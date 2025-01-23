#!/usr/bin/env luax

-- Simplistic alternative to rofi

--local ps = require "ps"
--local t0 = ps.time()

local F = require "F"
local fs = require "fs"
local sh = require "sh"
local cbor = require "cbor"

local cache = "/tmp"/arg[0]:basename():splitext()

local args = (function()
    local parser = require "argparse"() : name(arg[0]:basename())
    parser : flag "-r" : description "refresh cache"
    return parser:parse(arg)
end)()

local refresh = args.r or (function()
    local cache_stat = fs.stat(cache)
    return not cache_stat or os.time() > cache_stat.mtime+86400
end)()

-------------------------------------------------------------------------------
-- Windows
-------------------------------------------------------------------------------
local windows_items, windows_actions

if os.getenv "SWAYSOCK" then

    windows_items, windows_actions = (function()
        local actions = {}
        local items = F(sh.read [[ swaymsg -t get_tree | jq -r '.. | select(.pid? and .name? and .focused==false) | "\(.pid) \(.name)"' ]] or "")
            : lines()
            : map(function(s)
                local wid, title = s:split("%s+", 1):unpack()
                title = title:trim()
                local item = ("%s win %s"):format(wid, title)
                actions[wid] = ("swaymsg '[pid=%s] focus'"):format(wid)
                return item
            end)
            : unlines()
        return items, actions
    end)()

else

    windows_items, windows_actions = (function()
        local actions = {}
        local items = F(sh.read "wmctrl -l" or "")
            : lines()
            : init() -- ignore the last window (i.e. the fzf-launcher window)
            : map(function(s)
                local wid, _, _, title = s:split("%s+", 3):unpack()
                title = title:trim()
                local item = ("%s win %s"):format(wid, title)
                actions[wid] = ("wmctrl -a %q"):format(title)
                return item
            end)
            : unlines()
        return items, actions
    end)()

end

-------------------------------------------------------------------------------
-- Applications
-------------------------------------------------------------------------------
local apps_items, apps_actions = (function()
    if not refresh then return end
    local lang -- = os.getenv"LANG":sub(1, 2)
    local section = ""
    local seen = {}
    local actions = {}
    local items = F{
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
            local name = lang and app["Name["..lang.."]"] or app["Name"]
            if not name or app["NoDisplay"] == "true" then return "" end
            local generic_name = lang and app["GenericName["..lang.."]"] or app["GenericName"]
            local comment = lang and app["Comment["..lang.."]"] or app["Comment"]
            local item = ("%s drun %s%s%s"):format(
                hash,
                name,
                generic_name and (" (%s)"):format(generic_name) or "",
                comment and (" -- %s"):format(comment) or ""
            )
            actions[hash] = ("nohup gio launch '%s' &>/dev/null &"):format(file)
            return item
        end)
        : filter(function(item) return #item > 0 end)
        : sort(function(a, b) return a:match" (.*)":lower() < b:match" (.*)":lower() end)
        : unlines()
    return items, actions
end)()

-------------------------------------------------------------------------------
-- Executables
-------------------------------------------------------------------------------
local exes_items, exes_actions = (function()
    if not refresh then return end
    local actions = {}
    local items = os.getenv "PATH"
        : split ":" ---@diagnostic disable-line: undefined-field
        : reverse()
        : map(function(path)
            return (fs.dir(path) or F{})
                : map(function(file)
                    local hash = (path/file):hash()
                    local item = ("%s run %s"):format(hash, file)
                    actions[hash] = ("nohup %s &>/dev/null &"):format(path/file)
                    return item
                end)
        end)
        : flatten()
        : sort()
        : sort(function(a, b) return a:match" (.*)":lower() < b:match" (.*)":lower() end)
        : unlines()
    return items, actions
end)()

-------------------------------------------------------------------------------
-- Cache
-------------------------------------------------------------------------------
local actions = {}
if refresh then
    fs.rmdir(cache)
    fs.mkdir(cache)
    fs.write(cache/"items", apps_items..exes_items)
    actions = F.merge{apps_actions, exes_actions}
    fs.write_bin(cache/"actions", cbor.encode(actions))
else
    actions = cbor.decode(assert(fs.read_bin(cache/"actions")))
end
fs.write(cache/"windows", windows_items)

-------------------------------------------------------------------------------
-- Run fzf
-------------------------------------------------------------------------------

--print(ps.time() - t0)

local item = sh.read {
    "cat", cache/"windows", cache/"items", "| fzf",
    "--exact",
    "--ignore-case",
    "--with-nth=2..",
    "--nth=2..",
    "--no-sort",
    --"--wrap",
    "--no-multi-line",
    "--layout=reverse",
    "--border=rounded",
    "--info=hidden",
    "--color=dark,current-bg:#287755,border:#287755,hl:#FF0000,hl+:#FF0000",
    "--highlight-line",
}
if not item then return end

item = item:trim()
local hash = item:words():head()
local action = assert(actions[hash] or windows_actions[hash], "can not execute "..item)

--io.stderr:write("item\t", item, "\n")
--io.stderr:write("action\t", action, "\n")

sh.run(action)
