#!/bin/env lua
-- vim: set ts=4 sw=4 foldmethod=marker :

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2020 Christophe Delord
https://github.com/CDSoft/fu

This file is part of Fedora Updater (FU)

FU is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FU is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FU.  If not, see <http://www.gnu.org/licenses/>.
====================================================================--]]

function help()
    printI [[
usage: %(basename(arg[0])) options

    %(basename(arg[0])) installs and configures some softwares I use on
    Linux at home and at work:
    - zsh, fzf, some plugins
    - neovim and some plugins
    - i3 and some personal tools
    - programming languages (Haskell, OCaml, Rust, Julia, Zig, ...)
    - pandoc, LaTeX, ...
    - zoom
    - and much more (Use the source, Luke!)

options:
    -h          help
    -f          force update
    -u          upgrade packages
    -r          reset

hooks:
    ~/.zuser    additional definitions loaded at the end of .zshrc
]]
end

function configuration()

    HOME = os.getenv "HOME"
    USER = os.getenv "USER"

    fu_path = I"%(HOME)/.config/fu"
    config_path = I"%(fu_path)/config"
    repo_path = I"%(fu_path)/repos"
    src_files = dirname(pipe "realpath %(arg[0])").."/files"

    TIMEZONE = "Europe/Paris"
    KEYMAP = "fr"
    LOCALE = "fr_FR.UTF-8"

    FONT = "Source Code Pro"
    FONT_VARIANT = "Medium"
    FONT_SIZE = 10

    BROWSER = "firefox"
    BROWSER2 = cfg_yesno("chrome-as-alternative-browser", "Use Google Chrome as alternative browser?") and "google-chrome" or
               cfg_yesno("edge-as-alternative-browser", "Use Microsoft Edge as alternative browser?") and "microsoft-edge" or
               cfg_yesno("chromium-as-alternative-browser", "Use Chromium as alternative browser?") and "chromium-browser" or
               BROWSER

    LATEST_LTS = "lts-17.12"

    CLING_ARCHIVE = "cling_2020-11-05_ROOT-fedora32.tar.bz2"
    CLING_URL = I"https://root.cern.ch/download/cling/%(CLING_ARCHIVE)"
    CLING_DIR = I"%(CLING_ARCHIVE:gsub('%.tar%.bz2$', ''))"

    DROPBOXINSTALL = 'https://www.dropbox.com/download?plat=lnx.x86_64'

    --EATON_IPP_VERSION = "1.67.162-1"
    --EATON_IPP_URL = I"https://www.eaton.com/content/dam/eaton/products/backup-power-ups-surge-it-power-distribution/power-management-software-connectivity/eaton-intelligent-power-protector/software/ipp-linux-%(EATON_IPP_VERSION).x86_64.rpm"
    EATON_IPP_VERSION = "1.66.161-1"
    EATON_IPP_URL = I"http://pqsoftware.eaton.com/install/linux/ipp/ipp-linux-%(EATON_IPP_VERSION).x86_64.rpm"

end

function main()
    title "Fedora Updater"

    configuration()

    for _, a in ipairs(arg) do
        if a == "-h" then help(); return;
        elseif a == "-f" then force = true; upgrade = true
        elseif a == "-u" then upgrade = true
        elseif a == "-r" then reset()
        else io.stderr:write("Error: Unknown argument: "..a.."\n\n"); help(); return 1
        end
    end

    identification()

    create_directories()

    check_last_upgrade()

    system_configuration()
    if cfg_yesno("rust", "Install Rust?") then rust_configuration() end
    shell_configuration()
    network_configuration()
    if cfg_yesno("dropbox", "Install dropbox?") then dropbox_configuration() end
    if cfg_yesno("nextcloud", "Install Nextcloud?") then nextcloud_configuration() end
    filesystem_configuration()
    dev_configuration()
    if cfg_yesno("haskell", "Install Haskell?") then haskell_configuration() end
    if cfg_yesno("ocaml", "Install OCaml?") then ocaml_configuration() end
    if cfg_yesno("racket", "Install Racket?") then racket_configuration() end
    if cfg_yesno("julia", "Install Julia?") then julia_configuration() end
    if cfg_yesno("zig", "Install Zig?") then zig_configuration() end
    if cfg_yesno("cling", "Install cling?") then cling_configuration() end
    if cfg_yesno("swipl", "Install SWI Prolog (from sources)?") then swipl_configuration() end
    text_edition_configuration()
    pandoc_configuration()
    if cfg_yesno("latex", "Install LaTeX?") then latex_configuration() end
    if cfg_yesno("mdbook", "Install MDBook?") then mdbook_configuration() end
    if cfg_yesno("sphinx", "Install Sphinx?") then sphinx_configuration() end
    neovim_configuration()
    i3_configuration()
    if cfg_yesno("st", "Install Suckless Terminal?") then st_configuration() end
    graphic_application_configuration()
    if cfg_yesno("povray", "Install Povray?") then povray_configuration() end
    internet_configuration()
    if cfg_yesno("zoom", "Install Zoom?") then zoom_configuration() end
    if cfg_yesno("teams", "Install Teams?") then teams_configuration() end
    if cfg_yesno("virtualization", "Install virtualization tools?") then virtualization_configuration() end
    if cfg_yesno("work", "Install work configuration?") then work_configuration() end
    if cfg_yesno("eaton", "Install Eaton Intelligent Power Protector?") then eaton_configuration() end
    if cfg_yesno("radicale", "Install Radicale?") then radicale_configuration() end

    upgrade_packages()

    store_upgrade_date()
end

-- Configuration {{{

function reset()
    sh "rm -rf %(config_path)"
end

function ask_yesno(question)
    local answer = nil
    repeat
        io.write(question.." [y/n] ")
        answer = io.read "l":lower():gsub("^%s*(%S).*$", "%1")
    until answer:match "[yn]"
    return answer:match "y"
end

function ask_string(question)
    local answer = nil
    repeat
        io.write(I(question).." ")
        answer = io.read "l":gsub("^%s+", ""):gsub("%s+$", "")
    until #answer > 0
    return answer
end

function cfg_yesno(param, question)
    local config_file = config_path.."/"..param
    if not file_exist(config_file) then
        local answer = ask_yesno(question) and "y" or "n"
        mkdir(config_path)
        write(config_file, answer)
    end
    local answer = read(config_file):lower():gsub("^%s*(%S).*$", "%1")
    return answer:match "y"
end

function cfg_string(param, question)
    local config_file = config_path.."/"..param
    if not file_exist(config_file) then
        local answer = ask_string(question)
        mkdir(config_path)
        write(config_file, answer)
    end
    local answer = read(config_file):gsub("^%s+", ""):gsub("%s+$", "")
    return answer
end

-- }}}

-- Utilities {{{

function I(s)
    return (s:gsub("%%(%b())", function(x)
        return (assert(load("return "..x)))()
    end))
end

function dedent(s)
    local n = #s
    for line in s:gmatch("[^\n]*") do
        if not line:match "^%s*$" then
            local indent = line:match "^%s*"
            n = math.min(n, #indent)
        end
    end
    local lines = {}
    for line in s:gmatch("[^\n]*") do
        if line:match "^%s*$" then line = "" end
        table.insert(lines, line:sub(n+1))
    end
    return table.concat(lines, "\n") .. "\n"
end

function set(init)
    local set = {}
    local ordered = {}
    local self = {}
    function self.len() return #ordered end
    function self.add(item)
        item:gsub("%S+", function(name)
            if set[name] == nil then
                set[name] = true
                table.insert(ordered, name)
            end
        end)
    end
    function self.ipairs() return ipairs(ordered) end
    function self.has(name)return set[name] end
    function self.concat(sep) return table.concat(ordered, sep) end
    if init then self.add(init) end
    return self
end

function printI(s)
    print(I(s))
end

function title(s)
    local cols = pipe "tput cols"
    local color = string.char(27).."[1m"..string.char(27).."[37m"..string.char(27).."[44m"
    local normal = string.char(27).."[0m"
    s = I(s)
    io.write(string.char(27).."]0;fu: "..s..string.char(7)) -- windows title
    s = s .. string.rep(" ", cols - #s - 4)
    io.write(color.."### "..s..normal.."\n")
end

function log(s)
    local color = string.char(27).."[0m"..string.char(27).."[30m"..string.char(27).."[46m"
    local normal = string.char(27).."[0m"
    s = I(s)
    io.write(color.."### "..s.." "..normal.."\n")
end

function dirname(s)
    return (I(s):gsub("[^/]*$", ""))
end

function basename(s)
    return (I(s):gsub(".*/([^/]*)$", "%1"))
end

function file_exist(path) return (os.execute("test -f "..I(path))) end
function dir_exist(path) return (os.execute("test -d "..I(path))) end
function link_exist(path) return (os.execute("test -L "..I(path))) end

function read(path)
    local f = assert(io.open(I(path), "r"))
    local content = f:read "a"
    f:close()
    return I(content)
end

function write(path, content)
    local f = assert(io.open(I(path), "w"))
    f:write(I(content))
    f:close()
end

function rootfile(path, content)
    with_tmpfile(function(tmp)
        write(tmp, content)
        path = I(path)
        sh("sudo cp "..tmp.." "..path)
        sh("sudo chmod 644 "..path)
        sh("sudo chown root:root "..path)
    end)
end

function readlines(path)
    local f = assert(io.open(I(path), "r"))
    return function()
        local line = f:read "l"
        if line then return line end
        f:close()
    end
end

function pipe(cmd, stdin)
    local mode = stdin and "w" or "r"
    local f = io.popen(I(cmd), mode)
    if stdin then
        f:write(I(stdin))
        f:close()
    else
        local result = f:read "a":gsub("^%s+", ""):gsub("%s+$", "")
        f:close()
        return I(result)
    end
end

function ls(pattern)
    local files = dirname(pipe "realpath %(arg[0])").."/files/"
    local p = io.popen("ls "..files..I(pattern))
    return function()
        local name = p:read "l"
        if name then return name:sub(#files+1) end
        p:close()
    end
end

function with_tmpfile(f)
    local tmp = os.tmpname()
    f(tmp)
    os.remove(tmp)
end

function with_tmpdir(f)
    local tmp = os.tmpname()
    os.remove(tmp)
    sh("mkdir "..tmp)
    f(tmp)
    sh("rm -rf "..tmp)
end

function sh(cmd) assert(os.execute(I(cmd))) end

function mkdir(path) sh("mkdir -p "..path) end

function rm(path) os.remove(I(path)) end

function identification()
    MYHOSTNAME = cfg_string("hostname", "Hostname:")
    RELEASE = pipe "rpm -E %fedora"
    log "release : Fedora %(RELEASE)"
    log "hostname: %(MYHOSTNAME)"
end

function repo(local_name, name)
    if not file_exist(I(local_name)) then
        name = I(name)
        log("Install repo "..name)
        sh("sudo dnf install -y \""..name.."\"")
    end
end

function copr(local_name, name)
    if not file_exist(local_name) then
        name = I(name)
        log("Install copr "..name)
        sh("sudo dnf copr enable \""..name.."\"")
    end
end

function packages(names)
    names = I(names)
    local all = set(names)
    local new_packages = set(names)
    local already_installed = set()
    if file_exist "%(config_path)/packages" then
        local old_names = read "%(config_path)/packages"
        already_installed.add(old_names)
        all.add(old_names)
    end
    local new = false
    for _, name in new_packages.ipairs() do
        new = new or not already_installed.has(name)
    end
    if new then
        names = new_packages.concat " "
        log("Install packages: "..names)
        sh("sudo dnf install "..names.." --skip-broken --best --allowerasing")
        write("%(config_path)/packages", all.concat("\n").."\n")
    end
end

function luarocks(names)
    names = I(names)
    local all = set(names)
    local new_packages = set(names)
    local already_installed = set()
    if file_exist "%(config_path)/luarocks" then
        local old_names = read "%(config_path)/luarocks"
        already_installed.add(old_names)
        all.add(old_names)
    end
    local new = force or upgrade
    for _, name in new_packages.ipairs() do
        new = new or not already_installed.has(name)
    end
    if new then
        names = new_packages.concat " "
        log("Install luarocks: "..names)
        for _, name in new_packages.ipairs() do
            sh("luarocks install --local "..name)
        end
        write("%(config_path)/luarocks", all.concat("\n").."\n")
    end
end

function upgrade_packages()
    if force or upgrade then
        title "Upgrade packages"
        sh "sudo dnf upgrade --best --allowerasing"
    end
end

function installed(cmd)
    local found = (os.execute("hash "..I(cmd).." 2>/dev/null"))
    return found
end

function script(name)
    local function template(file_name, dest_name, exe)
        if file_exist(file_name) then
            log("Create "..dest_name)
            mkdir(dirname(dest_name))
            write(dest_name, read(file_name))
            if exe then sh("chmod +x "..dest_name) end
            return true
        end
    end
    name = I(name)
    if template(src_files.."/"..name, HOME.."/"..name) then return end
    if template(src_files.."/.local/bin/"..name, HOME.."/.local/bin/"..name, true) then return end
    error("Template not found: "..name)
end

function gitclone(url, options)
    url = I(url)
    local name = basename(url)
    options = table.concat(options or {}, " ")
    mkdir(repo_path)
    local path = repo_path.."/"..name:gsub("%.git$", "")
    if dir_exist(path) then
        if force or upgrade then
            log("Upgrade "..url.." to "..path.." "..options)
            sh("cd "..path.." && git reset --hard master && git pull")
        end
    else
        log("Clone "..url.." to "..path)
        sh("git clone "..url.." "..path.." "..options)
    end
end

function mime_default(desktop_file)
    desktop_file = I(desktop_file)
    local config_flag = I("%(config_path)/"..desktop_file..".already_configured")
    local path = "/usr/share/applications/"..desktop_file
    if file_exist(path) and (force or upgrade or not file_exist(config_flag)) then
        read(path):gsub("MimeType=([^\n]*)", function(mimetypes)
            mimetypes:gsub("[^;]+", function(mimetype)
                sh("xdg-mime default "..desktop_file.." "..mimetype)
            end)
        end)
        sh("touch "..config_flag)
    end
end

-- }}}

-- Create fu directories {{{

function create_directories()
    mkdir "%(HOME)/.local/bin"
    mkdir "%(HOME)/.local/opt"
    mkdir "%(config_path)"
    mkdir "%(repo_path)"
end

-- }}}

-- Force upgrade when the last upgrade is too old {{{

function check_last_upgrade()
    if not upgrade then
        title "Check last upgrade"

        if file_exist "%(config_path)/last_upgrade" then
            local last_upgrade = tonumber(pipe "date +%s -r %(config_path)/last_upgrade")
            local now = tonumber(pipe "date +%s")
            outdated = now - last_upgrade > 15*86400
        else
            outdated = true
        end
        if outdated then
            upgrade = ask_yesno "The last upgrade is too old. Force upgrade now?"
        end
    end
end

function store_upgrade_date()
    if upgrade then
        sh "touch %(config_path)/last_upgrade"
    end
end

-- }}}

-- System packages {{{

function system_configuration()
    title "System configuration"

    repo("/etc/yum.repos.d/rpmfusion-free.repo", "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%(RELEASE).noarch.rpm")
    repo("/etc/yum.repos.d/rpmfusion-nonfree.repo", "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%(RELEASE).noarch.rpm")

    packages [[
        dnf-plugins-core dnfdragora
        fedora-workstation-repositories
    ]]

    -- Locale and timezone
    sh "sudo timedatectl set-timezone %(TIMEZONE)"
    sh "sudo localectl set-keymap %(KEYMAP)"
    sh "sudo localectl set-locale %(LOCALE)"

    -- No more poweroff
    sh "sudo sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf"
end

-- }}}

-- Shell configuration {{{

function shell_configuration()
    title "Shell configuration"

    packages [[
        zsh
        powerline-fonts
        grc bat fzf
        PackageKit-command-not-found
        util-linux-user
        inotify-tools
        htop
        pwgen
        ripgrep
        exa
        fd-find
        tmux
        tldr
        procs
        the_silver_searcher
    ]]

    sh "chsh -s /bin/zsh %(USER)"

    script ".zprofile"
    script ".zshrc"

    script ".config/starship.toml"

    gitclone "https://github.com/ohmyzsh/ohmyzsh.git" -- not installed, some scripts will be sourced
    gitclone "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    gitclone "https://github.com/zsh-users/zsh-autosuggestions"
    if force or not installed "starship" then
        -- The binary downloaded by install.sh is buggy (crashes on non existing directory)
        -- If Rust is installed, building from sources is better.
        if cfg_yesno("rust", "Install Rust?") then
            gitclone "https://github.com/starship/starship.git"
            sh "cd %(repo_path)/starship && ~/.cargo/bin/cargo install --force --path . --root ~/.local"
        else
            with_tmpfile(function(tmp)
                sh("curl -fsSL https://starship.rs/install.sh -o "..tmp.." && bash "..tmp.." -f -b ~/.local/bin")
            end)
        end
    end

    script "vi"

    gitclone "https://github.com/junegunn/fzf.git"
    sh "cd %(repo_path)/fzf && ./install --key-bindings --completion --no-update-rc"

    script ".tmux/conf"

    script "fzfmenu"

end

-- }}}

-- Network configuration {{{

function network_configuration()
    title "Network configuration"

    packages [[
        nmon
        openssh openssh-server
        nmap
        blueman
        network-manager-applet NetworkManager-tui
        socat
        sshpass
        minicom
        wireshark
        tigervnc
        can-utils
        openvpn
        telnet
        curl
        wget
    ]]

    -- hostname
    sh "sudo hostname %(MYHOSTNAME)"
    rootfile("/etc/hostname", "%(MYHOSTNAME)\n")

    -- ssh
    sh "sudo systemctl start sshd"
    sh "sudo systemctl enable sshd"
    sh "sudo systemctl disable firewalld" -- firewalld fails to stop during shutdown.
    script "ssha"

    -- sshd
    sh "sudo chkconfig sshd on"
    sh "sudo service sshd start"

    -- wireshark
    sh "sudo usermod -a -G wireshark %(USER)"

    -- Google Drive
    if force or upgrade then
        sh "pip install --user --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib"
    end

end

-- }}}

-- Dropbox configuration {{{

function dropbox_configuration()

    packages [[ PyQt4 libatomic ]]

    if force or not file_exist "%(HOME)/.dropbox-dist/dropboxd" then
        title "Dropbox configuration"
        sh "rm -rf ~/.dropbox-dist"
        sh "cd ~ && wget -O - %(DROPBOXINSTALL) | tar xzf -"
    end

end

-- }}}

-- Nextcloud configuration {{{

function nextcloud_configuration()

    local installed = file_exist "%(HOME)/.local/bin/Nextcloud"
    if force or upgrade or not file_exist "%(HOME)/.local/bin/Nextcloud" then
        title "Nextcloud configuration"
        local version, new_version
        if installed then
            version = pipe("%(HOME)/.local/bin/Nextcloud -v"):match("version%s+([%d%.]+)")
        end
        new_version = pipe("curl -s https://github.com/nextcloud/desktop/releases/latest/"):match("tag/v([%d%.]+)")
        if new_version ~= version then
            if version then sh("%(HOME)/.local/bin/Nextcloud -q") end
            sh("wget https://github.com/nextcloud/desktop/releases/download/v"..new_version.."/Nextcloud-"..new_version.."-x86_64.AppImage -O %(HOME)/.local/bin/Nextcloud")
            sh("chmod +x %(HOME)/.local/bin/Nextcloud")
        end
    end

end

-- }}}

-- Filesystem configuration {{{

function filesystem_configuration()
    title "Filesystem configuration"

    copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:fcsm:cryfs.repo", "fcsm/cryfs")

    packages [[
        gparted
        udftools
        encfs
        cryfs
        p7zip p7zip-gui p7zip-plugins
        mc pcmanfm thunar
        vifm
        pmount
        exfat-utils fuse-exfat
        syslinux
        backintime-common backintime-qt4
        timeshift
        cryptsetup
        squashfs-tools squashfuse
        baobab ncdu qdirstat
        xz unrar
        archivemount fuseiso sshfs curlftpfs fuse-7z
    ]]

    gitclone "https://github.com/vifm/vifm-colors"
    script ".config/vifm/vifmrc"
    mkdir "%(HOME)/.config/vifm/colors"
    sh "cp %(repo_path)/vifm-colors/*.vifm %(HOME)/.config/vifm/colors/"

end

-- }}}

-- Development environment configuration {{{

function dev_configuration()
    title "Development environment configuration"

    if cfg_yesno("R", "Install R?") then packages [[ R ]] end

    packages [[
        git git-gui gitk qgit gitg tig git-lfs
        git-delta
        subversion
        clang llvm clang-tools-extra
        ccls
        cppcheck
        cmake
        ncurses-devel
        readline-devel
        meld
        pl pl-xpce pl-devel
        libev-devel startup-notification-devel xcb-util-devel xcb-util-cursor-devel xcb-util-keysyms-devel xcb-proto xcb-util-wm-devel xcb-util-xrm-devel libxkbcommon-devel libxkbcommon-x11-devel yajl-devel
        arm-none-eabi-gcc arm-none-eabi-gcc-cs-c++ arm-none-eabi-gdb
        mingw64-gcc
        gcc-gnat
        python-pip
        pypy
        lua lua-filesystem lua-fun lua-lpeg lua-posix lua-socket luajit
        luarocks
        lua-devel
        glfw
        flex bison
        perl-ExtUtils-MakeMaker
        SDL2-devel SDL2_ttf-devel SDL2_gfx-devel
        libpcap-devel
        libyaml libyaml-devel
        libubsan libubsan-static libasan libasan-static libtsan libtsan-static
        expect
        python3-devel
        python3-PyYAML python3-termcolor
        pkgconfig
        boost boost-devel
        libjpeg-turbo-devel libpng-devel libtiff-devel
        npm
        liblzma-devel
        protobuf-devel python3-protobuf
        lzma-devel xz-devel zlib-devel
        blas-devel lapack-devel
        gnuplot
        openssl-devel
        tokei
        golang
        libX11-devel
        libXft-devel
        octave
        libcurl-devel
        libicu-devel ncurses-devel zlib-devel
        libstdc++-static
    ]]

    luarocks [[
        ansicolors
        bigint
        cprint
        fun
        lcomplex
        lpeg
        lua-basex
        lua-cURL
        luafilesystem
        lua_fun
        lua-gnuplot
        lua-protobuf
        luarepl
        luasocket
        lua-term
        lua-toml
        lua-yaml
        lyaml
        map
        optparse
        penlight
        stdlib
        tcc
    ]]

    script ".gitconfig"

    -- pip
    if force or upgrade then sh "python -m pip install --user --upgrade pip" end

    -- git
    -- https://stackoverflow.com/questions/34119866/setting-up-and-using-meld-as-your-git-difftool-and-mergetool
    -- use git meld to call git difftool with meld
    sh "git config --global alias.meld '!git difftool -t meld --dir-diff'"
    sh "git config --global core.excludesfile ~/.gitignore"

    -- PMcCabe
    if force or upgrade or not installed "pmccabe" then
        gitclone "https://github.com/datacom-teracom/pmccabe"
        sh "cd %(repo_path)/pmccabe && make && cp pmccabe ~/.local/bin"
    end

    -- interactive scratchpad: https://github.com/metakirby5/codi.vim
    script "codi"

    -- Language servers
    if force or upgrade or not file_exist "%(HOME)/.local/opt/bash-language-server/node_modules/.bin/bash-language-server" then
        mkdir "%(HOME)/.local/opt/bash-language-server"
        sh "cd ~/.local/opt/bash-language-server && npm install bash-language-server && ln -s -f $PWD/node_modules/.bin/bash-language-server ~/.local/bin/"
    end
    if force or upgrade or not file_exist "%(HOME)/.local/opt/dot-language-server/node_modules/.bin/dot-language-server" then
        mkdir "%(HOME)/.local/opt/dot-language-server"
        sh "cd ~/.local/opt/dot-language-server && npm install dot-language-server && ln -s -f $PWD/node_modules/.bin/dot-language-server ~/.local/bin/"
    end
    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "haskell-language-server" then
            gitclone("https://github.com/haskell/haskell-language-server", {"--recurse-submodules"})
            sh "cd %(repo_path)/haskell-language-server && stack ./install.hs hls"
        end
    end
    if force or upgrade or not installed "zls" then
        mkdir "%(HOME)/.local/opt/pyright-langserver"
        sh "cd ~/.local/opt/pyright-langserver && npm install pyright && ln -s -f $PWD/node_modules/.bin/pyright-langserver ~/.local/bin/"
    end
    if cfg_yesno("zig", "Install Zig?") then
        if force or upgrade or not installed "zls" then
            gitclone("https://github.com/zigtools/zls", {"--recurse-submodules"})
            sh [[ cd %(repo_path)/zls &&
                git fetch origin b756ed4da59cb0ec419a4010ab6f870c1924924f &&
                git reset --hard FETCH_HEAD &&
                zig build -Drelease-safe &&
                ln -s -f $PWD/zig-out/bin/zls ~/.local/bin/ ]]
        end
    end
    if force or upgrade or not installed "lua-language-server" then
        gitclone("https://github.com/sumneko/lua-language-server", {"--recurse-submodules"})
        sh [[ cd %(repo_path)/lua-language-server &&
              cd 3rd/luamake
              compile/install.sh
              cd ../..
              ./3rd/luamake/luamake rebuild
              ln -s -f $PWD/bin/Linux/lua-language-server ~/.local/bin/ ]]
    end

end

-- }}}

-- Haskell configuration {{{

function haskell_configuration()
    title "Haskell configuration"

    if cfg_yesno("haskell-platform", "Install haskell-platform?") then packages [[ haskell-platform ]] end

    if not installed "stack" then
        sh "curl -sSL https://get.haskellstack.org/ | sh"
    elseif force or upgrade then
        sh "stack upgrade"
    end

    local RESOLVER = LATEST_LTS
    local HASKELL_PACKAGES = {
        "hasktags",
        "hlint",
        "hoogle",
        "matplotlib",
        "gnuplot",
        "parallel",
        "MissingH",
        "timeit",
    }
    if force or upgrade then
        for _, package in ipairs(HASKELL_PACKAGES) do
            sh("stack install --resolver="..RESOLVER.." "..package)
        end
    end

    -- hCalc
    if force or upgrade or not installed "hcalc" then
        gitclone "http://github.com/cdsoft/hcalc"
        sh "cd %(repo_path)/hcalc && make install"
    end

end

-- }}}

-- OCaml configuration {{{

function ocaml_configuration()

    packages [[
        z3
        cvc4
    ]]

    if force or not installed "opam" then
        title "OCaml configuration"
        sh "wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin"
        sh "opam init"
        sh "opam update && opam upgrade"
        sh "opam install depext"
        sh "opam depext frama-c || true"
        sh "opam install frama-c coq why3 alt-ergo || true"
    end

end

-- }}}

-- Racket configuration {{{

function racket_configuration()

    if force or not installed "racket" then

        title "Racket configuration"

        RACKET_URL = "https://download.racket-lang.org/"

        local index = pipe("curl -sSL %(RACKET_URL)")
        RACKETINST = nil
        index:gsub([["([0-9.]+/(racket%-[0-9.]+)%-x86_64%-linux%-cs%.sh)"]], function(path, name)
            if not RACKETINST then
                RACKETINST = "https://mirror.racket-lang.org/installers/"..path
                RACKET_NAME = name
            end
        end)
        assert(RACKETINST and RACKET_NAME, "Can not determine the Racket version")

        sh "wget %(RACKETINST) -c -O ~/.local/opt/%(basename(RACKETINST))"
        sh "sh ~/.local/opt/%(basename(RACKETINST)) --in-place --dest ~/.local/opt/%(RACKET_NAME)"
        sh "ln -f -s ~/.local/opt/%(RACKET_NAME)/bin/racket ~/.local/bin/racket"

    end

end

-- }}}

-- Rust configuration {{{

function rust_configuration()

    if not installed "rustc" then
        title "Rust configuration"
        with_tmpfile(function(tmp)
            sh("curl https://sh.rustup.rs -sSf -o "..tmp.." && sh "..tmp.." -y -v --no-modify-path")
        end)
        sh "PATH=$PATH:$HOME/.cargo/bin rustup update stable"
    elseif force or upgrade then
        title "Rust configuration"
        sh "rustup update stable"
    end

    local RUST_PACKAGES = {
    }
    for _, package in ipairs(RUST_PACKAGES) do
        if force or not installed(package) then
            sh("~/.cargo/bin/cargo install %(force and '--force' or '') "..package)
        end
    end

end

-- }}}

-- Julia configuration {{{

function julia_configuration()

    if force or not installed "julia" then

        title "Julia configuration"

        JULIA_URL = "https://julialang.org/downloads/"

        local index = pipe("curl -sSL %(JULIA_URL)")
        JULIA_ARCHIVE = nil
        index:gsub([[href="(https://julialang%-s3%.julialang%.org/bin/linux/x64/[0-9.]+/(julia%-[0-9.]+)%-linux%-x86_64%.tar%.gz)"]], function(path, name)
            if not JULIA_ARCHIVE then
                JULIA_ARCHIVE = path
                JULIA_NAME = name
            end
        end)
        assert(JULIA_ARCHIVE and JULIA_NAME, "Can not determine the Julia version")

        sh "wget %(JULIA_ARCHIVE) -c -O ~/.local/opt/%(basename(JULIA_ARCHIVE))"
        sh "rm -rf ~/.local/opt/%(JULIA_NAME)"
        sh "tar xzf ~/.local/opt/%(basename(JULIA_ARCHIVE)) -C ~/.local/opt"
        sh "ln -f -s ~/.local/opt/%(JULIA_NAME)/bin/julia ~/.local/bin/julia"
    end

end

-- }}}

-- Zig configuration {{{

function zig_configuration()

    --package "zig"

    if force or not installed "zig" then

        title "Zig configuration"

        ZIG_URL = "https://ziglang.org/download/"

        local index = pipe("curl -sSL %(ZIG_URL)")
        ZIG_ARCHIVE = nil
        index:gsub([[(https://ziglang%.org/download/[0-9.]+/(zig%-linux%-x86_64%-[0-9.]+)%.tar%.xz)]], function(url, name)
            if not ZIG_ARCHIVE then
                ZIG_ARCHIVE = url
                ZIG_DIR = name
            end
        end)
        assert(ZIG_ARCHIVE and ZIG_DIR, "Can not determine Zig version")

        sh "wget %(ZIG_ARCHIVE) -c -O ~/.local/opt/%(basename(ZIG_ARCHIVE))"
        sh "rm -rf ~/.local/opt/%(ZIG_DIR)"
        sh "tar xJf ~/.local/opt/%(basename(ZIG_ARCHIVE)) -C ~/.local/opt"
        sh "ln -f -s ~/.local/opt/%(ZIG_DIR)/zig ~/.local/bin/zig"
    end

end

-- }}}

-- Cling configuration {{{

function cling_configuration()

    if force or not installed "cling" then
        title "Cling configuration"

        sh "wget %(CLING_URL) -c -O ~/.local/opt/%(basename(CLING_URL))"
        sh "rm -rf ~/.local/opt/%(CLING_DIR)"
        sh "tar xjf ~/.local/opt/%(basename(CLING_URL)) -C ~/.local/opt"
        sh "ln -f -s ~/.local/opt/%(CLING_DIR)/bin/cling ~/.local/bin/cling"
    end

end

-- }}}

-- SWI Prolog {{{

function swipl_configuration()

    if force or not file_exist "%(HOME)/.local/bin/swipl" then
        title "SWI Prolog configuration"

        -- https://www.swi-prolog.org/build/unix.html
        packages [[
            cmake
            ninja-build
            libunwind
            gperftools-devel
            freetype-devel
            gmp-devel
            java-1.8.0-openjdk-devel
            java-11-openjdk-devel
            jpackage-utils
            libICE-devel
            libjpeg-turbo-devel
            libSM-devel
            libX11-devel
            libXaw-devel
            libXext-devel
            libXft-devel
            libXinerama-devel
            libXmu-devel
            libXpm-devel
            libXrender-devel
            libXt-devel
            ncurses-devel
            openssl-devel
            pkgconfig
            readline-devel
            libedit-devel
            unixODBC-devel
            zlib-devel
            uuid-devel
            libarchive-devel
            libyaml-devel
        ]]
        gitclone "https://github.com/SWI-Prolog/swipl-devel.git"
        sh "cd %(repo_path)/swipl-devel && git submodule update --init"
        mkdir "%(repo_path)/swipl-devel/build"
        sh "cd %(repo_path)/swipl-devel/build && cmake -DCMAKE_INSTALL_PREFIX=%(HOME)/.local -G Ninja .. && ninja && ninja install"
    end

end

-- }}}

-- Text edition configuration {{{

function text_edition_configuration()
    title "Text edition configuration"

    packages [[
        wkhtmltopdf
        aspell-fr aspell-en
        figlet
        translate-shell
        doxygen
        gnuplot
        graphviz plantuml
    ]]

end

-- }}}

-- Pandoc configuration {{{

function pandoc_configuration()
    title "Pandoc configuration"

    packages [[
        pandoc
        patat
        asymptote
    ]]

    if force or upgrade or not installed "panda" then
        gitclone "http://github.com/cdsoft/panda"
        sh "cd %(repo_path)/panda && make install"
    end

    if force or upgrade or not installed "upp" then
        gitclone "http://github.com/cdsoft/upp"
        sh "cd %(repo_path)/upp && make install"
    end

    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "abp" then
            gitclone "http://github.com/cdsoft/abp"
            sh "cd %(repo_path)/abp && stack install"
        end
    end

    if cfg_yesno("haskell", "Install Haskell?") and cfg_yesno("pp", "Install pp?") then
        if force or upgrade or not installed "pp" then
            gitclone "http://github.com/cdsoft/pp"
            sh "cd %(repo_path)/pp && make install"
        end
    end

    if force or not file_exist "%(HOME)/.local/bin/plantuml.jar" then
        sh "wget http://sourceforge.net/projects/plantuml/files/plantuml.jar -O ~/.local/bin/plantuml.jar"
    end

    if force or not file_exist "%(HOME)/.local/bin/ditaa.jar" then
        sh "wget https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar -O ~/.local/bin/ditaa.jar"
    end

    if force or upgrade or not installed "blockdiag" then
        sh "pip3 install --user blockdiag seqdiag actdiag nwdiag"
    end

    if force or upgrade or not file_exist "%(HOME)/.local/opt/mermaid/node_modules/.bin/mmdc" then
        mkdir "%(HOME)/.local/opt/mermaid"
        sh "cd ~/.local/opt/mermaid && npm install mermaid.cli && ln -s -f $PWD/node_modules/.bin/mmdc ~/.local/bin/"
    end

end

-- }}}

-- LaTeX configuration {{{

function latex_configuration()
    title "LaTeX configuration"

    packages [[
        texlive texlive-scheme-full
        graphviz plantuml asymptote
    ]]

end

-- }}}

-- MDBook configuration {{{

function mdbook_configuration()
    title "MDBook configuration"

    local MDBOOK_PACKAGES = {
        "mdbook",
        "mdbook-toc",
        "mdbook-latex",
        "mdbook-plantuml",
        "mdbook-mermaid",
        "mdbook-checklist",
        "mdbook-presentation-preprocessor",
    }
    for _, package in ipairs(MDBOOK_PACKAGES) do
        if force or not installed(package) then
            sh("~/.cargo/bin/cargo install %(force and '--force' or '') "..package)
        end
    end
end

-- }}}

-- Sphinx configuration {{{

function sphinx_configuration()

    if force or upgrade or not installed "sphinx-build" then
        title "Sphinx configuration"
        sh [[ pip3 install '--user'         \
                    sphinx==2.4.4           \
                    sphinxcontrib-plantuml  \
                    breathe                 \
                    recommonmark            \
                    sphinx-rtd-theme        \
                    pyaml                   \
                    scipy                   \
                    matplotlib              \
        ]]
    end

end

-- }}}

-- neovim configuration {{{

function neovim_configuration()
    title "neovim configuration"

    packages [[
        neovim
        fzf
        ccrypt pwgen
        gzip
    ]]

    for config_file in ls ".config/nvim/*.vim" do
        script(config_file)
    end
    for config_file in ls ".config/nvim/vim/*.vim" do
        script(config_file)
    end
    for config_file in ls ".config/nvim/lua/*.lua" do
        script(config_file)
    end

    -- vim-plug
    gitclone "https://github.com/junegunn/vim-plug.git"
    mkdir "%(HOME)/.config/nvim/autoload"
    sh "cp %(repo_path)/vim-plug/plug.vim %(HOME)/.config/nvim/autoload/"

    -- Asymptote syntax
    if file_exist "/usr/share/asymptote/asy.vim" and file_exist "/usr/share/asymptote/asy_filetype.vim" then
        mkdir "%(HOME)/.config/nvim/syntax"
        mkdir "%(HOME)/.config/nvim/ftdetect"
        sh "cp /usr/share/asymptote/asy.vim ~/.config/nvim/syntax/"
        sh "cp /usr/share/asymptote/asy_filetype.vim ~/.config/nvim/ftdetect/asy.vim"
    end

    -- update all plugins
    if force or upgrade then
        sh "nvim -c PlugUpgrade -c PlugInstall -c PlugUpdate -c qa"
        sh 'nvim --headless "+call firenvim#install(0) | q"'
    end

    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "shellcheck" then
            sh "stack install --resolver=lts-14.27 ShellCheck"
        end
    end

end

-- }}}

-- i3 configuration {{{

function i3_configuration()
    title "i3 configuration"

    packages [[
        rxvt-unicode
        alacritty
        numlockx
        rlwrap
        i3 i3status i3lock dmenu xbacklight feh
        i3-ipc
        arandr
        sox
        fortune-mod ImageMagick
        st sxiv ristretto
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
        xfce4-settings
        xfce4-screenshooter
        xsetroot
        xfce4-notifyd
        xfce4-volumed
    ]]

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
    if cfg_yesno("thunderbird-mailer", "Use Thunderbird as the default mailer?") then
        mime_default "mozilla-thunderbird.desktop"
    end
    --mime_default "org.pwmt.zathura-djvu.desktop"
    --mime_default "org.pwmt.zathura-pdf-poppler.desktop"
    --mime_default "org.pwmt.zathura-ps.desktop"
    mime_default "xreader.desktop"
    mime_default "thunar.desktop"
    mime_default "ristretto.desktop" -- shall be configured after xreader to overload xreader associations
    mime_default "vlc.desktop"
    mime_default "wireshark.desktop"

    script ".config/alacritty/alacritty.yml"

    script ".config/i3/config"

    script ".config/dunst/dunstrc"

    script ".config/rofi/config.rasi"

    script "xi3"

    if force or upgrade or not installed "xcwd" then
        gitclone "https://github.com/schischi-a/xcwd.git"
        -- patch to reject "/"
        local xcwd = read "%(repo_path)/xcwd/xcwd.c"
        xcwd = xcwd:gsub('%(%s*access%s*%(%s*([%w->]+)%s*,%s*F_OK%s*%)%s*%)', I'(access(%1, F_OK) != 0 || strcmp(%1, "/") == 0)')
        write("%(repo_path)/xcwd/xcwd.c", xcwd)
        sh "cd %(repo_path)/xcwd && make && sudo make install"
    end

    pipe("base64 -d > ~/.config/i3/empty.wav", "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=")

    script ".config/i3/status"
    sh "sudo setcap cap_net_admin=ep %(pipe 'which i3status')"

    script "lock"

    script "screenshot"

    script "menu"
    script "idle"

    script "brightness"
    script "notify_volume"

    script ".config/volumeicon/volumeicon"

    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "tt" then
            gitclone "http://github.com/CDSoft/tt"
            sh "cd %(repo_path)/tt && make"
        end
    end

    -- start VLC in a single instance
    if file_exist "%(HOME)/.config/vlc/vlcrc" then
        local vlcrc = read "%(HOME)/.config/vlc/vlcrc"
        vlcrc = vlcrc:gsub('#?one%-instance=[01]', "one-instance=1")
        write("%(HOME)/.config/vlc/vlcrc", vlcrc)
    end

end

-- }}}

-- Suckless simple terminal configuration {{{

function st_configuration()
    title "st configuration"

    if force or upgrade or not file_exist "%(HOME)/.local/bin/st" then
        gitclone "git://git.suckless.org/st"
        local config = read "%(repo_path)/st/config.def.h"
        config = config:gsub([[font = ".-";]], I[[font = "%(FONT) %(FONT_VARIANT):size=%(FONT_SIZE):antialias=true:autohint=true";]])
        write("%(repo_path)/st/config.h", config)
        sh "cd %(repo_path)/st && make && cp st %(HOME)/.local/bin/"
    end
end

-- }}}

-- Graphic applications configuration {{{

function graphic_application_configuration()
    title "Graphic applications configuration"

    packages [[
        shutter feh gimp ImageMagick scribus inkscape
        qt5-qtx11extras
        gnuplot
        qrencode
        libreoffice libreoffice-langpack-fr libreoffice-help-fr
        vokoscreenNG
        simple-scan
        evince okular mupdf qpdfview
        zathura zathura-plugins-all
        xreader

        vlc ffmpeg
        gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras
    ]]

    script ".config/zathura/zathurarc"

end

-- }}}

-- Povray configuration {{{

function povray_configuration()
    title "Povray configuration"

    if force or not installed "povray" then
        gitclone "https://github.com/pov-ray/povray.git"
        sh "cd %(repo_path)/povray/unix && ./prebuild.sh"
        sh [[cd %(repo_path)/povray/ && ./configure '--prefix'="$(realpath ~/.local)" compiled_by="christophe delord <http://cdelord.fr>"]]
        sh "cd %(repo_path)/povray/ && make check install"
    end
end

-- }}}

-- Internet configuration {{{

function internet_configuration()
    title "Internet configuration"

    packages [[
        firefox
        surf
        thunderbird
        transmission
    ]]

    if cfg_yesno("chrome", "Install Google Chrome?") then
        sh "sudo dnf config-manager --set-enabled google-chrome"
        packages "google-chrome-stable"
    end
    if cfg_yesno("chromium", "Install Chromium?") then
        packages "chromium"
    end
    if cfg_yesno("edge", "Install Microsoft Edge?") then
        -- https://www.microsoftedgeinsider.com/en-us/download/
        sh "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        sh "sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge"
        sh "sudo mv -f /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-beta.repo"
        packages "microsoft-edge-beta"
    end

    -- Default browser
    sh "BROWSER= xdg-settings set default-web-browser %(BROWSER).desktop"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop text/html"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/http"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/https"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/about"

    -- Firefox configuration
    -- https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
    -- https://askubuntu.com/questions/239543/get-the-default-firefox-profile-directory-from-bash
    for line in readlines("%(HOME)/.mozilla/firefox/profiles.ini") do
        for profile in line:gmatch("Path=(.*)") do
            write("%(HOME)/.mozilla/firefox/"..profile.."/user.js", read "%(src_files)/user.js")
        end
    end

    -- Thunderbird extensions
    if force or upgrade or not file_exist "%(repo_path)/reply_as_original_recipient.xpi" then
        gitclone "https://github.com/qiqitori/reply_as_original_recipient.git"
        sh "cd %(repo_path)/reply_as_original_recipient && zip -r ../reply_as_original_recipient.xpi *"
    end

    -- Remove unecessary language symlinks
    sh "sudo find /usr/share/myspell -type l -exec rm -v {} \\;"

end

-- }}}

-- Zoom configuration {{{

function zoom_configuration()
    title "Zoom configuration"

    if force or not installed "zoom" then
        with_tmpdir(function(tmp)
            sh("wget https://zoom.us/client/latest/zoom_x86_64.rpm -O "..tmp.."/zoom_x86_64.rpm")
            sh("sudo dnf install "..tmp.."/zoom_x86_64.rpm")
            mime_default "Zoom.desktop"
        end)
    end

end

-- }}}

-- Teams configuration {{{

function teams_configuration()

    if force or not installed "teams" then

        title "Teams configuration"

        TEAMS_URL = "https://packages.microsoft.com/yumrepos/ms-teams"

        local index = pipe("curl -sSL %(TEAMS_URL)")
        local version = ""
        local latest = nil
        index:gsub([["(teams%-([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)%-([0-9]+)%.x86_64%.rpm)"]], function(n, a, b, c, d, e)
            local v = ("%5s.%5s.%5s.%10s-%5s"):format(a,b,c,d,e)
            if v > version then version, latest = v, n end
        end)
        assert(latest, "Can not determine the latest Teams version")

        TEAMS_URL = TEAMS_URL.."/"..latest
        sh "wget %(TEAMS_URL) -c -O ~/.local/opt/%(basename(TEAMS_URL))"
        sh "sudo dnf install ~/.local/opt/%(basename(TEAMS_URL))"
        mime_default "teams.desktop"

    end

end

-- }}}

-- Virtualization configuration {{{

function virtualization_configuration()
    title "Virtualization configuration"

    packages [[
        VirtualBox
        virtualbox-guest-additions
    ]]
    packages "akmod-VirtualBox kernel-devel-%(pipe 'uname -r')"

end

-- }}}

-- Work configuration {{{

function work_configuration()
    title "Work configuration"

    copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:thofmann:ros.repo", "thofmann/ros")

    packages [[
        moby-engine grubby
        python-devel python3-devel
        ros-rosbag
        xterm
        minicom
        patch yices z3 cvc4 zenon eqp E gtksourceview2-devel libgnomecanvas-devel gmp
        xorg-x11-server-Xephyr
        sqlite-devel fuse-devel libcurl-devel zlib-devel m4
    ]]
    packages [[
        asymptote
        can-utils
        clang
        clang-tools-extra
        cmake
        curl
        doxygen
        gcc
        git
        graphviz
        ImageMagick
        libasan
        libasan-static
        libpcap-devel
        libtsan
        libtsan-static
        libubsan
        libubsan-static
        llvm
        ncurses
        plantuml
        protobuf-devel
        python3
        python3-protobuf
        SDL2-devel
        SDL2_ttf-devel
        socat
        texlive
        texlive-scheme-full
        tcpdump
        tcpreplay
        wget
        xz-devel
        zlib-devel
        minicom
        xterm
        blas-devel
        lapack-devel
        @virtualization
        vim-common
        python3-pygame
        gnu-free-mono-fonts
    ]]

    script "menu-work"

    -- AWS
    if force or upgrade then
        sh "pip3 install --user awscli boto3"
        sh "sudo groupadd docker || true"
        sh "sudo usermod -a -G docker %(USER)"
        sh "sudo systemctl enable docker || true"
    end
    script "aws-login"

    -- Frama-C
    if force or upgrade then
        sh "why3 config --detect || true"
        --sh "pip2 install --user json-query"
    end

    -- Docker
    if force or upgrade then
        -- https://github.com/docker/cli/issues/2104
        sh "sudo grubby --update-kernel=ALL --args=\"systemd.unified_cgroup_hierarchy=0\""

        sh "sudo systemctl start docker || true"
        sh "sudo usermod -a -G docker %(USER)"
    end

    if cfg_yesno("move-docker-to-home", "Move /var/lib/docker to /home/docker?") then
        if not dir_exist "/home/docker" then
            log "Move /var/lib/docker to /home/docker"
            sh "sudo service docker stop"
            if dir_exist "/var/lib/docker" then
                log "Copy /var/lib/docker to /home/docker"
                sh "sudo mv /var/lib/docker /home/docker"
            else
                log "Create /home/docker"
                sh "sudo mkdir /home/docker"
            end
            log "Link /var/lib/docker to /home/docker"
            sh "sudo ln -s -f /home/docker /var/lib/docker"
            sh "sudo service docker start || true"
        end
    end

    if installed "opam" then
        if force or upgrade or not installed "google-drive-ocamlfuse" then
            sh "opam install google-drive-ocamlfuse || true"
        end
    end

    sh [[ pip3 install '--user'             \
                awscli                      \
                click                       \
                junit-xml                   \
                matplotlib                  \
                pyaml                       \
                python-can                  \
                scipy                       \
                tftpy                       \
    ]]

    if cfg_yesno("sphinx", "Install Sphinx?") then
        sh [[ pip3 install '--user'             \
                    breathe                     \
                    recommonmark                \
                    sphinx==2.4.4               \
                    sphinxcontrib-globalsubs    \
                    sphinxcontrib-needs         \
                    sphinxcontrib-plantuml      \
                    sphinxcontrib-wavedrom      \
                    sphinx-multibuild           \
                    sphinx_rtd_theme            \
        ]]
    end

end

-- }}}

-- Eaton configuration {{{

function eaton_configuration()

    if force or not file_exist "/usr/local/Eaton/IntelligentPowerProtector/mc2" then
        title "Eaton Intelligent Power Protector configuration"

        -- https://www.eaton.com/content/dam/eaton/products/backup-power-ups-surge-it-power-distribution/power-management-software-connectivity/eaton-intelligent-power-protector/eaton-ipp-user-guide-p-164000291.pdf
        -- http://pqsoftware.eaton.com/explore/fra/ipp/default_fr.htm?lang=fr&os=LINUX
        -- https://localhost:4680/

        sh "wget %(EATON_IPP_URL) -c -O ~/.local/opt/%(basename(EATON_IPP_URL))"
        sh "sudo dnf install ~/.local/opt/%(basename(EATON_IPP_URL))"
    end

end

-- }}}

-- Radicale configuration {{{

function radicale_configuration()

    title "Radicale configuration"

    packages "radicale3"

    -- The server is available at http://localhost:5232/
    script ".config/radicale/config"
    if not file_exist "%(HOME)/.config/radicale/users" then
        write("%(HOME)/.config/radicale/users", "%(USER):%(ask_string 'Radicale password for %(USER):')\n")
    end
    script "every"
    script "radicale_backup"

end

-- }}}

os.exit(main())
