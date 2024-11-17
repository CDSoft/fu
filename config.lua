myconf = {}
if fs.is_file(HOME/".myconf") then
    assert(loadfile(HOME/".myconf", "t", myconf))()
end

local function os_release(param) return read(". /etc/os-release; echo $"..param):trim() end
OS_RELEASE_NAME         = os_release "NAME"
OS_RELEASE_PRETTY_NAME  = os_release "PRETTY_NAME"
OS_RELEASE_ID           = os_release "ID"
OS_RELEASE_VERSION_ID   = os_release "VERSION_ID"

RELEASE = read "rpm -E %fedora" : trim()

title(OS_RELEASE_PRETTY_NAME)

LUA_VERSION = "5.4.7"

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

WIKI = myconf.wiki or HOME
