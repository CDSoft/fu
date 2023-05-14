#!/usr/bin/env luax

local DEBUG = true

local process_blacklist = {
    ["alacritty"] = true,
    ["st"] = true,
    ["bash-language-server"] = true,
    ["clangd.main"] = true,
    ["clangd"] = true,
    ["dot-language-server"] = true,
    ["elm-language-server"] = true,
    ["lua-language-server"] = true,
    ["nimlsp"] = true,
    ["pasls"] = true,
    ["pyright-langserver"] = true,
    ["xclip"] = true,
    ["xsel"] = true,
    ["zls"] = true,
}

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

local window_id = sh.read "xprop -root" : lines()
    : filter(function(line) return line:find("_NET_ACTIVE_WINDOW(WINDOW)", 1, true) end)
    : head() : words() : last()
log("window_id: ", window_id)

if not window_id or tonumber(window_id) == 0 then exit() end

local window_pid = sh.read("xprop", "-id", window_id) : lines()
    : filter(function(line) return line:find("PID", 01, true) end)
    : head() : words() : last()
log("window_pid: ", window_pid)

if not window_pid or tonumber(window_pid) == 0 then exit() end

local pids = F{}
sh.read("pstree", "-lp", window_pid) : gsub("%((%d+)%)", function(pid) pids[#pids+1] = pid end)

local HOME_HIDDEN = fs.join(HOME, ".")

local function group(path)
    if path == "/" then return -1 end
    if path == HOME then return 1 end
    if path:has_prefix(HOME_HIDDEN) then return 2 end
    if path:has_prefix(HOME) then return 3 end
    return 0
end

local function read_process(i, pid)
    local exe = fs.readlink(fs.join("/proc", pid, "exe"))
    if not exe then return {} end
    local cwd = fs.readlink(fs.join("/proc", pid, "cwd"))
    if not cwd then return {} end
    return {
        exe = exe and fs.basename(exe),
        cwd = cwd,
        group = cwd and group(cwd),
        order = i,
    }
end

local function compare_processes(p1, p2)
    local r1 = p1.group
    local r2 = p2.group
    if r1 ~= r2 then return r1 < r2 end
    return p1.order < p2.order
end

local processes = pids
    : mapi(read_process)
    : filter(F.compose{F.op.lnot, F.null})
    : filter(function(proc) return not process_blacklist[proc.exe] end)
    : sort(compare_processes)

log("processes:\n", F.show(processes, {indent=4}))

exit(not processes:null() and processes:last().cwd)
