#!/bin/env luax

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2025 Christophe Delord
https://codeberg.org/cdsoft/fu

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
local import = require "import"

I = F.I(_G) % "%%()"

local args = (function()
    local parser = require "argparse"() : name "fu" : description "Fedora Updater"
    parser : flag "-u" : description "Fast update"
    parser : flag "-f" : description "Force update of all packages"
    parser : flag "-r" : description "Reset the package database"
    parser : argument "packages" : description "Configuration or packages to update" : args "*"
    return parser : parse(arg)
end)()

FORCE = args.f
UPDATE = args.u or FORCE
RESET = args.r

function read(...)
    local out, msg = require "sh".read(...)
    if not out then error(msg) end
    return out:trim()
end

function run(...)
    assert(require "sh".run(...))
end

HOSTNAME = read "hostname"
HOME     = os.getenv "HOME"
USER     = os.getenv "USER"
FU_PATH  = HOME/".config"/"fu"

local function os_release(param) return read(". /etc/os-release; echo $"..param) end

OS_RELEASE_NAME         = os_release "NAME"
OS_RELEASE_PRETTY_NAME  = os_release "PRETTY_NAME"
OS_RELEASE_ID           = os_release "ID"
OS_RELEASE_VERSION_ID   = os_release "VERSION_ID"
RELEASE = read "rpm -E %fedora"

fs.chdir(arg[0]:realpath():dirname())

local function title(fmt, ...)
    local color = term.color.green + term.color.reverse
    print(color("▓▒░ %s ░▒▓"):format(fmt:format(...)))
end

local function log(fmt, ...)
    local color = F.case(fmt:lower():words():head()) {
        load = term.color.yellow,
        run = term.color.yellow,
        update = term.color.green + term.color.bold,
        [F.Nil] = term.color.cyan
    }
    print(color(">>> %s"):format(fmt:format(...)))
end

db = setmetatable({ dnf={}, lua={}, pip={}, npm={}, mime={}, sudoers={} }, {
    __index = {
        dbfile = FU_PATH/"db.lua",
        load = function(self)
            log("load %s", self.dbfile)
            if RESET then fs.remove(self.dbfile) end
            F(fs.is_file(self.dbfile) and assert(loadfile(self.dbfile))() or {})
               : foreachk(function(k, v) self[k] = v end)
        end,
        save = function(self)
            fs.mkdirs(self.dbfile:dirname())
            assert(fs.write(self.dbfile, "return "..F.show(self, {indent=4})))
        end,
        once = function(self, cond, key, func)
            if cond or not self[key] then
                func()
                self[key] = true
                self:save()
            end
        end,
    },
})
db:load()

-- update at least every 2 weeks
do
    local t0, t = db.last_update, os.time()
    if t0 and t - t0 > 14*86400 then UPDATE = true end
end
-- complete update at least every 4 weeks
do
    local t0, t = db.last_force, os.time()
    if t0 and t - t0 > 28*86400 then FORCE = true; UPDATE = true end
end

function when(cond)
    return cond and I or F.const""
end

function gitclone(url, options)
    url = I(url)
    local name = url:basename()
    local path = FU_PATH/name:gsub("%.git$", "")
    local function update()
        run {
            "cd", path,
            "&&",
            "git submodule sync",
            "&&",
            "git submodule update --init --recursive"
        }
    end
    if fs.is_dir(path) then
        if UPDATE then
            log("git update %s", url)
            run {
                "cd", path,
                "&&",
                "( git stash && ( (git checkout master && git reset --hard master) || (git checkout main && git reset --hard main) || true ) )",
                "&&",
                "git pull",
            }
            update()
        end
    else
        log("clone update %s", url)
        run { "git clone", url, path, options or {} }
        update()
    end
end

function repo(local_name, name)
    if not fs.is_file(I(local_name)) then
        name = I(name)
        log("add repo %s", name)
        run("sudo dnf install -y \""..name.."\"")
    end
end

function copr(local_name, name)
    if not fs.is_file(I(local_name)) then
        name = I(name)
        log("add copr %s", name)
        run("sudo dnf copr enable \""..name.."\"")
    end
end

function dnf_install(...)
    names = F.flatten{...}:map(I):unlines():words()
    local new_packages = names : filter(function(name) return not db.dnf[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        log("dnf install %s", new_names)
        run { "sudo dnf install", new_names, "--skip-broken --best --allowerasing" }
        new_packages : foreach(function(name) db.dnf[name] = true end)
        db:save()
    end
end

function luarocks(names, opts)
    names = I(names):words()
    local new_packages = names:filter(function(name) return FORCE or not db.lua[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        log("luarocks install %s", new_names)
        new_packages : foreach(function(name)
            run { "luarocks install --local", opts or {}, name }
            db.lua[name] = true
        end)
        db:save()
    end
end

function pip_install(names)
    names = I(names):words()
    local new_packages = names:filter(function(name) return UPDATE or not db.pip[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        log("pip install %s", new_names)
        run { "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring", "pip install --user", names }
        new_packages : foreach(function(name) db.pip[name] = true end)
        db:save()
    end
end

function npm_install(names)
    names = I(names):words()
    local new_packages = names:filter(function(name) return UPDATE or not db.npm[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        log("npm install %s", new_names)
        run { "cd && npm install", names }
        new_packages : foreach(function(name) db.npm[name] = true end)
        db:save()
    end
end

function npm_global_install(names)
    names = I(names):words()
    local new_packages = names:filter(function(name) return UPDATE or not db.npm[name] end)
    if #new_packages > 0 then
        local new_names = new_packages : unwords()
        log("npm global install %s", new_names)
        fs.mkdir(HOME/".npm-global")
        run "npm config set prefix '~/.npm-global'"
        run { "cd && npm install -g", names }
        new_packages : foreach(function(name) db.npm[name] = true end)
        db:save()
    end
end

function installed(cmd)
    return (os.execute("hash "..I(cmd).." 2>/dev/null"))
end

function try_download(url, dest)
    local sh = require "sh"
    log("download %s", url)
    dnf_install "curl"
    if not dest then
        return sh.read("curl", "-sSLf", I(url))
    end
    local ok, msg = sh.run("curl", "-sSLf", I(url), "-o", dest)
    if not ok then
        fs.remove(dest)
    end
    return ok, msg
end

function download(url, dest)
    local content, err = try_download(url, dest)
    if not content then error(err) end
    return content
end

function github_tag(url)
    return read { "curl", "-Ls", "-o /dev/null", '-w "%{url_effective}"', url } : basename()
end

function with_file(name, f)
    local content = fs.read(name)
    local new_content = f(content)
    if new_content and new_content ~= content then
        fs.write(name, new_content)
    end
end

function mime_default(desktop_file)
    desktop_file = I(desktop_file)
    local path = "/usr/share/applications"/desktop_file
    if fs.is_file(path) and not db.mime[desktop_file] then
        log("update mime association for %s", desktop_file)
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

local function install_package(package)
    if already_installed[package] then return end
    already_installed[package] = true
    title(package)
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
        if content ~= fs.read(dest) then
            log("update %s", dest)
            assert(fs.write(dest, content))
            fs.chmod(dest, file)
        end
    end)
    fs.ls(package/"root/**", true) : filter(fs.is_file) : foreach(function(file)
        local name = file:drop(#(package/"root/"))
        local dest = "/"..name
        local content = assert(fs.read(file))
        content = interpolate(file, content)
        if content ~= fs.read(dest) then
            log("update %s", dest)
            fs.with_tmpfile(function(tmp)
                assert(fs.write(tmp, content))
                fs.chmod(tmp, file)
                run { "sudo", "mv", "-f", tmp, dest }
                run { "sudo", "chown", "root:root", dest }
            end)
        end
    end)
    -- Package installation
    fs.ls(package/"*.lua") : foreach(function(script)
        log("run %s", script)
        assert(loadfile(script))(package)
    end)
end

local function install_configuration(name)
    title(name)
    F.foreach(CONFIGURATIONS, function(conf)
        local package_name = F.head(conf)
        local confs = F.tail(conf):flatten()
        if confs:elem(name) then
            install_package(package_name)
        end
    end)
end

log("load %s", HOME/".myconf")
myconf = fs.is_file(HOME/".myconf") and import(HOME/".myconf") or {}

require "config"

title(OS_RELEASE_PRETTY_NAME)

local implemented_packages = fs.dir() : filter(fs.is_dir) : sort() : filter(function(name) return name:head()~="." end)
local referenced_packages = F.map(F.head, CONFIGURATIONS)
local implemented_but_not_referenced = F.difference(implemented_packages, referenced_packages)
if #implemented_but_not_referenced > 0 then error(implemented_but_not_referenced:str(", ", " and ")..": implemented but not referenced") end
local referenced_but_not_implemented = F.difference(referenced_packages, implemented_packages)
if #referenced_but_not_implemented > 0 then error(referenced_but_not_implemented:str(", ", " and ")..": referenced but not implemented") end
local configuration_names = F(CONFIGURATIONS)
    : map(function(conf) return F.tail(conf) end)
    : flatten()
    : nub()
    : sort()
if #F.intersection(referenced_packages, configuration_names) > 0 then
    error(F.intersection(referenced_packages, configuration_names):str(", ", " and ")..": configurations and packages can not have the same names")
end

local function default_configuration()
    if db.default_configuration then return db.default_configuration end
    local linenoise = require "linenoise"
    local prompt = "Default configuration ("..configuration_names:str(", ").."): "
    for _ = 1, 3 do
        local name = linenoise.read(prompt)
        if configuration_names:elem(name) then
            db.default_configuration = name
            db:save()
            return name
        end
    end
    error "Try again..."
end

if #args.packages>0 and not db.default_configuration then
    error("the first installation must be a configuration, not individual packages")
end

local names = #args.packages>0 and args.packages or {default_configuration()}

F.foreach(PARAMETERS, function(conf)
    local name = F.head(conf)
    local confs = F.tail(conf):flatten()
    _G[name] = confs:elem(db.default_configuration)
end)

F.foreach(names, function(name)
    if referenced_packages:elem(name) then
        install_package(name)
    elseif configuration_names:elem(name) then
        install_configuration(name)
    else
        error(name..": configuration or package not found")
    end
end)

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
