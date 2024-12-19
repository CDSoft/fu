#!/usr/bin/env luax

-- Simplistic alternative to rofi

--local ps = require "ps"
--local t0 = ps.time()

local F = require "F"
local fs = require "fs"
local sh = require "sh"
local cbor = require "cbor"

local dbname = "/tmp/fzf-launcher.db"

local args = (function()
    local parser = require "argparse"() : name "fzf-launcher.lua"
    parser : flag "-r" : description "reset database"
    parser : flag "-w" : description "list Windows"
    parser : flag "-d" : description "list Desktop applications"
    parser : flag "-p" : description "list applications in PATH"
    return parser:parse(arg)
end)()
if not args.w and not args.d and not args.p then
    args.w = true
    args.d = true
    args.p = true
end

local new_db = false

local db = { actions={} }
local dbstat = fs.stat(dbname)
if dbstat then
    if args.r or dbstat.mtime > os.time() then
        fs.remove(dbname)
    else
        db = cbor.decode(fs.read_bin(dbname))
    end
end

local actions = {}

local function list_windows()
    if not args.w then return F{} end
    return F(sh.read "wmctrl -l" or "")
        : lines()
        : init() -- ignore the last window (i.e. the fzf-launcher window)
        : map(function(s)
            local wid, _, _, title = s:split("%s+", 3):unpack()
            title = title:trim()
            local item = ("%s win %s"):format(wid, title)
            actions[item] = ("wmctrl -a %q"):format(title)
            return item
        end)
end

local function list_applications()
    if not args.d then return F{} end
    if db.applications then return db.applications end
    local lang = os.getenv"LANG":sub(1, 2)
    local section = ""
    local seen = {}
    new_db = true
    db.applications = F{
            fs.ls("/usr/share/applications/*.desktop"),
            fs.ls(os.getenv"HOME"/".local/share/applications/*.desktop"),
        }
        : flatten()
        : map(function(file)
            local content = fs.read(file)
            local hash = content:hash()
            if seen[hash] then return "" end
            seen[hash] = true
            local app = content
                : lines()
                : map(function(s)
                    local new_section = s:match("^%[(.-)%]")
                    if new_section then
                        section = new_section
                        return {"_", nil}
                    end
                    if section ~= "Desktop Entry" then return {"_", nil} end
                    local k, v = s:split("=", 1):unpack()
                    if not k then return {"_", nil} end
                    return {k, v}
                end)
                : from_list()
            local name = app["Name["..lang.."]"] or app["Name"]
            if not name or app["NoDisplay"] == "true" then return "" end
            local generic_name = app["GenericName["..lang.."]"] or app["GenericName"]
            local comment = app["Comment["..lang.."]"] or app["Comment"]
            local item = ("%s drun %s%s%s"):format(
                hash,
                name,
                (generic_name) and (" (%s)"):format(generic_name) or "",
                (comment) and (" -- %s"):format(comment) or ""
            )
            actions[item] = ("nohup gio launch %s &>/dev/null &"):format(file)
            db.actions[item] = actions[item]
            return item
        end)
        : filter(function(item) return #item > 0 end)
        : sort(function(a, b) return a:match" (.*)":lower() < b:match" (.*)":lower() end)
    return db.applications
end

local function list_executables()
    if not args.p then return F{} end
    if db.executables then return db.executables end
    db.executables =  os.getenv "PATH"
        : split ":" ---@diagnostic disable-line: undefined-field
        : reverse()
        : map(function(path)
            return (fs.dir(path) or F{})
                : map(function(file)
                    local item = ("%s run %s"):format((path/file):hash(), file)
                    actions[item] = ("nohup %s &>/dev/null &"):format(path/file)
                    db.actions[item] = actions[item]
                    return item
                end)
        end)
        : flatten()
        : sort()
        : sort(function(a, b) return a:match" (.*)":lower() < b:match" (.*)":lower() end)
    return db.executables
end

local windows = list_windows()
local applications = list_applications()
local executables = list_executables()

local itemfile = "/tmp/fzf-launcher-items"
local items = assert(io.open(itemfile, "w"))
local function write_item(item) items:write(item, "\n") end
F.foreach(windows, write_item)
F.foreach(applications, write_item)
F.foreach(executables, write_item)
items:close()

if new_db then
    fs.write_bin(dbname, cbor.encode(db))
end

--print(ps.time() - t0)

local item = sh.read {
    "cat", itemfile, "| fzf",
    "--exact",
    "--ignore-case",
    "--with-nth=2..",
    "--nth=2..",
    "--no-sort",
    --"--wrap",
    "--no-multi-line",
    "--height=-1",
    "--layout=reverse",
    "--border=rounded",
    "--info=hidden",
    "--color=dark,current-bg:#105020",
    "--highlight-line",
}
if not item then return end

item = item:trim()
local action = assert(actions[item] or db.actions[item], "can not execute "..item)

--io.stderr:write("item\t", item, "\n")
--io.stderr:write("action\t", action, "\n")

sh.run(action)
