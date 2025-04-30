local alacritty_sources = false
local install_foot_from_sources = false -- WARNING: this sets some root permissions in files installed in ~/.local !

-- Thunar bug with miniatures: rm -rf .cache/thumbnails
if FORCE then
    run "rm -rf .cache/thumbnails"
end

db:once(FORCE, "i3_sway_input_group_configured", function()
    run { "sudo usermod -a -G input", USER }
end)

dnf_install [[
    rxvt-unicode
    numlockx
    rlwrap
    i3 i3status i3lock dmenu xbacklight feh
    wmctrl
    picom
    arandr
    sox
    fortune-mod ImageMagick
    sxiv ristretto
    volumeicon pavucontrol
    adobe-source-code-pro-fonts
    mozilla-fira-mono-fonts
    mozilla-fira-sans-fonts
    fira-code-fonts
    google-droid-sans-mono-fonts
    dejavu-sans-mono-fonts
    rofi
    rofi-themes
    fontawesome-fonts
    fontawesome-fonts-web
    xbindkeys
    lxappearance
    gnome-tweak-tool
    qt-config
    qt5ct
    qqc2-desktop-style
    xfce4-settings
    xfce4-screenshooter
    xsetroot
    xfce4-notifyd
    xfce4-volumed
    barrier
    redshift
    keepassxc aspell-fr
    xdotool
    ksnip
    xinput
    Thunar
    thunar-archive-plugin.x86_64
    thunar-media-tags-plugin.x86_64
    thunar-vcs-plugin.x86_64
    thunar-volman.x86_64
    gnome-clocks
    polybar
    gtk4-devel libadwaita-devel
    cadaver
]]

dnf_install [[
    sway
    wdisplays
    SwayNotificationCenter
    swaybg
    swayidle
    swayimg
    swaylock
    waybar
    wf-recorder
    wlsunset
    grimshot
    swappy
    foot
]]

-- Nerd Fonts
local release = nil
local font_cache_update = false
local function install_font(name, file)
    if FORCE or not fs.is_file(HOME/".local/share/fonts"/file) then
        release = release or download("https://github.com/ryanoasis/nerd-fonts/releases/latest/"):match("tag/(v[%d%.]+)")
        download("https://github.com/ryanoasis/nerd-fonts/releases/download"/release/name..".zip", FU_PATH/name.."-"..release..".zip")
        fs.mkdirs(HOME/".local/share/fonts")
        run { "unzip", "-j", "-u", FU_PATH/name.."-"..release..".zip", "'*.ttf'", "-d", HOME/".local/share/fonts/" }
        font_cache_update = true
    end
end
install_font("SourceCodePro", "SauceCodeProNerdFont-Regular.ttf")
install_font("FiraCode", "FiraCodeNerdFont-Regular.ttf")

-- FontAweome
--[[
local function install_fontawesome()
    local file = "FontAwesome.otf"
    if FORCE or not fs.is_file(HOME/".local/share/fonts"/file) then
        local url = download("https://www.cdnpkg.com/font-awesome/file/FontAwesome.otf/"):match('href="(https://get%.cdnpkg%.com/font%-awesome/[%d%.]+/FontAwesome%.otf)"')
        download(url, FU_PATH/file)
        fs.copy(FU_PATH/file, HOME/".local/share/fonts/"/file)
        font_cache_update = true
    end
end
install_fontawesome()
--]]

-- Update font cache
if font_cache_update then
    run "fc-cache -f"
end

-- alacritty
if alacritty_sources and fs.is_file(HOME/".cargo/bin/cargo") and (FORCE or not installed "alacritty") then
    -- Prerequisites
    dnf_install [[ cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ ]]
    -- Get sources
    gitclone "https://github.com/alacritty/alacritty.git"
    -- Build
    run { "cd", FU_PATH/"alacritty", "&&", "~/.cargo/bin/cargo build --release --no-default-features --features=x11" }
    -- Terminfo
    run { "cd", FU_PATH/"alacritty", "&&", "sudo tic -xe alacritty,alacritty-direct extra/alacritty.info" }
    -- Install Alacritty (or replace the existing executable)
    run { "rm -f", HOME/".local/bin/alacritty" }
    run { "cp", FU_PATH/"alacritty/target/release/alacritty", HOME/".local/bin" }
    run { "strip", HOME/".local/bin/alacritty" }
    -- Desktop Entry
    run { "sudo cp", FU_PATH/"alacritty/extra/logo/alacritty-term.svg", "/usr/share/pixmaps/Alacritty.svg" }
    run { "cd", FU_PATH/"alacritty", "&&", "sudo desktop-file-install extra/linux/Alacritty.desktop" }
    run { "sudo update-desktop-database" }
    -- Manual Page
    fs.mkdirs(HOME/".local/share/man/man1")
    run { "cd", FU_PATH/"alacritty", "&&", "gzip -c extra/alacritty.man", ">", "tee", HOME/".local/share/man/man1/alacritty.1.gz" }
    run { "cd", FU_PATH/"alacritty", "&&", "gzip -c extra/alacritty-msg.man", ">", "tee", HOME/".local/share/man/man1/alacritty-msg.1.gz" }
else
    dnf_install "alacritty"
end

-- urxvt
if FORCE or not fs.is_file(HOME/".urxvt/ext/font-size") then
    -- Urxvt font-size
    gitclone "https://github.com/majutsushi/urxvt-font-size"
    fs.mkdirs(HOME/".urxvt/ext")
    run { "cp", FU_PATH/"urxvt-font-size/font-size", HOME/".urxvt/ext/" }
end

-- st
if FORCE or not fs.is_file(HOME/".local/bin/st") then
    local version = "0.9"
    gitclone("https://git.suckless.org/st")
    run { "cd", FU_PATH/"st", "&&", "git reset --hard master", "&&", "git checkout master", "&&", "git clean -dfx", "&&", "git fetch", "&&", "git rebase" }
    run { "cd", FU_PATH/"st", "&&", "git checkout", version }
    local function patch(url)
        local file = FU_PATH/"st-patches"/fs.basename(url)
        if not fs.is_file(file) then
            fs.mkdirs(fs.dirname(file))
            download(url, file)
        end
        run { "cd", FU_PATH/"st", "&&", "patch -p1 <", file }
    end
    patch "https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff"
    --patch "https://st.suckless.org/patches/fix_keyboard_input/st-fix-keyboard-input-20180605-dc3b5ba.diff"
    patch "https://st.suckless.org/patches/dynamic-cursor-color/st-dynamic-cursor-color-0.9.diff"
    patch "https://st.suckless.org/patches/gruvbox/st-gruvbox-dark-0.8.5.diff"
    patch "https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff"
    patch "https://st.suckless.org/patches/desktopentry/st-desktopentry-0.8.5.diff"
    --patch "https://st.suckless.org/patches/dracula/st-dracula-0.8.5.diff"
    patch "https://st.suckless.org/patches/right_click_to_plumb/simple_plumb.diff"
    --patch "https://st.suckless.org/patches/right_click_to_plumb/simple_plumb-0.8.5.diff"
    --patch "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff"
    --patch "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20220127-2c5edf2.diff"
    --patch "https://st.suckless.org/patches/undercurl/st-undercurl-0.8.4-20210822.diff"

    -- Same colors than Alacritty

    local colors = {
        -- /* 8 normal colors */
        [ 0] = "#000000",
        [ 1] = "#cd3131",
        [ 2] = "#0dbc79",
        [ 3] = "#e5e510",
        [ 4] = "#2472c8",
        [ 5] = "#bc3fbc",
        [ 6] = "#11a8cd",
        [ 7] = "#e5e5e5",

        -- /* 8 bright colors */
        [ 8] = "#666666",
        [ 9] = "#f14c4c",
        [10] = "#23d18b",
        [11] = "#f5f543",
        [12] = "#3b8eea",
        [13] = "#d670d6",
        [14] = "#29b8db",
        [15] = "#e5e5e5",

        -- /* more colors can be added after 255 to use with DefaultXX */
        [256] = "#000000",
        [257] = "#f8f8f2",
        [258] = "#000000",
        [259] = "#eeeeee",
    }
    with_file(FU_PATH/"st/config.def.h", function(config)
        config = config:gsub("font = \".-\";", I"font = \"%(FONT):style=%(FONT_VARIANT):size=%(FONT_SIZE):antialias=true:autohint=true\";")
        config = config:gsub("worddelimiters = L\".-\";", I"worddelimiters = L\" `'\\\"()[]{}\";")
        for i, c in pairs(colors) do
            config = config:gsub('(%['..i..'%]) = "(#......)"', '%1 = "'..c..'"')
        end
        return config
    end)

    run(I[[cd %(FU_PATH)/st && sed -i 's#PREFIX =.*#PREFIX = %(HOME)/.local#' config.mk]])
    run(I[[cd %(FU_PATH)/st && sed -i 's#MANPREFIX =.*#MANPREFIX = %(HOME)/.local/man#' config.mk]])
    run(I[[cd %(FU_PATH)/st && make install]])
end

-- ghostty
if GHOSTTY then
    if FORCE or not fs.is_file(HOME/".local/bin/ghostty") then
        gitclone "https://github.com/ghostty-org/ghostty"
        run {
            "cd", FU_PATH/"ghostty",
            "&&",
            "zig build", "-p $HOME/.local", "-Doptimize=ReleaseFast",
        }
    end
end

-- foot
if install_foot_from_sources then
    if FORCE or not fs.is_file(HOME/".local/bin/foot") then
        dnf_install "meson scdoc utf8proc-devel"
        gitclone "https://codeberg.org/dnkl/foot"
        assert(fs.mkdirs(FU_PATH/"foot/bld/release"))
        run {
            "cd", FU_PATH/"foot/bld/release",
            "&&",
            "export CFLAGS='-O3'",
            "&&",
            "meson", "../..", "--prefix=~/.local",
                "--reconfigure",
                "--buildtype=release",
                "-Db_lto=true",
                "-Ddocs=enabled",
                "-Dgrapheme-clustering=enabled",
            "&&",
            "ninja",
            "&&",
            "ninja install",
        }
    end
end

-- https://docs.xfce.org/xfce/xfconf/xfconf-query#listing_properties
do
    -- xfce4-terminal configuration
    -- xfconf-query -c xfce4-terminal -lv
    F[[
        /color-palette                  #000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec
        /font-name                      %(FONT) %(FONT_VARIANT) %(FONT_SIZE)
        /misc-always-show-tabs          false
        /misc-bell                      false
        /misc-bell-urgent               true
        /misc-borders-default           true
        /misc-confirm-close             false
        /misc-copy-on-select            true
        /misc-cursor-blinks             false
        /misc-cursor-shape              TERMINAL_CURSOR_SHAPE_BLOCK
        /misc-cycle-tabs                true
        /misc-default-geometry          80x24
        /misc-highlight-urls            true
        /misc-inherit-geometry          false
        /misc-menubar-default           false
        /misc-middle-click-opens-uri    false
        /misc-mouse-autohide            false
        /misc-mouse-wheel-zoom          true
        /misc-new-tab-adjacent          false
        /misc-rewrap-on-resize          true
        /misc-right-click-action        TERMINAL_RIGHT_CLICK_ACTION_CONTEXT_MENU
        /misc-search-dialog-opacity     100
        /misc-show-relaunch-dialog      true
        /misc-show-unsafe-paste-dialog  true
        /misc-slim-tabs                 true
        /misc-tab-close-buttons         true
        /misc-tab-close-middle-click    true
        /misc-tab-position              GTK_POS_TOP
        /misc-toolbar-default           false
        /overlay-scrolling              true
        /scrolling-lines                10001
        /shortcuts-no-menukey           true
        /shortcuts-no-mnemonics         true
        /title-mode                     TERMINAL_TITLE_REPLACE
    ]] : trim() : lines() : foreach(function(line)
        local param, value = line:trim():split("%s+", 1):unpack()
        run { "xfconf-query -c xfce4-terminal", "-p", param, "-s", string.format("%q", I(value)) }
    end)

    -- xfce4-notifyd
    -- xfconf-query -c xfce4-notifyd -lv
    F[[
        /theme                            Greybird
    ]] : trim() : lines() : foreach(function(line)
        local param, value = line:trim():split("%s+", 1):unpack()
        run { "xfconf-query -c xfce4-notifyd", "-p", param, "-s", string.format("%q", I(value)) }
    end)
end

-- Default programs

mime_default "%(BROWSER).desktop"
mime_default "transmission-gtk.desktop"
mime_default "libreoffice-base.desktop"
mime_default "libreoffice-calc.desktop"
mime_default "libreoffice-draw.desktop"
mime_default "libreoffice-impress.desktop"
mime_default "libreoffice-math.desktop"
mime_default "libreoffice-startcenter.desktop"
mime_default "libreoffice-writer.desktop"
mime_default "libreoffice-xsltfilter.desktop"
if THUNDERBIRD then
    mime_default "mozilla-thunderbird.desktop"
end
mime_default "atril.desktop"
mime_default "thunar.desktop"
--mime_default "pcmanfm.desktop"
mime_default "ristretto.desktop" -- shall be configured after atril to overload atril associations
mime_default "vlc.desktop"
mime_default "wireshark.desktop"
mime_default "nvim.desktop"

if FORCE or not installed "hsetroot" then
    dnf_install "imlib2-devel libXinerama-devel"
    gitclone "https://github.com/himdel/hsetroot"
    run { "cd", FU_PATH/"hsetroot", "&&", "make", "&&", "DESTDIR="..HOME, "PREFIX=/.local", "make install" }
end

if not fs.is_file(HOME/".config/i3/empty.wav") then
    fs.write(HOME/".config/i3/empty.wav", F"UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=":unbase64())
end

if read { "getcap", read"which i3status" } : words()[2] ~= "cap_net_admin=ep" then
    run { "sudo setcap cap_net_admin=ep", read'which i3status' }
end
