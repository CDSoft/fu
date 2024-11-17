#!/usr/bin/env luax

-- check the clipboards every 30 seconds
-- and clear their contents when they are older than 15 minutes

local cleanup_period = 30
local selection_persistence = 15*60

local selections = {
    {   name = "X",
        content = "",
        time = nil,
        read = "xclip -o 2>/dev/null",
        write = "xclip",
    },
    {   name = "WM",
        content = "",
        time = nil,
        read = "xclip -selection clipboard 2>/dev/null",
        write = "xclip -selection clipboard /dev/null",
    },
}

local DEBUG = false

local F = require "F"
local ps = require "ps"
local sh = require "sh"

local log
if DEBUG then
    local log_file = assert(io.open("/tmp/transient_clipboard.log", "a+"))
    log = function(...) log_file:write(...) log_file:write "\n" end
else
    log = F.const()
end

local function truncate(s, w)
    if #s <= w then return s end
    return s:sub(1, w).."..."
end

function cleanup(selection)

    local content = sh.read(selection.read)
    if not content or content == "" then return end

    local time = ps.time()

    if selection.content == content then
        if #content > 0 and time > selection.time + selection_persistence then
            -- unchanged for a long time => blank
            sh.write(selection.write)""
            selection.content = ""
            selection.time = time
            log(
                F"=":rep(80), "\n",
                os.date(), " - ", selection.name, " cleared"
            )
        end
    else
        -- new content
        selection.content = content
        selection.time = time
        log(
            F"=":rep(80), "\n",
            os.date(), " - ", selection.name, "\n",
            F"-":rep(80), "\n",
            truncate(selection.content, 64)
        )
    end

end

while true do
    F.foreach(selections, cleanup)
    ps.sleep(cleanup_period)
end
