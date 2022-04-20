#!/bin/env luax
-- vim: set ts=4 sw=4 foldmethod=marker :

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2022 Christophe Delord
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

local fun = require "fun"
local fs = require "fs"

function fu_configuration()
    HOME = os.getenv "HOME"
    USER = os.getenv "USER"

    fu_path = I"%(HOME)/.config/fu"
    config_path = I"%(fu_path)/config"
    repo_path = I"%(fu_path)/repos"
    src_files = dirname(pipe "realpath %(arg[0])").."/files"

    configured = db(fs.join(config_path, "configured.lua"))
    installed_packages = db(fs.join(config_path, "packages.lua"))
    installed_snap_packages = db(fs.join(config_path, "snap_packages.lua"))
    installed_lua_packages = db(fs.join(config_path, "lua_packages.lua"))

    cfg = interactive(fs.join(config_path, "config.lua")) {

        hostname = {"Hostname:", "str"},
        wiki = {"Wiki directory (e.g.: ~/Nextcloud/Wiki):", "str"},
        git_user_email = {"Git user email:", "str"},
        git_user_name = {"Git user name:", "str"},

        numlockx = {"Enable numclockx?", "yn"},
        external_monitor = {"Add shortcuts for external monitor?", "yn"},
        i3_fnkeys = {"Use Fn keys to change workspaces?", "yn"},
        wallpaper = {"Use daily wallpaper?", "yn"},
        wallpaper_nasa = {"Use NASA wallpaper?", "yn"},
        wallpaper_bing = {"Use BING wallpaper?", "yn"},

        chrome_as_alternative_browser = {"Use Google Chrome as alternative browser?", "yn"},
        chromium_as_alternative_browser = {"Use Chromium as alternative browser?", "yn"},
        thunderbird_mailer = {"Use Thunderbird as the default mailer?", "yn"},
        chrome = {"Install Google Chrome?", "yn"},
        chromium = {"Install Chromium?", "yn"},

        haskell = {"Install Haskell?", "yn"},
        ocaml = {"Install OCaml?", "yn"},
        racket = {"Install Racket?", "yn"},
        julia = {"Install Julia?", "yn"},
        swipl = {"Install SWI Prolog (from sources)?", "yn"},
        zig = {"Install Zig?", "yn"},
        frama_c = {"Install Frama-C?", "yn"},
        rust = {"Install Rust?", "yn"},
        v = {"Install V?", "yn"},
        R = {"Install R?", "yn"},
        asymptote_sources = {"Install Asymptote from source?", "yn"},
        geogebra = {"Install GeoGebra?", "yn"},

        latex = {"Install LaTeX?", "yn"},
        povray = {"Install Povray?", "yn"},
        lazygit = {"Install lazygit?", "yn"},
        lazydocker = {"Install lazydocker?", "yn"},
        abp = {"Install abp?", "yn"},
        pp = {"Install pp?", "yn"},

        zoom = {"Install Zoom?", "yn"},
        teams = {"Install Teams?", "yn"},

        virtualization = {"Install virtualization tools?", "yn"},

        work = {"Install work configuration?", "yn"},
        ros = {"Install ROS?", "yn"},
        move_docker_to_home = {"Move /var/lib/docker to /home/docker?", "yn"},

        nvim_telescope = {"Use Telescope with Neovim?", "yn"},
        nvim_fzf = {"Use FZF with Neovim?", "yn"},

        nextcloud_client = {"Install Nextcloud client?", "yn"},
        nextcloud_client_start = {"Start Nextcloud client after boot?", "yn"},
        nextcloud_server = {"Install Nextcloud server?", "yn"},
        dropbox = {"Install Dropbox?", "yn"},

        startvlc = {"Autostart VLC in the systray?", "yn"},

    }
end

function os_configuration()

    LUA_VERSION = "5.4.4"

    TIMEZONE = "Europe/Paris"
    KEYMAP = "fr"
    LOCALE = "fr_FR.UTF-8"

    I3_THEME = -- "blue" (default), "green"
           UBUNTU and "blue"
        or DEBIAN and "green"
        or FEDORA and "green"
    FONT = "Fira Code"
    FONT_VARIANT = "Medium"
    NORMAL_FONT_SIZE = 9
    SMALL_FONT_SIZE = 9
    local yres = tonumber(pipe "xdpyinfo | awk '/dimensions/ {print $2}' | awk -F 'x' '{print $2}'") or 1080
    FONT_SIZE =    yres <= 1080 and 9
                or yres <= 1440 and 9+4
                or                  9+8
    I3_INPUT_FONT = "-*-*-*-*-*-*-20-*-*-*-*-*-*-*"

    BROWSER = "firefox"
    BROWSER2 = cfg.chrome_as_alternative_browser and "google-chrome" or
               cfg.chromium_as_alternative_browser and "chromium-browser" or
               BROWSER

    WIKI = cfg.wiki
    if WIKI == "" then WIKI = "~" end

    LATEST_LTS = "lts-18.24"

    DROPBOXINSTALL = 'https://www.dropbox.com/download?plat=lnx.x86_64'

end

function main()

    fu_configuration()
    identification()
    os_configuration()

    for _, a in ipairs(arg) do
        if a == "-h" then help(); return;
        elseif a == "-f" then force = true; upgrade = true
        elseif a == "-u" then upgrade = true
        elseif a == "-r" then reset()
        else io.stderr:write("Error: Unknown argument: "..a.."\n\n"); help(); return 1
        end
    end

    create_directories()

    check_last_upgrade()

    system_configuration()
    if cfg.rust then rust_configuration() end
    shell_configuration()
    network_configuration()
    if cfg.dropbox then dropbox_configuration() end
    if cfg.nextcloud_client then nextcloud_client_configuration() end
    if cfg.nextcloud_server then nextcloud_server_configuration() end
    filesystem_configuration()
    if cfg.v then v_configuration() end
    dev_configuration()
    if cfg.haskell then haskell_configuration() end
    if cfg.ocaml then ocaml_configuration() end
    if cfg.frama_c then framac_configuration() end
    if cfg.racket then racket_configuration() end
    if cfg.julia then julia_configuration() end
    if cfg.zig then zig_configuration() end
    if cfg.swipl then swipl_configuration() end
    lsp_configuration()
    text_edition_configuration()
    if cfg.latex then latex_configuration() end
    asymptote_configuration()
    pandoc_configuration()
    neovim_configuration()
    i3_configuration()
    graphic_application_configuration()
    if cfg.povray then povray_configuration() end
    internet_configuration()
    if cfg.zoom then zoom_configuration() end
    if cfg.teams then teams_configuration() end
    if cfg.virtualization then virtualization_configuration() end
    if cfg.work then work_configuration() end

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
    return answer:match "y" == "y"
end

function when(cond)
    return function(s) return cond and s or "" end
end

do -- configuration management

    local function read(filename)
        local f = io.open(filename, "r")
        if not f then return {} end
        local content = assert(f:read"a")
        local t = {}
        local chunk = assert(load(content, filename, "t", t))
        chunk()
        f:close()
        return t
    end

    local function write(filename, params)
        local conf = fun.map(fun.keys(params), function(k)
            local v = params[k]
            local fmt = type(v) == "string" and "%q" or "%s"
            return ("_ENV['%%s'] = %s\n"):format(fmt):format(k, v)
        end)
        mkdir(fs.dirname(filename))
        local f = io.open(filename, "w")
        if not f then return end
        f:write(table.concat(conf))
        f:close()
    end

    function interactive(filename)
        return function(definitions)

            local questions = {
                ["yn"] = function(question)
                    local answer = nil
                    repeat
                        io.write(question.." [y/n] ")
                        answer = io.read "l":lower():gsub("^%s*(%S).*$", "%1")
                    until answer:match "[yn]"
                    return answer:match "y" == "y"
                end,
                ["str"] = function(question)
                    local answer = nil
                    repeat
                        io.write(question.." ")
                        answer = io.read "l":gsub("^%s+", ""):gsub("%s+$", "")
                    until #answer > 0
                    return answer
                end,
                ["num"] = function(question)
                    local answer = nil
                    repeat
                        io.write(question.." ")
                        answer = io.read "l":gsub("^%s+", ""):gsub("%s+$", "")
                    until #answer > 0 and tonumber(answer)
                    return tonumber(answer)
                end,
            }

            local params = read(filename)

            local mt = {}

            function mt.__index(_, key)
                if params[key] == nil then
                    local qdef = assert(definitions[key], ("Undefined configuration parameter: %s"):format(key))
                    local question, question_type = table.unpack(qdef)
                    ask = assert(questions[question_type], ("Question type not implemented: %s"):format(question_type))
                    params[key] = ask(question)
                    write(filename, params)
                end
                return params[key]
            end

            return setmetatable({}, mt)
        end
    end

    function db(filename)
        local params = read(filename)

        local mt = {}

        function mt.__index(_, key)
            return params[key]
        end

        function mt.__newindex(_, key, val)
            params[key] = val
            write(filename, params)
        end

        return setmetatable({}, mt)

    end

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

function with_file(name, f)
    local content = read(name)
    content = f(content)
    write(name, content)
end

function sh(cmd) assert(os.execute(I(cmd))) end

function mkdir(path) sh("mkdir -p "..path) end

function rm(path) os.remove(I(path)) end

function identification()
    local function os_release(param) return pipe(". /etc/os-release; echo $"..param) end
    OS_RELEASE_NAME         = os_release "NAME"
    OS_RELEASE_PRETTY_NAME  = os_release "PRETTY_NAME"
    OS_RELEASE_ID           = os_release "ID"
    OS_RELEASE_VERSION_ID   = os_release "VERSION_ID"
    UBUNTU_CODENAME         = os_release "UBUNTU_CODENAME"

    title(OS_RELEASE_PRETTY_NAME)

    FEDORA = (OS_RELEASE_ID == "fedora")
    UBUNTU = (OS_RELEASE_ID == "ubuntu")
    DEBIAN = (OS_RELEASE_ID == "linuxmint" or OS_RELEASE_ID == "debian")

    assert(FEDORA or UBUNTU or DEBIAN, "Unsupported distribution: "..OS_RELEASE_PRETTY_NAME)

    RELEASE = FEDORA and pipe "rpm -E %fedora"
              or (UBUNTU or DEBIAN) and OS_RELEASE_VERSION_ID

    MYHOSTNAME = cfg.hostname
    log "hostname: %(MYHOSTNAME)"
    log "username: %(USER)"
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
        apt_install "software-properties-common"
        sh("sudo add-apt-repository "..name)
        sh("sudo apt update")
    end
end

function deblist(local_name, name)
    if (UBUNTU or DEBIAN) and not file_exist(local_name) then
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
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if force or update or not installed_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install packages: "..names, 1)
        sh("sudo dnf install "..names.." --skip-broken --best --allowerasing")
        fun.foreach(new_packages, function(name) installed_packages[name] = true end)
    end
end

function apt_install(names)
    if not (UBUNTU or DEBIAN) then return end
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if force or update or not installed_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install packages: "..names, 1)
        sh("sudo apt install "..names)
        fun.foreach(new_packages, function(name) installed_packages[name] = true end)
    end
end

function snap_install(names)
    if not UBUNTU then return end
    if not cfg.nextcloud_server and not cfg.snap then return end
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if force or update or not installed_snap_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install snap packages: "..names, 1)
        sh("sudo snap install "..names)
        fun.foreach(new_packages, function(name) installed_snap_packages[name] = true end)
    end
end

function luarocks(names)
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if not installed_lua_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install luarocks: "..names, 1)
        for _, name in new_packages.ipairs() do
            sh("luarocks install --local "..name)
        end
        fun.foreach(new_packages, function(name) installed_lua_packages[name] = true end)
    end
end

function upgrade_packages()
    if force or upgrade then
        title "Upgrade packages"
        if FEDORA then
            sh "sudo dnf update --refresh"
            sh "sudo dnf upgrade --best --allowerasing"
        end
        if UBUNTU or DEBIAN then
            sh "sudo apt update && sudo apt upgrade"
        end
        if UBUNTU then
            sh "sudo snap refresh"
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
            log("Create "..dest_name, 2)
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
            sh("cd "..path.." && ( git stash && git checkout master && git reset --hard master || true ) && git pull")
        end
    else
        log("Clone "..url.." to "..path, 1)
        sh("git clone "..url.." "..path.." "..options)
    end
    sh("cd "..path.." && git submodule sync && git submodule update --init --recursive")
end

function mime_default(desktop_file)
    desktop_file = I(desktop_file)
    log("Mime default: "..desktop_file, 1)
    local path = "/usr/share/applications/"..desktop_file
    if file_exist(path) and (force or upgrade or not configured[desktop_file]) then
        read(path):gsub("MimeType=([^\n]*)", function(mimetypes)
            mimetypes:gsub("[^;]+", function(mimetype)
                sh("xdg-mime default "..desktop_file.." "..mimetype)
            end)
        end)
        configured[desktop_file] = true
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
    local now = os.time()
    if not force then
        title "Check last force upgrade"
        local last_force_upgrade = installed_packages.last_force_upgrade or 0
        local outdated = now - last_force_upgrade > 60*86400
        if outdated then
            force = ask_yesno "The last force upgrade is too old. Force upgrade now?"
        end
        upgrade = upgrade or force
    end
    if not upgrade then
        title "Check last upgrade"
        local last_upgrade = installed_packages.last_upgrade or 0
        local outdated = now - last_upgrade > 15*86400
        if outdated then
            upgrade = ask_yesno "The last upgrade is too old. Force upgrade now?"
        end
    end
end

function store_upgrade_date()
    local now = os.time()
    if force then
        installed_packages.last_force_upgrade = now
    end
    if upgrade then
        installed_packages.last_upgrade = now
    end
end

-- }}}

-- System packages {{{

function system_configuration()
    title "System configuration"

    if FEDORA then
        local dnf_conf = read("/etc/dnf/dnf.conf")
        local function add_param(name, val)
            local n
            dnf_conf, n = dnf_conf:gsub(name.."=(.-)\n", name.."="..val.."\n")
            if n == 0 then dnf_conf = dnf_conf..name.."="..val.."\n" end
        end
        add_param("fastestmirrors", "true")
        add_param("max_parallel_downloads", "10")
        add_param("defaultyes", "true")
        with_tmpfile(function(tmp)
            write(tmp, dnf_conf)
            sh("sudo cp "..tmp.." /etc/dnf/dnf.conf")
        end)
    end

    repo("/etc/yum.repos.d/rpmfusion-free.repo", "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%(RELEASE).noarch.rpm")
    repo("/etc/yum.repos.d/rpmfusion-nonfree.repo", "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%(RELEASE).noarch.rpm")

    dnf_install [[
        dnf-plugins-core dnfdragora
        fedora-workstation-repositories
        git
    ]]

    apt_install [[
        apt-file
        software-properties-common
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

    if not os.getenv "SHELL" :match "/bin/zsh" then
        log "Change current shell"
        sh "chsh -s /bin/zsh %(USER)"
    end

    script ".zprofile"
    script ".zshrc"

    script ".config/starship.toml"

    log "Oh My Zsh"
    gitclone "https://github.com/ohmyzsh/ohmyzsh.git" -- not installed, some scripts will be sourced
    gitclone "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    gitclone "https://github.com/zsh-users/zsh-autosuggestions"

    log "Starship prompt"
    if force or upgrade or not installed "starship" then
        -- The binary downloaded by install.sh is buggy (crashes on non existing directory)
        -- If Rust is installed, building from sources is better.
        if cfg.rust then
            dnf_install "openssl-devel"
            apt_install "gcc libssl-dev"
            gitclone "https://github.com/starship/starship.git"
            sh "cd %(repo_path)/starship && ~/.cargo/bin/cargo install --force --path . --root ~/.local"
        else
            with_tmpfile(function(tmp)
                sh("curl -fsSL https://starship.rs/install.sh -o "..tmp.." && sh "..tmp.." -f -b ~/.local/bin")
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

    if UBUNTU or DEBIAN then
        if not installed "fd" and installed "fdfind" then
            sh "ln -s -f /usr/bin/fdfind ~/.local/bin/fd"
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
    if UBUNTU or DEBIAN then
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

function nextcloud_client_configuration()

    local installed = file_exist "%(HOME)/.local/bin/Nextcloud"
    if force or upgrade or not installed then
        title "Nextcloud configuration"
        local version, new_version
        if installed then
            version = pipe("%(HOME)/.local/bin/Nextcloud -v"):match("version%s+([%d%.]+)")
        end
        new_version = pipe("curl -s https://github.com/nextcloud/desktop/releases/latest/"):match("tag/v([%d%.]+)")
        new_version = new_version == "3.4.3" and "3.4.2"
                   or new_version
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

function nextcloud_server_configuration()

    snap_install "nextcloud"

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
        pmount
        exfatprogs fuse-exfat
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
        p7zip-full
        mc pcmanfm thunar
        pmount
        exfatprogs exfat-fuse
        syslinux
        backintime-common backintime-qt
        timeshift
        cryptsetup
        squashfs-tools squashfuse
        baobab ncdu
        xz-utils 
        archivemount fuseiso sshfs curlftpfs
    ]]
    if UBUNTU then
        apt_install [[
            p7zip-rar
            unrar
        ]]
    end

end

-- }}}

-- Development environment configuration {{{

function dev_configuration()
    title "Development environment configuration"

    if cfg.R then
        dnf_install [[ R ]]
        apt_install [[ r-base r-base-dev ]]
    end

    ppa("/etc/apt/sources.list.d/bartbes-ubuntu-love-stable-%(UBUNTU_CODENAME).list", "ppa:bartbes/love-stable")

    dnf_install [[
        git git-gui gitk qgit gitg tig git-lfs
        git-delta
        subversion
        clang llvm clang-tools-extra
        ccls
        cppcheck
        cmake
        ninja-build
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
        love
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
        golang
        libX11-devel
        libXft-devel
        octave
        libcurl-devel
        libicu-devel ncurses-devel zlib-devel
        libstdc++-static
        gc-devel
    ]]

    apt_install [[
        git git-gui gitk qgit gitg tig git-lfs
        subversion
        clang llvm clang-tidy clang-format clangd clang-tools
        ccls
        cppcheck
        cmake
        ninja-build
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
        love
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
        libpng-dev libtiff-dev
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
    if UBUNTU then apt_install "libjpeg-turbo8-dev" end

    if force or update or not installed "tokei" then
        if cfg.rust then
            log "Tokei"
            sh "~/.cargo/bin/cargo install tokei --root ~/.local"
        end
    end

    if UBUNTU or DEBIAN then
        if force or upgrade or not installed "delta" then
            with_tmpdir(function(tmp)
                local curr_version = pipe("delta --version"):match("[%d%.]+")
                local version = pipe("curl -s https://github.com/dandavison/delta/releases/latest/"):match("tag/([%d%.]+)")
                if version ~= curr_version then
                    log "Delta"
                    sh("wget https://github.com/dandavison/delta/releases/download/"..version.."/git-delta_"..version.."_amd64.deb -O "..tmp.."/delta.deb")
                    sh("sudo dpkg -i "..tmp.."/delta.deb")
                end
            end)
        end
    end

    if force or not file_exist "%(HOME)/.local/bin/lua" or not pipe"ldd %(HOME)/.local/bin/lua":match"readline" then
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
        sh "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring python3 -m pip install --user --upgrade pip"
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

    if cfg.v then
        if force or upgrade or not installed "vls" then
            gitclone "https://github.com/nedpals/tree-sitter-v"
            sh "mkdir -p ~/.vmodules/; ln -sf %(repo_path)/tree-sitter-v ~/.vmodules/tree_sitter_v"
            gitclone("https://github.com/vlang/vls.git")
            sh [[ cd %(repo_path)/vls
                git checkout use-tree-sitter
                ~/.local/bin/v -gc boehm -cc gcc cmd/vls ]]
        end
    end

    if cfg.lazygit then
        if force or upgrade or not installed "lazygit" then
            sh "go install github.com/jesseduffield/lazygit@latest && ln -sf %(HOME)/go/bin/lazygit %(HOME)/.local/bin/lazygit"
        end
    end

    script "ido"

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
    if cfg.haskell then
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
              cd 3rd/luamake &&
              compile/install.sh &&
              cd ../.. &&
              ./3rd/luamake/luamake rebuild &&
              ln -s -f $PWD/bin/lua-language-server ~/.local/bin/ ]]
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
        "parallel",
        "MissingH",
        "timeit",
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

    title "OCaml installation"

    dnf_install [[
        opam
    ]]

    apt_install [[
        opam
    ]]

    if not file_exist "%(HOME)/.opam/config" then
        log "Opam configuration"
        sh "opam init"
        sh "opam update && opam upgrade"
    elseif force then
        log "Opam update"
        sh "opam update && opam upgrade"
    end

    local packages = "dune ocaml-lsp-server merlin utop"

    sh("opam install "..packages)

end

function framac_configuration()

    title "Frama-C installation"

    if not cfg.ocaml then error("Frama-C requires OCaml") end

    dnf_install [[
        z3
        cvc4
    ]]

    apt_install [[
        z3
        cvc4
    ]]

    if force or upgrade or not installed "frama-c" then
        log "Frama-C installation"
        if DEBIAN then
            apt_install "alt-ergo frama-c-base"
        else
            sh "opam install alt-ergo"
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

    dnf_install "curl"
    apt_install "curl"

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
        --{"bottom", "btm"},
        --"hyperfine",
        --"procs",
    }
    for _, package in ipairs(RUST_PACKAGES) do
        local exe = nil
        if type(package) == "table" then
            package, exe = table.unpack(package)
        else
            exe = package
        end
        if force or upgrade or not installed(exe) then
            log("Rust package: "..package)
            sh("~/.cargo/bin/cargo install %(force and '--force' or '') "..package.." --root ~/.local")
        end
    end

end

-- }}}

-- Julia configuration {{{

function julia_configuration()

    if force or not installed "julia" then

        title "Julia configuration"

        --dnf_install [[ julia ]]
        --apt_install [[ julia ]]

        -- [=[
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

    if force or upgrade or not installed "zig" then

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
        local curr_version = pipe("zig version")
        local version = ZIG_ARCHIVE:match("/([%d%.]+)/")

        if version ~= curr_version then
            sh "wget %(ZIG_ARCHIVE) -c -O ~/.local/opt/%(basename(ZIG_ARCHIVE))"
            sh "rm -rf ~/.local/opt/%(ZIG_DIR)"
            sh "tar xJf ~/.local/opt/%(basename(ZIG_ARCHIVE)) -C ~/.local/opt"
            sh "ln -f -s ~/.local/opt/%(ZIG_DIR)/zig ~/.local/bin/zig"
        end
    end

    if force or upgrade or not installed "zls" then
        title "Zig Language Server installation"
        local curr_version = installed_packages.zls_version
        local version = pipe("curl -s https://github.com/zigtools/zls/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            with_tmpdir(function(tmp)
                sh("wget https://github.com/zigtools/zls/releases/download/"..version.."/x86_64-linux.tar.xz -O "..tmp.."/x86_64-linux.tar.xz")
                sh("cd "..tmp.."; tar xJf x86_64-linux.tar.xz && mv bin/zls %(HOME)/.local/bin/zls")
                installed_packages.zls_version = version
            end)
        end
    end

end

-- }}}

-- SWI Prolog {{{

function swipl_configuration()

    if force or upgrade or not file_exist "%(HOME)/.local/bin/swipl" then
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
        doxygen
        gnuplot
        graphviz
    ]]
    if UBUNTU then apt_install "translate-shell" end

end

-- }}}

-- Pandoc configuration {{{

function pandoc_configuration()
    title "Pandoc configuration"

    dnf_install [[
        patat
    ]]
    apt_install [[
        patat
    ]]

    if force or upgrade or not installed "pandoc" then
        local curr_version = pipe("pandoc --version | head -1"):match("[%d%.]+")
        local version = pipe("curl -s https://github.com/jgm/pandoc/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            log "Pandoc"
            with_tmpdir(function(tmp)
                sh("wget https://github.com/jgm/pandoc/releases/download/"..version.."/pandoc-"..version.."-linux-amd64.tar.gz -O "..tmp.."/pandoc.tar.gz")
                sh("tar xvzf "..tmp.."/pandoc.tar.gz --strip-components 1 -C ~/.local")
            end)
        end
    end

    if force or upgrade or not installed "panda" then
        gitclone "http://github.com/cdsoft/panda"
        sh "cd %(repo_path)/panda && make install"
    end

    if force or upgrade or not installed "upp" then
        gitclone "http://github.com/cdsoft/upp"
        sh "cd %(repo_path)/upp && make install"
    end

    if cfg.haskell and cfg.abp then
        if force or upgrade or not installed "abp" then
            gitclone "http://github.com/cdsoft/abp"
            sh "cd %(repo_path)/abp && stack install"
        end
    end

    if cfg.haskell and cfg.pp then
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
        sh "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring pip3 install --user blockdiag seqdiag actdiag nwdiag"
    end

    if force or upgrade or not installed "mmdc" then
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
        graphviz plantuml
    ]]
    apt_install [[
        texlive texlive-full
        graphviz plantuml
    ]]

end

-- }}}

-- Asymptote configuration {{{

function asymptote_configuration()
    if cfg.asymptote_sources then
        if force or update or not file_exist "%(HOME)/.local/bin/asy" then
            log "Asymptote"
            gitclone "https://github.com/vectorgraphics/asymptote"
            sh [[ cd %(repo_path)/asymptote && ./autogen.sh ]]
            sh [[ cd %(repo_path)/asymptote && ./configure --prefix=%(HOME)/.local ]]
            sh [[ cd %(repo_path)/asymptote && make all -j 4 ]]
            sh [[ cd %(repo_path)/asymptote && make install ]]
        end
    else
        dnf_install "asymptote"
        apt_install "asymptote"
    end
end

-- }}}

-- neovim configuration {{{

function neovim_configuration()
    title "neovim configuration"

    copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:agriffis:neovim-nightly.repo", "agriffis/neovim-nightly")

    ppa("/etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-%(UBUNTU_CODENAME).list", "ppa:neovim-ppa/unstable")

    dnf_install [[
        neovim
        fzf
        ccrypt pwgen
        gzip
        jq
        xclip
    ]]
    apt_install [[
        neovim
        fzf
        ccrypt pwgen
        gzip
        jq
        xclip
    ]]

    sh "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring pip3 install --user pynvim"

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
    local function nvim_cp(msg, candidates, dest)
        for _, src in ipairs(candidates) do
            if file_exist(src) then
                log(msg)
                mkdir(dirname(dest))
                sh("cp "..src.." "..dest)
                return
            end
        end
    end
    nvim_cp("Asymptote syntax",
        { "%(HOME)/.local/share/asymptote/asy.vim",
          "/usr/share/asymptote/asy.vim",
          "/usr/share/vim/addons/syntax/asy.vim",
        },
        "%(HOME)/.config/nvim/syntax/asy.vim"
    )
    nvim_cp("Asymptote syntax detection",
        { "%(HOME)/.local/share/asymptote/asy_filetype.vim",
          "/usr/share/asymptote/asy_filetype.vim",
          "/usr/share/vim/addons/ftdetect/asy_filetype.vim",
        },
        "%(HOME)/.config/nvim/ftdetect/asy_filetype.vim"
    )

    -- update all plugins
    if force or upgrade then
        log "Pluggin update"
        sh "nvim -c PlugUpgrade -c PlugInstall -c PlugUpdate -c qa"
    end

    if cfg.haskell then
        if force or upgrade or not installed "shellcheck" then
            log "ShellCheck"
            sh "stack install --resolver=%(LATEST_LTS) ShellCheck"
        end
    else
        dnf_install "ShellCheck"
        apt_install "shellcheck"
    end

    -- Notes, TO-DO lists and password manager
    if WIKI ~= "~" then
        mkdir "%(WIKI)"
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
        xfce4-settings
        xfce4-screenshooter
        xsetroot
        xfce4-notifyd
        xfce4-volumed
        barrier
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
        barrier
    ]]
    if UBUNTU then
        apt_install "xfce4-volumed"
    end

    -- alacritty
    if force or upgrade or not installed "alacritty" then
        log "Alacritty"
        if cfg.rust then
            dnf_install [[ cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ ]]
            apt_install [[ cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 ]]
            sh "~/.cargo/bin/cargo install alacritty --root ~/.local"
        elseif FEDORA then
            dnf_install "alacritty"
        elseif UBUNTU then
            ppa("/etc/apt/sources.list.d/aslatter-ubuntu-ppa-%(UBUNTU_CODENAME).list", "ppa:aslatter/ppa")
            apt_install "alacritty"
        elseif DEBIAN then
            error("Rust is required to install alacritty on Debian")
        end
    end

    -- urxvt
    if force or upgrade or not file_exist "%(HOME)/.urxvt/ext/font-size" then
        log "Urxvt font-size"
        gitclone "https://github.com/majutsushi/urxvt-font-size"
        mkdir "%(HOME)/.urxvt/ext/"
        sh "cp %(repo_path)/urxvt-font-size/font-size %(HOME)/.urxvt/ext/"
    end

    -- st
    if force or upgrade or not file_exist "%(HOME)/.local/bin/st" then
        log "st"
        local version = "0.8.4"
        gitclone("https://git.suckless.org/st")
        sh "cd %(repo_path)/st && git reset --hard master && git checkout master && git clean -dfx && git fetch && git rebase"
        sh("cd %(repo_path)/st && git checkout "..version)
        sh[[cd %(repo_path)/st && sed -i 's/font =.*/font = "%(FONT):size=%(FONT_SIZE):antialias=true:autohint=true";/' config.def.h]]
        local function patch(url)
            local file = repo_path.."/st-patches/"..basename(url)
            if not file_exist(file) then
                mkdir(dirname(file))
                sh("wget "..url.." -O "..file)
            end
            sh("cd %(repo_path)/st && patch -p1 < "..file)
        end
        patch "https://st.suckless.org/patches/dynamic-cursor-color/st-dynamic-cursor-color-0.8.4.diff"
        patch "https://st.suckless.org/patches/moonfly/st-moonfly-0.8.2.diff"
        patch "https://st.suckless.org/patches/right_click_to_plumb/simple_plumb.diff"
        patch "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff"
        patch "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20191024-a2c479c.diff"
        --patch "https://st.suckless.org/patches/undercurl/st-undercurl-0.8.4-20210822.diff"
        --patch "https://st.suckless.org/patches/universcroll/st-universcroll-0.8.4.diff"

        -- Same colors than Alacritty

        local colors = {
            -- /* 8 normal colors */
            [0] = "#000000",
            [1] = "#cd3131",
            [2] = "#0dbc79",
            [3] = "#e5e510",
            [4] = "#2472c8",
            [5] = "#bc3fbc",
            [6] = "#11a8cd",
            [7] = "#e5e5e5",

            -- /* 8 bright colors */
            [8] = "#666666",
            [9] = "#f14c4c",
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
            [259]= "#eeeeee",
        }
        with_file("%(repo_path)/st/config.def.h", function(config)
            for i, c in pairs(colors) do
                config = config:gsub('(%['..i..'%]) = "(#......)"', '%1 = "'..c..'"')
            end
            return config
        end)

        sh[[cd %(repo_path)/st && sed -i 's#PREFIX =.*#PREFIX = %(HOME)/.local#' config.mk]]
        sh[[cd %(repo_path)/st && sed -i 's#MANPREFIX =.*#MANPREFIX = %(HOME)/.local/man#' config.mk]]
        sh "cd %(repo_path)/st && make install"
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
    if cfg.thunderbird_mailer then
        mime_default "mozilla-thunderbird.desktop"
    end
    mime_default "atril.desktop"
    mime_default "thunar.desktop"
    mime_default "ristretto.desktop" -- shall be configured after atril to overload atril associations
    mime_default "vlc.desktop"
    mime_default "wireshark.desktop"
    mime_default "nvim.desktop"

    script ".config/alacritty/alacritty.yml"
    script ".Xdefaults"

    script ".config/i3/config"
    script ".xsession"
    script ".xsessionrc"

    script ".config/dunst/dunstrc"

    script ".config/rofi/config.rasi"

    script "wallpaper_of_the_day"
    script "every"

    script "xi3"

    script ".config/gtk-3.0/settings.ini"
    script ".config/qt5ct/qt5ct.conf"
    script ".gtkrc-2.0"

    if force or upgrade or not installed "xcwd" then
        log "xcwd"
        gitclone "https://github.com/CDSoft/xcwd.git"
        sh "cd %(repo_path)/xcwd && make && make install"
    end

    if FEDORA then
        if force or upgrade or not installed "hsetroot" then
            dnf_install "imlib2-devel libXinerama-devel"
            gitclone "https://github.com/himdel/hsetroot"
            sh "cd %(repo_path)/hsetroot && make && DESTDIR=%(HOME) PREFIX=/.local make install"
        end
    end
    if UBUNTU or DEBIAN then
        apt_install "hsetroot"
    end

    pipe("base64 -d > ~/.config/i3/empty.wav", "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=")

    script ".config/i3/status"
    sh "sudo setcap cap_net_admin=ep %(pipe 'which i3status')"

    script "lock"

    script "screenshot"

    script "lrandr"

    script "menu"
    script "idle"

    script "brightness"
    script "notify_volume"

    script ".config/volumeicon/volumeicon"

    -- start VLC in a single instance
    if file_exist "%(HOME)/.config/vlc/vlcrc" then
        log "VLC configuration"
        with_file("%(HOME)/.config/vlc/vlcrc", function(vlcrc)
            return vlcrc:gsub('#?one%-instance=[01]', "one-instance=1")
        end)
    end

    -- Xfce configuration for i3
    for config_file in ls ".config/xfce4/terminal/*" do
        script(config_file)
    end
    for config_file in ls ".config/xfce4/xfconf/xfce-perchannel-xml/*" do
        script(config_file)
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
        xournal
        curl

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
        xournal
        curl

        vlc ffmpeg
    ]]

    -- GeoGebra
    if cfg.geogebra then
        if force or update or not installed "geogebra" then
            title "GeoGebra installation"
            local GEOGEBRA_URL = "https://download.geogebra.org"
            local GEOGEBRA_REDIR
            pipe("curl -i "..GEOGEBRA_URL.."/package/linux-port6"):gsub("Location:%s*(.*)", function(redir)
                GEOGEBRA_REDIR = GEOGEBRA_URL..redir:trim()
            end)
            if not file_exist("~/.local/opt/"..fs.basename(GEOGEBRA_REDIR)) then
                sh("curl --output-dir ~/.local/opt/ -O "..GEOGEBRA_REDIR)
            end
            sh("cd ~/.local/opt/ && rm -rf GeoGebra-linux-x64 && unzip "..fs.basename(GEOGEBRA_REDIR))
            sh("ln -f -s ~/.local/opt/GeoGebra-linux-x64/GeoGebra ~/.local/bin/geogebra")
        end
    end

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

    if cfg.chrome then
        if FEDORA then sh "sudo dnf config-manager --set-enabled google-chrome" end
        if UBUNTU or DEBIAN then
            deblist("/etc/apt/sources.list.d/google-chrome.list", "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main")
            sh "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
        end
        dnf_install "google-chrome-stable"
        apt_install "google-chrome-stable"
    end
    if cfg.chromium then
        dnf_install "chromium"
        apt_install "chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra"
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
    apt_install [[
        myspell-tools
        myspell-fr-fr myspell-fr-gut
        myspell-uk
    ]]
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
            if UBUNTU or DEBIAN then
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

        if UBUNTU or DEBIAN then
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
        qemu-system-x86
    ]]
    apt_install [[
        virtualbox-qt
        virtualbox-ext-pack
        virtualbox-guest-additions-iso
        qemu-system-x86
    ]]
    dnf_install "akmod-VirtualBox kernel-devel-%(pipe 'uname -r')"
    apt_install "virtualbox-dkms linux-headers-%(pipe 'uname -r')"
    if UBUNTU or DEBIAN then
        sh "sudo modprobe vboxdrv"
    end

    script "vm"
    script "sshfs-host"
    script "sshfs-mount"

end

-- }}}

-- Work configuration {{{

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
        sh "PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring pip3 install --user awscli boto3"
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

    if cfg.move_docker_to_home then
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

    sh [[ export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
          pip3 install '--user'             \
                awscli                      \
                click                       \
                junit-xml                   \
                matplotlib                  \
                pyaml                       \
                python-can                  \
                scipy                       \
                tftpy                       \
    ]]

    -- ROS: http://wiki.ros.org/Installation/Source
    if cfg.ros then
        if FEDORA then
            copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:thofmann:ros.repo", "thofmann/ros")
            if tonumber(OS_RELEASE_VERSION_ID) <= 34 then
                dnf_install [[
                    ros-desktop_full-devel
                ]]
            else
                dnf_install [[
                    ros-ros_base
                    ros-ros_base-devel
                ]]
            end
        end
                --[=[ WARNING: this does not seem to work!
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
                        rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall;
                        mkdir -p src;
                        vcs import --input noetic-desktop.rosinstall ./src;
                        rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y;
                        ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3;
                    ]]
                end
                --]=]
        if UBUNTU or DEBIAN then
            apt_install [[
                ros-desktop-full
                ros-desktop-full-dev
            ]]
        end
    end

    if cfg.lazydocker then
        if force or upgrade or not installed "lazydocker" then
            sh "go install github.com/jesseduffield/lazydocker@latest && ln -sf %(HOME)/go/bin/lazydocker %(HOME)/.local/bin/lazydocker"
        end
    end

    -- VPN
    if UBUNTU or DEBIAN then
        if not installed "AVPNC" then
            -- https://docs.aviatrix.com/Downloads/samlclient.html#debian-ubuntu
            apt_install "gedit resolvconf"
            with_tmpdir(function(tmp)
                sh("wget https://aviatrix-download.s3-us-west-2.amazonaws.com/AviatrixVPNClient/AVPNC_linux_FocalFossa.deb -O "..tmp.."/AVPNC_linux_FocalFossa.deb")
                sh("sudo dpkg -i "..tmp.."/AVPNC_linux_FocalFossa.deb")
            end)
        end
    end
    if FEDORA then
        if not file_exist "/etc/resolv.conf.orig" then
            dnf_install "NetworkManager-openvpn-gnome"
            sh "systemctl disable --now systemd-networkd"
            if file_exist "/etc/resolv.conf" then
                sh "sudo mv /etc/resolv.conf /etc/resolv.conf.orig"
            end
            sh "systemctl restart NetworkManager"
        end
    end

end

-- }}}

os.exit(main())
