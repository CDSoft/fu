title(...)

local alacritty_sources = false

dnf_install [[
    rxvt-unicode
    numlockx
    rlwrap
    i3 i3status i3lock dmenu xbacklight feh
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
]]

-- Nerd Fonts
local release = nil
local font_cache_update = false
local function install_font(name, file)
    if FORCE or not fs.is_file(HOME/".local/share/fonts"/file) then
        release = release or read("curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/"):match("tag/(v[%d%.]+)")
        run { "wget", "https://github.com/ryanoasis/nerd-fonts/releases/download"/release/name..".zip", "-c", "-O", FU_PATH/name.."-"..release..".zip" }
        fs.mkdirs(HOME/".local/share/fonts")
        run { "unzip", "-j", "-u", FU_PATH/name.."-"..release..".zip", "'*.ttf'", "-d", HOME/".local/share/fonts/" }
        font_cache_update = true
    end
end
install_font("SourceCodePro", "SauceCodeProNerdFont-Regular.ttf")
install_font("FiraCode", "FiraCodeNerdFont-Regular.ttf")
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
    run { "cd", FU_PATH/"alacritty", "&&", "gzip -c extra/alacritty.man", "|", "sudo tee", HOME/".local/share/man/man1/alacritty.1.gz", "> /dev/null" }
    run { "cd", FU_PATH/"alacritty", "&&", "gzip -c extra/alacritty-msg.man", "|", "sudo tee", HOME/".local/share/man/man1/alacritty-msg.1.gz", "> /dev/null" }
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
            run { "wget", url, "-O", file }
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
if HOSTNAME == "desktop" then
    mime_default "mozilla-thunderbird.desktop"
end
mime_default "atril.desktop"
--mime_default "thunar.desktop"
mime_default "pcmanfm.desktop"
mime_default "ristretto.desktop" -- shall be configured after atril to overload atril associations
mime_default "vlc.desktop"
mime_default "wireshark.desktop"
mime_default "nvim.desktop"

if FORCE or not installed "hsetroot" then
    dnf_install "imlib2-devel libXinerama-devel"
    gitclone "https://github.com/himdel/hsetroot"
    run { "cd", FU_PATH/"hsetroot", "&&", "make", "&&", "DESTDIR="..HOME, "PREFIX=/.local", "make install" }
end

require"sh".write "base64 -d > ~/.config/i3/empty.wav" "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA="

run { "sudo setcap cap_net_admin=ep", read'which i3status' }
