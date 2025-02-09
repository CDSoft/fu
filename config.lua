TIMEZONE = "Europe/Paris"
KEYMAP   = "fr"
LOCALE   = "fr_FR.UTF-8"

I3_THEME     = "green" -- "blue" (default), "green"

FONT_VARIANT = "Medium"
FONT         = "FiraCode Nerd Font"
--FONT         = "SauceCodePro Nerd Font"

FONT_SIZE = 9

I3_INPUT_FONT = "-*-*-*-*-*-*-20-*-*-*-*-*-*-*"

BROWSER = "firefox"
BROWSER2 = "chromium-browser"

------------------------------------------------------------------------------
-- Configuration lists
------------------------------------------------------------------------------

local _ = {}
local D = "desktop"
local L = "laptop"
local V = "vm"
local P = "pro"

CONFIGURATIONS = {
    { "system",         D, L, V, P },
    { "luax",           D, L, V, P },
    { "rust",           _, _, _, _ },
    { "shell",          D, L, V, P },
    { "network",        D, L, V, P },
    { "nextcloud",      D, L, V, _ },
    { "filesystem",     D, L, V, P },
    { "devel",          D, L, V, P },
    { "lua",            D, L, V, P },
    { "zig",            D, L, V, P },
    { "numbat",         D, L, V, P },
    { "haskell",        D, _, _, P },
    { "ocaml",          _, _, _, P },
    { "frama-c",        _, _, _, P },
    { "racket",         _, _, _, _ },
    { "julia",          _, _, _, _ },
    { "freepascal",     _, _, _, _ },
    { "wasmer",         _, _, _, _ },
    { "nim",            _, _, _, _ },
    { "swiprolog",      D, _, _, _ },
    { "bash",           D, L, V, P },
    { "graphviz",       D, _, V, P },
    { "python",         D, _, V, P },
    { "javascript",     _, _, _, _ },
    { "pandoc",         D, L, V, P },
    { "typst",          D, L, V, P },
    { "latex",          D, _, _, P },
    { "asymptote",      D, _, _, P },
    { "blockdiag",      D, _, V, P },
    { "mermaid",        D, _, V, P },
    { "neovim",         D, L, V, P },
    { "vscode",         D, _, _, P },
    { "graphic",        D, L, V, P },
    { "i3",             D, L, V, P },
    { "geogebra",       D, L, V, P },
    { "internet",       D, L, V, P },
    { "1password",      D, _, _, P },
    { "zoom",           D, _, _, P },
    { "virtualization", D, L, _, P },
    { "work",           _, _, _, P },
    { "vpn",            _, _, _, P },
}

PARAMETERS = {
    { "RFKILL",         _, _, _, P },
    { "NUMLOCK",        D, _, V, P },
    { "WALLPAPER",      D, _, _, _ },
    { "START_VLC",      _, _, _, _ },
    { "THUNDERBIRD",    D, _, _, _ },
    { "PICOM",          D, _, _, P },
    { "GHOSTTY",        _, _, _, _ },
}
