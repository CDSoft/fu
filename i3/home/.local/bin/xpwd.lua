#!/usr/bin/env luax

-- e.g. with i3wm and alacritty
-- in .config/i3/config:
-- bindsym $mod+Return exec alacritty --working-directory "`xpwd.lua`"
--
-- It requires http://cdelord.fr/luax

-- @RAW

local F = require "F"
local sh = require "sh"
local fs = require "fs"

local DEBUG = true

local process_blacklist = F[[
    alacritty
    xfce4-terminal
    st
    bash-language-server
    clangd.main
    clangd
    dot-language-server
    elm-language-server
    lua-language-server
    nimlsp
    pasls
    pyright-langserver
    xclip
    xsel
    zls
    firefox
    chromium-browser
    keepassxc-proxy
    plugin-container
    thunderbird
    wezterm-gui
    ghostty
    foot
]] : words() : from_set(F.const(true))

local path_blacklist = F[[
    /opt/1Password
]] : words() : from_set(F.const(true))

local HOME = os.getenv "HOME"

local function exit(cwd)
    print(cwd and cwd ~= "" and cwd or HOME)
    os.exit()
end

local log
if DEBUG then
    local log_file = assert(io.open("/tmp/xpwd.log", "a+"))
    log = function(...) log_file:write(...) log_file:write "\n" end
else
    log = F.const()
end

log(F"#":rep(80))
log("date: ", os.date())

local window_pid

if os.getenv "SWAYSOCK" then

    window_pid = sh.read "swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid'"

else

    local window_id = sh.read("xprop", "-root") : lines()
        : filter(function(line) return line:find("_NET_ACTIVE_WINDOW(WINDOW)", 1, true) end)
        : head() : words() : last()
    log("window_id: ", window_id)

    if not window_id or tonumber(window_id) == 0 then exit() end

    window_pid = sh.read("xprop", "-id", window_id) : lines()
        : filter(function(line) return line:find("PID", 01, true) end)
        : head() : words() : last()

end

log("window_pid: ", window_pid)

window_pid = tonumber(window_pid) or 0

if window_pid == 0 then exit() end

local pids = F{}
sh.read("pstree", "-lp", window_pid) : gsub("%((%d+)%)", function(pid) pids[#pids+1] = pid end)

local function read_process(i, pid)
    local exe = fs.readlink(fs.join("/proc", pid, "exe"))
    if not exe then return F.Nil end
    exe = fs.basename(exe) : gsub(" %(deleted%)$", "")
    if process_blacklist[exe]then return F.Nil end
    local cwd = fs.readlink(fs.join("/proc", pid, "cwd"))
    if not cwd or not fs.is_dir(cwd) then return F.Nil end
    if path_blacklist[cwd]then return F.Nil end
    return {
        exe = exe,
        cwd = cwd,
        order = i,
    }
end

local function compare_processes(p1, p2)
    return p1.order < p2.order
end

local processes = pids
    : mapi(read_process)
    : filter(F.curry(F.op.ne)(F.Nil))
    : sort(compare_processes)

log("processes:\n", processes
    : map(function(p)
        return ("%d: %-32s -> %s"):format(p.order, p.exe, p.cwd)
    end)
    : unlines()
)

exit(not processes:null() and processes:last().cwd)
