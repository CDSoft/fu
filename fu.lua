#!/bin/env lua
-- vim: set ts=4 sw=4 foldmethod=marker :

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2021 Christophe Delord
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

    FEDORA = installed "dnf"
    UBUNTU = installed "apt"

    LUA_VERSION = "5.4.3"

    HOME = os.getenv "HOME"
    USER = os.getenv "USER"

    fu_path = I"%(HOME)/.config/fu"
    config_path = I"%(fu_path)/config"
    repo_path = I"%(fu_path)/repos"
    src_files = dirname(pipe "realpath %(arg[0])").."/files"

    TIMEZONE = "Europe/Paris"
    KEYMAP = "fr"
    LOCALE = "fr_FR.UTF-8"

    I3_THEME = "green"      -- "blue" (default), "green"
    FONT = "Fira Code"
    FONT_VARIANT = "Medium"
    NORMAL_FONT_SIZE = 9
    SMALL_FONT_SIZE = 7
    FONT_SIZE = (tonumber(pipe "xdpyinfo | awk '/dimensions/ {print $2}' | awk -F 'x' '{print $2}'") or 1920) < 1080 and SMALL_FONT_SIZE or NORMAL_FONT_SIZE

    BROWSER = "firefox"
    BROWSER2 = cfg_yesno("chrome-as-alternative-browser", "Use Google Chrome as alternative browser?") and "google-chrome" or
               FEDORA and cfg_yesno("chromium-as-alternative-browser", "Use Chromium as alternative browser?") and "chromium-browser" or
               BROWSER

    LATEST_LTS = "lts-18.17"

    CLING_ARCHIVE = "cling_2020-11-05_ROOT-fedora32.tar.bz2"
    CLING_URL = I"https://root.cern.ch/download/cling/%(CLING_ARCHIVE)"
    CLING_DIR = I"%(CLING_ARCHIVE:gsub('%.tar%.bz2$', ''))"

    DROPBOXINSTALL = 'https://www.dropbox.com/download?plat=lnx.x86_64'

end

function main()
    if FEDORA then title "Fedora Updater" end
    if UBUNTU then title "Ubuntu Updater" end

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
    if cfg_yesno("v", "Install V?") then v_configuration() end
    dev_configuration()
    if cfg_yesno("haskell", "Install Haskell?") then haskell_configuration() end
    if cfg_yesno("ocaml", "Install OCaml?") then ocaml_configuration() end
    if cfg_yesno("racket", "Install Racket?") then racket_configuration() end
    if cfg_yesno("julia", "Install Julia?") then julia_configuration() end
    if cfg_yesno("zig", "Install Zig?") then zig_configuration() end
    if cfg_yesno("cling", "Install cling?") then cling_configuration() end
    if cfg_yesno("swipl", "Install SWI Prolog (from sources)?") then swipl_configuration() end
    lsp_configuration()
    text_edition_configuration()
    pandoc_configuration()
    if cfg_yesno("latex", "Install LaTeX?") then latex_configuration() end
    neovim_configuration()
    i3_configuration()
    graphic_application_configuration()
    if cfg_yesno("povray", "Install Povray?") then povray_configuration() end
    internet_configuration()
    if cfg_yesno("zoom", "Install Zoom?") then zoom_configuration() end
    if cfg_yesno("teams", "Install Teams?") then teams_configuration() end
    if cfg_yesno("virtualization", "Install virtualization tools?") then virtualization_configuration() end
    if cfg_yesno("work", "Install work configuration?") then work_configuration() end

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

function when(cond)
    return function(s) return cond and s or "" end
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

local current_title = ""

function title(s)
    local cols = pipe "tput cols"
    local color = string.char(27).."[1m"..string.char(27).."[37m"..string.char(27).."[44m"
    local normal = string.char(27).."[0m"
    s = I(s)
    current_title = s
    s = ("%s [%d]"):format(s, debug.getinfo(2, 'l').currentline)
    io.write(string.char(27).."]0;fu: "..s..string.char(7)) -- windows title
    s = s .. string.rep(" ", cols - #s - 4)
    io.write(color.."### "..s..normal.."\n")
end

function log(s, level)
    local color = string.char(27).."[0m"..string.char(27).."[30m"..string.char(27).."[46m"
    local normal = string.char(27).."[0m"
    s = I(s)
    s = ("%s [%d]"):format(s, debug.getinfo(2+(level or 0), 'l').currentline)
    io.write(string.char(27).."]0;fu: "..current_title.." / "..s..string.char(7)) -- windows title
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
    if FEDORA then
        RELEASE = pipe "rpm -E %fedora"
        log "release : Fedora %(RELEASE)"
    end
    if UBUNTU then
        RELEASE = pipe [[ awk -F "=" '$1=="DISTRIB_DESCRIPTION" {print $2}' /etc/lsb-release ]]
        log "release : %(RELEASE)"
    end
    log "hostname: %(MYHOSTNAME)"
end

function repo(local_name, name)
    if FEDORA and not file_exist(I(local_name)) then
        name = I(name)
        log("Install repo "..name, 1)
        sh("sudo dnf install -y \""..name.."\"")
    end
end

function copr(local_name, name)
    if FEDORA and not file_exist(local_name) then
        name = I(name)
        log("Install copr "..name, 1)
        sh("sudo dnf copr enable \""..name.."\"")
    end
end

function ppa(local_name, name)
    if UBUNTU and not file_exist(local_name) then
        name = I(name)
        log("Install ppa "..name, 1)
        sh("sudo add-apt-repository "..name)
        sh("sudo apt update")
    end
end

function deblist(local_name, name)
    if UBUNTU and not file_exist(local_name) then
        name = I(name)
        log("Install deb.list "..name, 1)
        with_tmpfile(function(tmp)
            write(tmp, name)
            sh("sudo cp "..tmp.." "..local_name)
            sh("sudo chmod 644 "..local_name)
        end)
        sh "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
        sh "sudo apt-get update"
    end
end

function dnf_install(names)
    if not FEDORA then return end
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
        log("Install packages: "..names, 1)
        sh("sudo dnf install "..names.." --skip-broken --best --allowerasing")
        write("%(config_path)/packages", all.concat("\n").."\n")
    end
end

function apt_install(names)
    if not UBUNTU then return end
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
        log("Install packages: "..names, 1)
        sh("sudo apt install "..names)
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
        log("Install luarocks: "..names, 1)
        for _, name in new_packages.ipairs() do
            sh("luarocks install --local "..name)
        end
        write("%(config_path)/luarocks", all.concat("\n").."\n")
    end
end

function upgrade_packages()
    if force or upgrade then
        title "Upgrade packages"
        if FEDORA then
            sh "sudo dnf update --refresh"
            sh "sudo dnf upgrade --best --allowerasing"
        end
        if UBUNTU then
            sh "sudo apt update && sudo apt upgrade"
        end
    end
end

function installed(cmd)
    local found = (os.execute("hash "..I(cmd).." 2>/dev/null"))
    return found
end

function script(name)
    local function template(file_name, dest_name, exe)
        if file_exist(file_name) then
            log("Create "..dest_name, 1)
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
            log("Upgrade "..url.." to "..path.." "..options, 1)
            sh("cd "..path.." && ( git reset --hard master || true ) && git pull")
        end
    else
        log("Clone "..url.." to "..path, 1)
        sh("git clone "..url.." "..path.." "..options)
    end
end

function mime_default(desktop_file)
    desktop_file = I(desktop_file)
    log("Mime default: "..desktop_file, 1)
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

    dnf_install [[
        dnf-plugins-core dnfdragora
        fedora-workstation-repositories
        git
    ]]

    apt_install [[
        git
    ]]

    -- Locale and timezone
    log "Timezone and keyboard"
    sh "sudo timedatectl set-timezone %(TIMEZONE)"
    if FEDORA then sh "sudo localectl set-keymap %(KEYMAP)" end -- TODO : à corriger pour UBUNTU
    sh "sudo localectl set-locale %(LOCALE)"

    -- No more poweroff
    log "Disable power key"
    sh "sudo sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf"
end

-- }}}

-- Shell configuration {{{

function shell_configuration()
    title "Shell configuration"

    dnf_install [[
        zsh
        powerline-fonts
        bat fzf
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
        the_silver_searcher
        hexyl
        zoxide
    ]]

    apt_install [[
        zsh
        fonts-powerline
        grc bat fzf
        inotify-tools
        htop
        pwgen
        ripgrep
        exa
        fd-find
        tmux
        tldr
        hexyl
        zoxide
    ]]

    log "Change current shell"
    sh "chsh -s /bin/zsh %(USER)"

    script ".zprofile"
    script ".zshrc"

    script ".config/starship.toml"

    log "Oh My Zsh"
    gitclone "https://github.com/ohmyzsh/ohmyzsh.git" -- not installed, some scripts will be sourced
    gitclone "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    gitclone "https://github.com/zsh-users/zsh-autosuggestions"

    log "Starship prompt"
    if force or not installed "starship" then
        -- The binary downloaded by install.sh is buggy (crashes on non existing directory)
        -- If Rust is installed, building from sources is better.
        if cfg_yesno("rust", "Install Rust?") then
            dnf_install "openssl-devel"
            apt_install "libssl-dev"
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

    script ".tmux.conf"

    script "fzfmenu"

    if file_exist "/usr/bin/batcat" then
        log "bat symlink"
        sh "ln -s -f /usr/bin/batcat ~/.local/bin/bat"
    end

    if FEDORA then
        if force or upgrade or not installed "grc" then
            gitclone "https://github.com/garabik/grc"
            sh "cd %(repo_path)/grc && sudo ./install.sh"
        end
    end

end

-- }}}

-- Network configuration {{{

function network_configuration()
    title "Network configuration"

    dnf_install [[
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
        openvpn
        telnet
        curl
        wget
        python3-pip
    ]]

    apt_install [[
        nmon
        openssh-client openssh-server
        nmap
        blueman
        socat
        sshpass
        minicom
        wireshark
        openvpn
        telnet
        curl
        wget
        python3-pip
    ]]

    -- hostname
    sh "sudo hostname %(MYHOSTNAME)"
    rootfile("/etc/hostname", "%(MYHOSTNAME)\n")

    -- ssh
    if FEDORA then
        log "sshd"
        sh "sudo systemctl start sshd"
        sh "sudo systemctl enable sshd"
    end
    if UBUNTU then
        log "sshd"
        sh "sudo systemctl start ssh"
        sh "sudo systemctl enable ssh"
    end
    if FEDORA then
        log "Disable firewalld"
        sh "sudo systemctl disable firewalld" -- firewalld fails to stop during shutdown.
    end
    script "ssha"

    -- sshd
    if FEDORA then
        log "sshd"
        sh "sudo chkconfig sshd on"
        sh "sudo service sshd start"
    end

    -- wireshark
    log "Wireshark group"
    sh "sudo usermod -a -G wireshark %(USER)"

end

-- }}}

-- Dropbox configuration {{{

function dropbox_configuration()

    dnf_install [[ PyQt4 libatomic ]]
    apt_install [[ python3-qtpy libatomic1 ]]

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
    if force or upgrade or not installed then
        title "Nextcloud configuration"
        local version, new_version
        if installed then
            version = pipe("%(HOME)/.local/bin/Nextcloud -v"):match("version%s+([%d%.]+)")
        end
        new_version = pipe("curl -s https://github.com/nextcloud/desktop/releases/latest/"):match("tag/v([%d%.]+)")
        if new_version ~= version then
            if version then sh("%(HOME)/.local/bin/Nextcloud -q") end
            with_tmpdir(function(tmp)
                sh("wget https://github.com/nextcloud/desktop/releases/download/v"..new_version.."/Nextcloud-"..new_version.."-x86_64.AppImage -O "..tmp.."/Nextcloud")
                sh("mv -f "..tmp.."/Nextcloud %(HOME)/.local/bin/Nextcloud")
                sh("chmod +x %(HOME)/.local/bin/Nextcloud")
            end)
        end
    end

end

-- }}}

-- Filesystem configuration {{{

function filesystem_configuration()
    title "Filesystem configuration"

    copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:fcsm:cryfs.repo", "fcsm/cryfs")

    dnf_install [[
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

    apt_install [[
        gparted
        udftools
        encfs
        cryfs
        p7zip-full p7zip-rar
        mc pcmanfm thunar
        vifm
        pmount
        exfat-utils exfat-fuse
        syslinux
        backintime-common backintime-qt
        timeshift
        cryptsetup
        squashfs-tools squashfuse
        baobab ncdu
        xz-utils unrar
        archivemount fuseiso sshfs curlftpfs
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

    if cfg_yesno("R", "Install R?") then
        dnf_install [[ R ]]
        apt_install [[ r-base r-base-dev ]]
    end

    dnf_install [[
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
        SDL2-devel SDL2_ttf-devel SDL2_gfx-devel SDL2_mixer-devel SDL2_image-devel
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
        gc-devel
        frama-c ocaml-seq-devel
    ]]

    apt_install [[
        git git-gui gitk qgit gitg tig git-lfs
        subversion
        clang llvm clang-tidy clang-format
        ccls
        cppcheck
        cmake
        ncurses-dev
        libreadline-dev
        meld
        swi-prolog-full
        libev-dev libstartup-notification0-dev libxcb-util-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-render-util0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libyajl-dev
        gcc-arm-none-eabi gdb-arm-none-eabi
        gcc-mingw-w64
        gnat
        python3-pip
        pypy
        luarocks
        libglfw3
        flex bison
        libsdl2-dev libsdl2-ttf-dev libsdl2-gfx-dev libsdl2-mixer-dev libsdl2-image-dev
        libpcap-dev
        libyaml-0-2 libyaml-dev
        libubsan1 libasan6 libtsan0
        expect
        python3-dev
        python3-yaml python3-termcolor
        pkg-config
        libboost-all-dev
        libjpeg-turbo8-dev libpng-dev libtiff-dev
        npm
        liblzma-dev
        libprotobuf-dev python3-protobuf
        lzma-dev
        libopenblas-dev liblapack-dev
        gnuplot
        libssl-dev
        golang
        libx11-dev
        libxft-dev
        octave
        libcurl4-openssl-dev
        libicu-dev ncurses-dev
        libgc-dev
    ]]
    if force or update or not installed "tokei" then
        if cfg_yesno("rust", "Install Rust?") then
            log "Tokei"
            sh "~/.cargo/bin/cargo install tokei"
        end
    end

    if UBUNTU then
        if force or upgrade or not installed "delta" then
            with_tmpdir(function(tmp)
                local version = pipe("curl -s https://github.com/dandavison/delta/releases/latest/"):match("tag/([%d%.]+)")
                if UBUNTU then
                    log "Delta"
                    sh("wget https://github.com/dandavison/delta/releases/download/"..version.."/git-delta_"..version.."_amd64.deb -O "..tmp.."/delta.deb")
                    sh("sudo dpkg -i "..tmp.."/delta.deb")
                end
            end)
        end
    end

    if not file_exist "%(HOME)/.local/bin/lua" or not pipe"ldd %(HOME)/.local/bin/lua":match"readline" then
        log "Lua"
        sh [[
            cd %(repo_path) &&
            curl -R -O http://www.lua.org/ftp/lua-%(LUA_VERSION).tar.gz &&
            rm -rf lua-%(LUA_VERSION) &&
            tar zxf lua-%(LUA_VERSION).tar.gz &&
            cd lua-%(LUA_VERSION) &&
            sed -i 's#^INSTALL_TOP=.*#INSTALL_TOP=%(HOME)/.local#' Makefile &&
            make linux-readline test install
        ]]
    end


    --[=[
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
    --]=]

    script ".gitconfig"

    -- pip
    if force or upgrade then
        log "pip upgrade"
        sh "python3 -m pip install --user --upgrade pip"
    end

    -- git
    -- https://stackoverflow.com/questions/34119866/setting-up-and-using-meld-as-your-git-difftool-and-mergetool
    -- use git meld to call git difftool with meld
    log "Git configuration"
    sh "git config --global alias.meld '!git difftool -t meld --dir-diff'"
    sh "git config --global core.excludesfile ~/.gitignore"

    -- PMcCabe
    if force or upgrade or not installed "pmccabe" then
        gitclone "https://github.com/datacom-teracom/pmccabe"
        sh "cd %(repo_path)/pmccabe && make && cp pmccabe ~/.local/bin"
    end

    -- interactive scratchpad: https://github.com/metakirby5/codi.vim
    script "codi"

    if cfg_yesno("v", "Install V?") then
        if force or upgrade or not installed "vls" then
            gitclone "https://github.com/nedpals/tree-sitter-v"
            sh "mkdir -p ~/.vmodules/; ln -sf %(repo_path)/tree-sitter-v ~/.vmodules/tree_sitter_v"
            gitclone("https://github.com/vlang/vls.git")
            sh [[ cd %(repo_path)/vls
                git checkout use-tree-sitter
                ~/.local/bin/v -gc boehm -cc gcc cmd/vls ]]
        end
    end

end

function lsp_configuration()

    title "Language servers configuration"

    if force or upgrade or not file_exist "%(HOME)/.local/opt/bash-language-server/node_modules/.bin/bash-language-server" then
        log "Bash Language Server"
        mkdir "%(HOME)/.local/opt/bash-language-server"
        sh "cd ~/.local/opt/bash-language-server && npm install bash-language-server && ln -s -f $PWD/node_modules/.bin/bash-language-server ~/.local/bin/"
    end
    if force or upgrade or not file_exist "%(HOME)/.local/opt/dot-language-server/node_modules/.bin/dot-language-server" then
        log "Dot Language Server"
        mkdir "%(HOME)/.local/opt/dot-language-server"
        sh "cd ~/.local/opt/dot-language-server && npm install dot-language-server && ln -s -f $PWD/node_modules/.bin/dot-language-server ~/.local/bin/"
    end
    --[[
    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "haskell-language-server" then
            log "Haskell Language Server"
            gitclone("https://github.com/haskell/haskell-language-server", {"--recurse-submodules"})
            sh "cd %(repo_path)/haskell-language-server && stack ./install.hs hls"
        end
    end
    --]]
    if force or upgrade or not file_exist "%(HOME)/.local/opt/pyright-langserver/node_modules/.bin/pyright-langserver" then
        log "Python Language Server"
        mkdir "%(HOME)/.local/opt/pyright-langserver"
        sh "cd ~/.local/opt/pyright-langserver && npm install pyright && ln -s -f $PWD/node_modules/.bin/pyright-langserver ~/.local/bin/"
    end
    if force or upgrade or not installed "lua-language-server" then
        log "Lua Language Server"
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

    if not installed "stack" then
        log "Stack installation"
        sh "curl -sSL https://get.haskellstack.org/ | sh"
    elseif force or upgrade then
        log "Stack upgrade"
        sh "stack upgrade"
    end

    local RESOLVER = LATEST_LTS
    local HASKELL_PACKAGES = {
        "hasktags",
        "hlint",
        "hoogle",
        --"matplotlib",
        --"gnuplot",
        --"parallel",
        --"MissingH",
        --"timeit",
    }
    if force or upgrade then
        for _, package in ipairs(HASKELL_PACKAGES) do
            log("Stack install "..package)
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

    dnf_install [[
        opam
        z3
        cvc4
        frama-c
        coq
        why3
        alt-ergo
        frama-c ocaml-seq-devel
    ]]

    apt_install [[
        opam
        z3
        cvc4
    ]]

    if force or not installed "opam" then
        title "OCaml configuration"
        if FEDORA then
            --sh "wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin"
            sh "opam init"
            sh "opam update && opam upgrade"
            --sh "opam install depext"
            --sh "opam depext frama-c || true"
            --sh "opam install frama-c coq why3 alt-ergo || true"
        end
        if UBUNTU then
            sh "opam init"
            sh "opam update && opam upgrade"
            sh "opam install depext"
            sh "opam depext frama-c"
            sh "opam install frama-c"
        end
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
        for _, exe in ipairs { "racket", "drracket", "raco" } do
            sh("ln -f -s ~/.local/opt/%(RACKET_NAME)/bin/"..exe.." ~/.local/bin/"..exe)
        end

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
        sh "~/.cargo/bin/rustup update stable"
    elseif force or upgrade then
        title "Rust upgrade"
        sh "rustup update stable"
    end

    local RUST_PACKAGES = {
    }
    for _, package in ipairs(RUST_PACKAGES) do
        if force or not installed(package) then
            log("Rust package: "..package)
            sh("~/.cargo/bin/cargo install %(force and '--force' or '') "..package)
        end
    end

end

-- }}}

-- Julia configuration {{{

function julia_configuration()

    if force or not installed "julia" then

        title "Julia configuration"

        dnf_install [[ julia ]]
        apt_install [[ julia ]]

        --[=[
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
        --]=]
    end

end

-- }}}

-- V configuration {{{

function v_configuration()

    if force or not installed "v" then

        title "V configuration"

        dnf_install "libatomic"
        gitclone "https://github.com/vlang/v"
        sh "cd %(repo_path)/v && make && ln -sf %(repo_path)/v/v ~/.local/bin/v"

    end

end

-- }}}

-- Zig configuration {{{

function zig_configuration()

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

    if force or upgrade or not installed "zls" then
        title "Zig Language Server installation"
        local version = pipe("curl -s https://github.com/zigtools/zls/releases/latest/"):match("tag/([%d%.]+)")
        with_tmpdir(function(tmp)
            sh("wget https://github.com/zigtools/zls/releases/download/"..version.."/x86_64-linux.tar.xz -O "..tmp.."/x86_64-linux.tar.xz")
            sh("cd "..tmp.."; tar xJf x86_64-linux.tar.xz && mv x86_64-linux/zls %(HOME)/.local/bin/zls")
        end)
    end

end

-- }}}

-- Cling configuration {{{

function cling_configuration()

    if FEDORA then
        if force or not installed "cling" then
            title "Cling configuration"

            dnf_install "cling"

            --[=[
            sh "wget %(CLING_URL) -c -O ~/.local/opt/%(basename(CLING_URL))"
            sh "rm -rf ~/.local/opt/%(CLING_DIR)"
            sh "tar xjf ~/.local/opt/%(basename(CLING_URL)) -C ~/.local/opt"
            sh "ln -f -s ~/.local/opt/%(CLING_DIR)/bin/cling ~/.local/bin/cling"
            --]=]
        end
    end

end

-- }}}

-- SWI Prolog {{{

function swipl_configuration()

    if force or not file_exist "%(HOME)/.local/bin/swipl" then
        title "SWI Prolog configuration"

        -- https://www.swi-prolog.org/build/unix.html
        dnf_install [[
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
        apt_install [[
            build-essential cmake ninja-build pkg-config
            libncurses-dev libreadline-dev libedit-dev
            libgoogle-perftools-dev
            libunwind-dev
            libgmp-dev
            libssl-dev
            unixodbc-dev
            zlib1g-dev libarchive-dev
            libossp-uuid-dev
            libxext-dev libice-dev libjpeg-dev libxinerama-dev libxft-dev
            libxpm-dev libxt-dev
            libdb-dev
            libpcre3-dev
            libyaml-dev
            default-jdk junit4
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

    dnf_install [[
        wkhtmltopdf
        aspell-fr aspell-en
        figlet
        translate-shell
        doxygen
        gnuplot
        graphviz
    ]]
    apt_install [[
        wkhtmltopdf
        aspell-fr aspell-en
        figlet
        translate-shell
        doxygen
        gnuplot
        graphviz
    ]]

end

-- }}}

-- Pandoc configuration {{{

function pandoc_configuration()
    title "Pandoc configuration"

    dnf_install [[
        pandoc
        patat
        asymptote
    ]]
    apt_install [[
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

    if cfg_yesno("haskell", "Install Haskell?") and cfg_yesno("abp", "Install abp?") then
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
        log "plantuml.jar"
        sh "wget http://sourceforge.net/projects/plantuml/files/plantuml.jar -O ~/.local/bin/plantuml.jar"
    end

    if force or not file_exist "%(HOME)/.local/bin/ditaa.jar" then
        log "ditaa.jar"
        sh "wget https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar -O ~/.local/bin/ditaa.jar"
    end

    if force or upgrade or not installed "blockdiag" then
        log "Blockdiag"
        sh "pip3 install --user blockdiag seqdiag actdiag nwdiag"
    end

    if force or upgrade or not file_exist "%(HOME)/.local/opt/mermaid/node_modules/.bin/mmdc" then
        log "Mermaid"
        mkdir "%(HOME)/.local/opt/mermaid"
        sh "cd ~/.local/opt/mermaid && npm install mermaid.cli && ln -s -f $PWD/node_modules/.bin/mmdc ~/.local/bin/"
    end

end

-- }}}

-- LaTeX configuration {{{

function latex_configuration()
    title "LaTeX configuration"

    dnf_install [[
        texlive texlive-scheme-full
        graphviz plantuml asymptote
    ]]
    apt_install [[
        texlive texlive-full
        graphviz plantuml asymptote
    ]]

end

-- }}}

-- neovim configuration {{{

function neovim_configuration()
    title "neovim configuration"

    ppa("/etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-impish.list", "ppa:neovim-ppa/stable")

    dnf_install [[
        neovim
        fzf
        ccrypt pwgen
        gzip
        jq
    ]]
    apt_install [[
        neovim
        fzf
        ccrypt pwgen
        gzip
        jq
    ]]

    sh "pip3 install --user pynvim"

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
        log "Asymptote syntax"
        mkdir "%(HOME)/.config/nvim/syntax"
        mkdir "%(HOME)/.config/nvim/ftdetect"
        sh "cp /usr/share/asymptote/asy.vim ~/.config/nvim/syntax/"
        sh "cp /usr/share/asymptote/asy_filetype.vim ~/.config/nvim/ftdetect/asy.vim"
    end

    -- update all plugins
    if force or upgrade then
        log "Pluggin update"
        sh "nvim -c PlugUpgrade -c PlugInstall -c PlugUpdate -c qa"
        sh 'nvim --headless "+call firenvim#install(0) | q"'
    end

    if cfg_yesno("haskell", "Install Haskell?") then
        if force or upgrade or not installed "shellcheck" then
            log "ShellCheck"
            sh "stack install --resolver=%(LATEST_LTS) ShellCheck"
        end
    end

end

-- }}}

-- i3 configuration {{{

function i3_configuration()
    title "i3 configuration"

    dnf_install [[
        rxvt-unicode
        numlockx
        rlwrap
        i3 i3status i3lock dmenu xbacklight feh
        i3-ipc
        picom
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
    apt_install [[
        rxvt-unicode
        numlockx
        rlwrap
        i3 i3status i3lock suckless-tools xbacklight feh
        picom
        arandr
        sox
        fortune-mod imagemagick
        sxiv ristretto
        volumeicon-alsa pavucontrol
        fonts-firacode
        rofi
        xbindkeys
        lxappearance
        qt5ct
        xfce4-settings
        xfce4-screenshooter
        xfce4-notifyd
        xfce4-volumed
        xcwd
    ]]

    -- alacritty
    if force or upgrade or not installed "alacritty" then
        log "Alacritty"
        if cfg_yesno("rust", "Install Rust?") then
            dnf_install [[ cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ ]]
            apt_install [[ cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 ]]
            sh "~/.cargo/bin/cargo install alacritty"
        elseif FEDORA then
            dnf_install "alacritty"
        elseif UBUNTU then
            ppa("/etc/apt/sources.list.d/aslatter-ubuntu-ppa-impish.list", "ppa:aslatter/ppa")
            apt_install "alacritty"
        end
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
    if cfg_yesno("thunderbird-mailer", "Use Thunderbird as the default mailer?") then
        mime_default "mozilla-thunderbird.desktop"
    end
    mime_default "atril.desktop"
    mime_default "thunar.desktop"
    mime_default "ristretto.desktop" -- shall be configured after atril to overload atril associations
    mime_default "vlc.desktop"
    mime_default "wireshark.desktop"
    mime_default "nvim.desktop"

    script ".config/alacritty/alacritty.yml"

    script ".config/i3/config"
    script ".xsession"
    script ".xsessionrc"

    script ".config/dunst/dunstrc"

    script ".config/rofi/config.rasi"

    script "wallpaper_of_the_day"
    script "every"

    script "xi3"

    if FEDORA then
        if force or upgrade or not installed "xcwd" then
            gitclone "https://github.com/schischi-a/xcwd.git"
            -- patch to reject "/"
            local xcwd = read "%(repo_path)/xcwd/xcwd.c"
            xcwd = xcwd:gsub('%(%s*access%s*%(%s*([%w->]+)%s*,%s*F_OK%s*%)%s*%)', I'(access(%1, F_OK) != 0 || strcmp(%1, "/") == 0)')
            write("%(repo_path)/xcwd/xcwd.c", xcwd)
            sh "cd %(repo_path)/xcwd && make && sudo make install"
        end
    end

    if FEDORA then
        if force or upgrade or not installed "hsetroot" then
            dnf_install "imlib2-devel"
            gitclone "https://github.com/himdel/hsetroot"
            sh "cd %(repo_path)/hsetroot && make && DESTDIR=%(HOME) PREFIX=/.local make install"
        end
    end
    if UBUNTU then
        apt_install "hsetroot"
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
        log "VLC configuration"
        local vlcrc = read "%(HOME)/.config/vlc/vlcrc"
        vlcrc = vlcrc:gsub('#?one%-instance=[01]', "one-instance=1")
        write("%(HOME)/.config/vlc/vlcrc", vlcrc)
    end

end

-- }}}

-- Graphic applications configuration {{{

function graphic_application_configuration()
    title "Graphic applications configuration"

    dnf_install [[
        shutter feh gimp ImageMagick scribus inkscape
        qt5-qtx11extras
        gnuplot
        qrencode
        libreoffice libreoffice-langpack-fr libreoffice-help-fr
        vokoscreenNG
        simple-scan
        evince okular mupdf qpdfview
        atril

        vlc ffmpeg
        gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras
    ]]
    apt_install [[
        feh gimp imagemagick scribus inkscape
        gnuplot
        qrencode
        libreoffice libreoffice-l10n-fr libreoffice-help-fr
        vokoscreen-ng
        simple-scan
        evince okular mupdf qpdfview
        atril

        vlc ffmpeg
    ]]

    --[=[
    if UBUNTU then
        apt_install [[
            git dpkg-dev
            gobject-introspection libdjvulibre-dev libgail-3-dev
            libgirepository1.0-dev libgtk-3-dev libgxps-dev
            libkpathsea-dev libpoppler-glib-dev libsecret-1-dev
            libspectre-dev libtiff-dev libwebkit2gtk-4.0-dev libxapp-dev
            mate-common meson xsltproc yelp-tools
        ]]
        gitclone "https://github.com/linuxmint/xreader.git"
        sh [[
            cd %(repo_path)/xreader &&
                meson debian/build \
                    --prefix=%(HOME)/.local \
                    --buildtype=plain \
                    -D deprecated_warnings=false \
                    -D djvu=true \
                    -D dvi=true \
                    -D t1lib=true \
                    -D pixbuf=true \
                    -D comics=true \
                    -D introspection=true &&
                ninja -C debian/build &&
                ninja -C debian/build install
        ]]
    end
    --]=]

end

-- }}}

-- Povray configuration {{{

function povray_configuration()
    title "Povray configuration"

    dnf_install [[ povray ]]
    apt_install [[ povray ]]

    --[=[
    if force or not installed "povray" then
        gitclone "https://github.com/pov-ray/povray.git"
        sh "cd %(repo_path)/povray/unix && ./prebuild.sh"
        sh [[cd %(repo_path)/povray/ && ./configure '--prefix'="$(realpath ~/.local)" compiled_by="christophe delord <http://cdelord.fr>"]]
        sh "cd %(repo_path)/povray/ && make check install"
    end
    --]=]
end

-- }}}

-- Internet configuration {{{

function internet_configuration()
    title "Internet configuration"

    dnf_install [[
        firefox
        surf
        thunderbird
        transmission
    ]]
    apt_install [[
        firefox
        surf
        thunderbird
        transmission
    ]]

    if cfg_yesno("chrome", "Install Google Chrome?") then
        if FEDORA then sh "sudo dnf config-manager --set-enabled google-chrome" end
        if UBUNTU then
            deblist("/etc/apt/sources.list.d/google-chrome.list", "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main")
            sh "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
        end
        dnf_install "google-chrome-stable"
        apt_install "google-chrome-stable"
    end
    if FEDORA and cfg_yesno("chromium", "Install Chromium?") then
        packages "chromium"
    end

    -- Default browser
    log "Default browser"
    sh "BROWSER= xdg-settings set default-web-browser %(BROWSER).desktop"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop text/html"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/http"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/https"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/about"

    -- Firefox configuration
    -- https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
    -- https://askubuntu.com/questions/239543/get-the-default-firefox-profile-directory-from-bash
    if file_exist("%(HOME)/.mozilla/firefox/profiles.ini") then
        log "Firefox configuration"
        for line in readlines("%(HOME)/.mozilla/firefox/profiles.ini") do
            for profile in line:gmatch("Path=(.*)") do
                write("%(HOME)/.mozilla/firefox/"..profile.."/user.js", read "%(src_files)/user.js")
            end
        end
    end

    -- Thunderbird extensions
    if force or upgrade or not file_exist "%(repo_path)/reply_as_original_recipient.xpi" then
        gitclone "https://github.com/qiqitori/reply_as_original_recipient.git"
        sh "cd %(repo_path)/reply_as_original_recipient && zip -r ../reply_as_original_recipient.xpi *"
    end

    -- Remove unecessary language symlinks
    log "Remove unecessary language symlinks"
    sh "sudo find /usr/share/myspell -type l -exec rm -v {} \\;"

end

-- }}}

-- Zoom configuration {{{

function zoom_configuration()
    title "Zoom configuration"

    if force or not installed "zoom" then
        with_tmpdir(function(tmp)
            if FEDORA then
                sh("wget https://zoom.us/client/latest/zoom_x86_64.rpm -O "..tmp.."/zoom_x86_64.rpm")
                sh("sudo dnf install "..tmp.."/zoom_x86_64.rpm")
            end
            if UBUNTU then
                sh("wget https://zoom.us/client/latest/zoom_amd64.deb -O "..tmp.."/zoom_amd64.deb")
                sh("sudo apt install "..tmp.."/zoom_amd64.deb")
            end
        end)
        mime_default "Zoom.desktop"
    end

end

-- }}}

-- Teams configuration {{{

function teams_configuration()

    if force or not installed "teams" then

        title "Teams configuration"

        if FEDORA then
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

        if UBUNTU then
            sh "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
            deblist("/etc/apt/sources.list.d/teams.list", "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main")
            apt_install "teams"
        end

    end

end

-- }}}

-- Virtualization configuration {{{

function virtualization_configuration()
    title "Virtualization configuration"

    dnf_install [[
        VirtualBox
        virtualbox-guest-additions
    ]]
    apt_install [[
        virtualbox-qt
        virtualbox-ext-pack
        virtualbox-guest-additions-iso
    ]]
    dnf_install "akmod-VirtualBox kernel-devel-%(pipe 'uname -r')"
    apt_install "virtualbox-dkms linux-headers-%(pipe 'uname -r')"
    if UBUNTU then
        sh "sudo modprobe vboxdrv"
    end

end

-- }}}

-- Work configuration {{{

function work_configuration_old()
    title "Work configuration"

    if not FEDORA then return end

    dnf_install [[
        moby-engine grubby
        python-devel python3-devel
        ros-rosbag
        ros-desktop_full-devel
        xterm
        minicom
        patch yices z3 cvc4 zenon eqp E gtksourceview2-devel libgnomecanvas-devel gmp
        xorg-x11-server-Xephyr
        sqlite-devel fuse-devel libcurl-devel zlib-devel m4
    ]]
    dnf_install [[
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
        glibc-locale-source
        cmake
        dos2unix
        findutils
        gcc
        make
        qt qt-x11 motif expect
        glibc.i686
        astyle
        asymptote
        bc
        blas-devel
        can-utils
        clang
        clang-tools-extra
        curl
        doxygen
        gcc
        gedit
        git
        git-lfs
        glibc.i686
        gnu-free-mono-fonts
        graphviz
        ImageMagick
        java
        jq
        lapack-devel
        libasan
        libasan-static
        libffi-devel
        libpcap-devel
        libtsan
        libtsan-static
        libubsan
        libubsan-static
        llvm
        lua
        lzma-devel
        mesa-dri-drivers
        mesa-libGLU
        minicom
        ncurses
        protobuf-devel
        python3
        python3-devel
        python3-pygments
        qt qt-x11 motif
        SDL2_ttf-devel
        SDL2-devel
        socat
        sudo
        tcpdump
        tcpreplay
        texlive
        texlive-scheme-full
        wget
        xauth
        xorg-x11-server-Xvfb
        xterm
        xz-devel
        zlib-devel
        cvc4
        E
        eqp
        gappa
        gmp
        gtksourceview2-devel
        libgnomecanvas-devel
        ocaml
        ocaml-ocamldoc
        opam
        patch
        yices
        z3
        zenon
    ]]

    script "menu-work"

    -- NVidia drivers
    -- https://docs.fedoraproject.org/en-US/quick-docs/how-to-set-nvidia-as-primary-gpu-on-optimus-based-laptops/
    if cfg_yesno("nvidia", "Install NVidia drivers") then
        dnf_install [[
            xorg-x11-drv-nvidia akmod-nvidia
            xorg-x11-drv-nvidia-cuda
            gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686
        ]]
        sh "sudo akmods --force || true"
        sh "sudo dracut --force"
        sh "sudo cp -p /usr/share/X11/xorg.conf.d/nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf"
        if not read("/etc/X11/xorg.conf.d/nvidia.conf"):match[[Option "PrimaryGPU" "yes"]] then
            -- add Option "PrimaryGPU" "yes" to OutputClass
            sh "sudo vi /etc/X11/xorg.conf.d/nvidia.conf"
        end
    end

    -- Google Drive
    --if force or upgrade then
    --    sh "pip install --user --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib"
    --end

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

function work_configuration()
    title "Work configuration"

    script "menu-work"

    dnf_install [[
        moby-engine grubby
    ]]
    apt_install [[
        docker.io docker-compose
    ]]

    -- AWS
    if force or upgrade then
        log "AWS configuration"
        sh "pip3 install --user awscli boto3"
        sh "sudo groupadd docker || true"
        sh "sudo usermod -a -G docker %(USER)"
        sh "sudo systemctl enable docker || true"
    end
    script "aws-login"

    -- Docker
    if force or upgrade then
        log "Docker configuration"
        if FEDORA then
            -- https://github.com/docker/cli/issues/2104
            sh "sudo grubby --update-kernel=ALL --args=\"systemd.unified_cgroup_hierarchy=0\""
        end
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

    -- ROS: http://wiki.ros.org/Installation/Source
    if cfg_yesno("ros", "Install ROS?") then
        if FEDORA then
            dnf_install [[
                gcc-c++ python3-rosdep python3-rosinstall_generator python3-vcstool @buildsys-build
                python3-sip-devel qt-devel python3-qt5-devel
            ]]
            if not dir_exist "%(HOME)/ros_catkin_ws" then
                log "Build ROS"
                sh "sudo rosdep init"
                sh "rosdep update"
                sh [[
                    mkdir -p %(HOME)/ros_catkin_ws;
                    cd %(HOME)/ros_catkin_ws;
                    rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.ros;
                    mkdir -p src;
                    vcs import --input noetic-desktop.ros ./src;
                    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y;
                    ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release;
                ]]
            end
        end
        if UBUNTU then
            apt_install [[
                ros-desktop-full
                ros-desktop-full-dev
            ]]
        end
    end

end

-- }}}

os.exit(main())
