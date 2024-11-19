local function os_release(param) return read(". /etc/os-release; echo $"..param):trim() end
OS_RELEASE_NAME         = os_release "NAME"
OS_RELEASE_PRETTY_NAME  = os_release "PRETTY_NAME"
OS_RELEASE_ID           = os_release "ID"
OS_RELEASE_VERSION_ID   = os_release "VERSION_ID"

RELEASE = read "rpm -E %fedora" : trim()

title(OS_RELEASE_PRETTY_NAME)

TIMEZONE = "Europe/Paris"
KEYMAP   = "fr"
LOCALE   = "fr_FR.UTF-8"

I3_THEME     = "green" -- "blue" (default), "green"

FONT_VARIANT = "Medium"
FONT         = "FiraCode Nerd Font"
--FONT         = "SauceCodePro Nerd Font"

dnf_install "xdpyinfo"
local xres, yres = (read "xdpyinfo | awk '/dimensions/ {print $2}'" or "1920x1080") : trim() : split "x" : map(tonumber) : unpack()
FONT_SIZE =    (xres <= 1920 or yres <= 1080) and 9
            or (xres <= 2560 or yres <= 1440) and 9+4
            or                                    9+8
I3_INPUT_FONT = "-*-*-*-*-*-*-20-*-*-*-*-*-*-*"
ST = I"st"
ALACRITTY = I"alacritty"

BROWSER = "firefox"
BROWSER2 = "chromium-browser"

------------------------------------------------------------------------------
-- Configuration lists
------------------------------------------------------------------------------

local _ = {}
local D = "desktop"
local L = "laptop"
local P = "pro"

CONFIGURATIONS = {
    { "system",         D, L, P },
    { "luax",           D, L, P },
    { "rust",           _, _, _ },
    { "shell",          D, L, P },
    { "network",        D, L, P },
    { "nextcloud",      D, L, _ },
    { "filesystem",     D, L, P },
    { "devel",          D, L, P },
    { "lua",            D, L, P },
    { "zig",            D, L, P },
    { "numbat",         D, L, P },
    { "haskell",        D, _, P },
    { "ocaml",          _, _, P },
    { "frama-c",        _, _, P },
    { "racket",         _, _, _ },
    { "julia",          _, _, _ },
    { "freepascal",     _, _, _ },
    { "wasmer",         _, _, _ },
    { "nim",            _, _, _ },
    { "swiprolog",      D, _, _ },
    { "bash",           D, L, P },
    { "graphviz",       D, _, P },
    { "python",         D, _, P },
    { "javascript",     _, _, _ },
    { "pandoc",         D, L, P },
    { "typst",          D, L, P },
    { "latex",          D, _, P },
    { "asymptote",      D, _, P },
    { "blockdiag",      D, _, P },
    { "mermaid",        D, _, P },
    { "neovim",         D, L, P },
    { "vscode",         D, _, P },
    { "i3",             D, L, P },
    { "graphic",        D, L, P },
    { "geogebra",       D, L, P },
    { "internet",       D, L, P },
    { "zoom",           D, _, P },
    { "virtualization", D, L, P },
    { "work",           _, _, P },
    { "vpn",            _, _, P },
}

PARAMETERS = {
    { "RFKILL",             _, _, P },
    { "NUMLOCK",            D, _, P },
    { "WALLPAPER",          D, _, _ },
    { "START_VLC",          D, _, _ },
    { "USE_THUNDERBIRD",    D, _, _ },
}
