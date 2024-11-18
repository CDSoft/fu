#!/bin/env luax

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2025 Christophe Delord
https://github.com/CDSoft/fu

This file is part of Fedora Updater (FU)

FU is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FU is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FU.  If not, see <http://www.gnu.org/licenses/>.
====================================================================--]]

F = require "F"
fs = require "fs"
local term = require "term"

I = F.I(_G) % "%%()"

local args = (function()
    local parser = require "argparse"()
        : name "fu"
        : description "Fedora Updater"
    parser : flag "-u" : description "Fast update"
    parser : flag "-f" : description "Force update of all packages"
    parser : flag "-r" : description "Reset the package database"
    parser : argument "packages" : description "Packages to update" : args "*"
    return parser : parse(arg)
end)()

FORCE = args.f
UPDATE = args.u or FORCE
RESET = args.r

function read(...) return assert(require "sh".read(...)):trim() end
function run(...) assert(require "sh".run(...)) end

HOSTNAME = read "hostname"
HOME     = os.getenv "HOME"
USER     = os.getenv "USER"
FU_PATH  = HOME/".config"/"fu"

fs.chdir(arg[0]:realpath():dirname())

local db_mt = {__index={}}
function db_mt.__index:dbfile() return FU_PATH/"db.lua" end
function db_mt.__index:reset() fs.remove(self:dbfile()) end
function db_mt.__index:load()
    local dbfile = self:dbfile()
    local confdb = {}
    if fs.is_file(dbfile) then
        confdb = assert(loadfile(dbfile))()
    end
    confdb.dnf = confdb.dnf or {}
    confdb.lua = confdb.lua or {}
    confdb.pip = confdb.pip or {}
    confdb.mime = confdb.mime or {}
    F.foreachk(self, function(k, _) self[k] = nil end)
    F.foreachk(confdb, function(k, v) self[k] = v end)
end
function db_mt.__index:save()
    local dbfile = self:dbfile()
    fs.mkdirs(dbfile:dirname())
    assert(fs.write(dbfile, "return "..F.show(self, {indent=4})))
end
db = setmetatable({}, db_mt)
if RESET then db:reset() end
db:load()

-- update at least every 2 weeks
do
    local t0 = db.last_update or 0
    local t = os.time()
    if t - t0 > 14*86400 then UPDATE = true end
end
-- complete update at least every 4 weeks
do
    local t0 = db.last_force or 0
    local t = os.time()
    if t - t0 > 28*86400 then FORCE = true; UPDATE = true end
end

function title(s)
    local cols = term.size(io.stdout).cols
    local color = term.color.black + term.color.ongreen
    s = I(s or arg[0])
    s = s .. string.rep(" ", cols - #s - 4)
    print(color("### "..s:ljust(cols-#s-4)))
end

function when(cond)
    return function(s) return cond and I(s) or "" end
end

function gitclone(url, options)
    url = I(url)
    local name = url:basename()
    options = F.unwords(options or {})
    local path = FU_PATH/name:gsub("%.git$", "")
    if fs.is_dir(path) then
        run {
            "cd", path,
            "&&",
            "( git stash && ( (git checkout master && git reset --hard master) || (git checkout main && git reset --hard main) || true ) )",
            "&&",
            "git pull",
        }
    else
        run { "git clone", url, path, options }
    end
    run {
        "cd", path,
        "&&",
        "git submodule sync",
        "&&",
        "git submodule update --init --recursive"
    }
end

function repo(local_name, name)
    if not fs.is_file(I(local_name)) then
        name = I(name)
        run("sudo dnf install -y \""..name.."\"")
    end
end

function copr(local_name, name)
    if not fs.is_file(I(local_name)) then
        name = I(name)
        run("sudo dnf copr enable \""..name.."\"")
    end
end

function dnf_install(...)
    names = F.flatten{...}:map(I):unlines():words()
    local new_packages = names : filter(function(name) return not db.dnf[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        print("# dnf install "..new_names)
        run { "sudo dnf install", new_names, "--skip-broken --best --allowerasing" }
        new_packages : foreach(function(name) db.dnf[name] = true end)
        db:save()
    end
end

function luarocks(names, opts)
    names = I(names):words()
    local new_packages = names:filter(function(name) return not db.lua[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        print("# luarocks install "..new_names)
        new_packages : foreach(function(name)
            run { "luarocks install --local", opts or {}, name }
            db.lua[name] = true
        end)
        db:save()
    end
end

function pip_install(names)
    names = I(names):words()
    local new_packages = names:filter(function(name) return not db.pip[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        print("# pip install "..new_names)
        run { "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring", "pip install --user", names }
        new_packages : foreach(function(name) db.pip[name] = true end)
        db:save()
    end
end

function installed(cmd)
    return (os.execute("hash "..I(cmd).." 2>/dev/null"))
end

function download(url)
    return assert(require"sh".read("curl", "-sSL", I(url)))
end

function with_file(name, f)
    local content = fs.read(name)
    content = f(content)
    fs.write(name, content)
end

function mime_default(desktop_file)
    desktop_file = I(desktop_file)
    local path = "/usr/share/applications"/desktop_file
    if fs.is_file(path) and not db.mime[desktop_file] then
        fs.read(path):gsub("MimeType=([^\n]*)", function(mimetypes)
            mimetypes:gsub("[^;]+", function(mimetype)
                run { "xdg-mime default", desktop_file, mimetype }
            end)
        end)
        db.mime[desktop_file] = true
        db:save()
    end
end

local already_installed = {}

function install(package)
    if already_installed[package] then return end
    already_installed[package] = true
    assert(fs.is_dir(package), package..": package not found")
    -- Configuration files
    local function interpolate(name, content)
        if content:match("@RAW") then return content end
        local ok, res = pcall(I, content)
        if not ok then error(name..": interpolation error") end
        return res
    end
    fs.ls(package/"home/**", true) : filter(fs.is_file) : foreach(function(file)
        local name = file:drop(#(package/"home/"))
        local dest = HOME/name
        fs.mkdirs(dest:dirname())
        local content = assert(fs.read(file))
        content = interpolate(file, content)
        assert(fs.write(dest, content))
        fs.chmod(dest, file)
    end)
    fs.ls(package/"root/**", true) : filter(fs.is_file) : foreach(function(file)
        local name = file:drop(#(package/"root/"))
        local dest = "/"..name
        fs.with_tmpfile(function(tmp)
            local content = assert(fs.read(file))
            content = interpolate(file, content)
            assert(fs.write(tmp, content))
            fs.chmod(tmp, file)
            run { "sudo", "mv", "-f", tmp, dest }
            run { "sudo", "chown", "root:root", dest }
        end)
    end)
    -- Package installation
    fs.ls(package/"*.lua") : foreach(function(script)
        assert(loadfile(script))(package)
    end)
end

require "config"

F.foreach(#args.packages>0 and args.packages or {HOSTNAME}, install)

if UPDATE then
    title "Upgrade packages"
    run "sudo dnf update --refresh"
    run "sudo dnf upgrade"
end

if UPDATE then
    local t = os.time()
    db.last_update = t
    if FORCE then
        db.last_force = t
    end
    db:save()
end
