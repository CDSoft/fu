#!/bin/env luax
-- vim: set ts=4 sw=4 foldmethod=marker :

--[[====================================================================
Fedora Updater (fu): lightweight Fedora « distribution »

Copyright (C) 2018-2023 Christophe Delord
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

F = require "F"
fs = require "fs"
term = require "term"

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
    - and much more (Use the source, Luke!)

options:
    -h          help
    -f          force update
    -u          upgrade packages
    -r          reset

hooks:
    ~/.myconf       various parameters
        starship    custom configuration added to starship.toml
        i3          custom configuration added to the i3 configuration
        zsh         additional definitions loaded at the end of .zshrc
        keepass     path to the keepassxc database
        remote      list of remote targets reachable with sshfs and vifm
]]
end

function fu_configuration()
    HOME = os.getenv "HOME"
    USER = os.getenv "USER"

    myconf = {}
    if fs.is_file(HOME/".myconf") then
        assert(loadfile(HOME/".myconf", "t", myconf))()
    end

    fu_path = I"%(HOME)/.config/fu"
    config_path = I"%(fu_path)/config"
    repo_path = I"%(fu_path)/repos"
    src_files = dirname(pipe "realpath %(arg[0])").."/files"

    configured              = db(config_path/"configured.lua")
    installed_packages      = db(config_path/"packages.lua")
    installed_snap_packages = db(config_path/"snap_packages.lua")
    installed_lua_packages  = db(config_path/"lua_packages.lua")
    installed_pip_packages  = db(config_path/"pip_packages.lua")

    cfg = interactive(config_path/"config.lua") {

        powertop = {"Install powertop?", "yn"},

        hostname = {"Hostname:", "str"},
        wiki = {"Wiki directory (e.g.: ~/Nextcloud/Wiki):", "str"},
        git_user_email = {"Git user email:", "str"},
        git_user_name = {"Git user name:", "str"},

        picom = {"Start picom?", "yn"},
        numlockx = {"Enable numclockx?", "yn"},
        external_monitor = {"Add shortcuts for external monitor?", "yn"},
        i3_fnkeys = {"Use Fn keys to change workspaces?", "yn"},
        wallpaper = {"Use daily wallpaper?", "yn"},
        wallpaper_nasa = {"Use NASA wallpaper?", "yn"},
        wallpaper_bing = {"Use BING wallpaper?", "yn"},
        rfkill_on_suspend = {"kill RF on suspend?", "yn"},

        chromium_as_alternative_browser = {"Use Chromium as alternative browser?", "yn"},
        thunderbird_mailer = {"Use Thunderbird as the default mailer?", "yn"},
        chromium = {"Install Chromium?", "yn"},

        nerd_fonts = {"Install Nerd Fonts?", "yn"},
        fira_code = {"Use Fira Code font?", "yn"},
        source_code_pro = {"Use Source Code Pro font?", "yn"},
        alacritty_sources = {"Install Alacritty from sources?", "yn"},
        wezterm = {"Install WezTerm?", "yn"},
        starship_sources = {"Install Starship from sources?", "yn"},
        tokei_sources = {"Install Tokei from sources?", "yn"},
        ninja_sources = {"Install Ninja from sources?", "yn"},
        haskell = {"Install Haskell?", "yn"},
        ocaml = {"Install OCaml?", "yn"},
        racket = {"Install Racket?", "yn"},
        julia = {"Install Julia?", "yn"},
        swipl = {"Install SWI Prolog (from sources)?", "yn"},
        zig = {"Install Zig?", "yn"},
        wasmer = {"Install Wasmer?", "yn"},
        frama_c = {"Install Frama-C?", "yn"},
        rust = {"Install Rust?", "yn"},
        v = {"Install V?", "yn"},
        vls = {"Install V Language Server?", "yn"},
        R = {"Install R?", "yn"},
        asymptote_sources = {"Install Asymptote from sources?", "yn"},
        geogebra = {"Install GeoGebra?", "yn"},
        freepascal = {"Install Free Pascal?", "yn"},
        freepascal_language_server = {"Install Pascal Language Server?", "yn"},
        nim = {"Install Nim?", "yn"},
        nim_language_server = {"Install Nim Language Server?", "yn"},
        vscode = {"Install VSCode?", "yn"},
        tup = {"Install tup?", "yn"},
        --compile_pandoc_with_cabal = {"Compile Pandoc with Cabal?", "yn"},
        --compile_typst_with_rust = {"Compile Typst with Rust?", "yn"},
        helix = {"Install Helix?", "yn"},
        helix_sources = {"Install Helix from sources?", "yn"},

        latex = {"Install LaTeX?", "yn"},
        povray = {"Install Povray?", "yn"},
        lazygit = {"Install lazygit?", "yn"},
        lazydocker = {"Install lazydocker?", "yn"},

        zoom = {"Install Zoom?", "yn"},

        virtualization = {"Install virtualization tools?", "yn"},

        work = {"Install work configuration?", "yn"},
        ros = {"Install ROS?", "yn"},
        move_docker_to_home = {"Move /var/lib/docker to /home/docker?", "yn"},
        work_vpn = {"Install work VPN configuration?", "yn"},

        nextcloud_client = {"Install Nextcloud client?", "yn"},
        nextcloud_client_start = {"Start Nextcloud client after boot?", "yn"},
        dropbox = {"Install Dropbox?", "yn"},

        startvlc = {"Autostart VLC in the systray?", "yn"},
        minidlna = {"Install minidlna?", "yn"},
        kodi = {"Install Kodi?", "yn"},

        devel = {"Install extended development packages?", "yn"},
        tokei = {"Install tokei?", "yn"},
        delta = {"Install delta?", "yn"},
        pmccabe = {"Install PMcCabe?", "yn"},

        bash_language_server = {"Install bash language server?", "yn"},
        dot_language_server = {"Install dot (Graphviz) language server?", "yn"},
        python_language_server = {"Install Python language server?", "yn"},
        lua_language_server = {"Install Lua language server?", "yn"},
        teal_language_server = {"Install Teal language server?", "yn"},
        zig_language_server = {"Install Zig language server?", "yn"},
        typescript_language_server = {"Install Typescript language server?", "yn"},
        purescript_language_server = {"Install Purescript language server?", "yn"},
        elm_language_server = {"Install ELM language server?", "yn"},
        typst_language_server = {"Install Typst language server?", "yn"},
        swipl_language_server = {"Install Prolog language server?", "yn"},

        patat = {"Install patat?", "yn"},
        blockdiag = {"Install blockdiag?", "yn"},
        mermaid = {"Install mermaid?", "yn"},
        penrose = {"Install penrose?", "yn"},
        asymptote = {"Install Asymptote?", "yn"},
        shellcheck = {"Install ShellCheck?", "yn"},

        compile_shellcheck_with_stack = {"Compile ShellCheck with stack?", "yn"},
        compile_typst_lsp_with_cargo = {"Compile Typst LSP with cargo?", "yn"},

        logitech_tools = {"Install Logitech tools?", "yn"},

        screenshot_with_gimp = {"Take screenshots with ImageMagick and Gimp?", "yn"},
        screenshot_with_ksnip = {"Take screenshots with ksnip?", "yn"},

    }
end

function os_configuration()

    LUA_VERSION = "5.4.7"

    TIMEZONE = "Europe/Paris"
    KEYMAP = "fr"
    LOCALE = "fr_FR.UTF-8"

    I3_THEME = "green" -- "blue" (default), "green"
    FONT = "Fira Code"
    FONT_VARIANT = "Medium"
    if cfg.fira_code then
        FONT = cfg.nerd_fonts and "FiraCode Nerd Font" or "Fira Code"
    elseif cfg.source_code_pro then
        FONT = cfg.nerd_fonts and "SauceCodePro Nerd Font" or "Source Code Pro"
    else
        FONT = cfg.nerd_fonts and "FiraCode Nerd Font" or "Fira Code"
    end
    dnf_install "xdpyinfo"
    local xres, yres = (pipe "xdpyinfo | awk '/dimensions/ {print $2}'" or "1920x1080") : split "x" : map(tonumber) : unpack()
    FONT_SIZE =    (xres <= 1920 or yres <= 1080) and 9
                or (xres <= 2560 or yres <= 1440) and 9+4
                or                                    9+8
    I3_INPUT_FONT = "-*-*-*-*-*-*-20-*-*-*-*-*-*-*"
    ST = I"st"
    ALACRITTY = I"alacritty"

    BROWSER = "firefox"
    BROWSER2 = cfg.chromium_as_alternative_browser and "chromium-browser" or
               BROWSER

    WIKI = cfg.wiki
    if WIKI == "" then WIKI = "~" end
    WIKI = WIKI:gsub("^~", os.getenv "HOME" or "~")

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
    luax_configuration()
    if cfg.rust then rust_configuration() end
    shell_configuration()
    network_configuration()
    if cfg.dropbox then dropbox_configuration() end
    if cfg.nextcloud_client then nextcloud_client_configuration() end
    filesystem_configuration()
    if cfg.v then v_configuration() end
    dev_configuration()
    if cfg.haskell then haskell_configuration() end
    if cfg.ocaml then ocaml_configuration() end
    if cfg.frama_c then framac_configuration() end
    if cfg.racket then racket_configuration() end
    if cfg.julia then julia_configuration() end
    if cfg.zig then zig_configuration() end
    if cfg.wasmer then wasmer_configuration() end
    if cfg.nim then nim_configuration() end
    if cfg.swipl then swipl_configuration() end
    lsp_configuration()
    text_edition_configuration()
    if cfg.latex then latex_configuration() end
    if cfg.asymptote then asymptote_configuration() end
    pandoc_configuration()
    neovim_configuration()
    if cfg.helix then helix_configuration() end
    if cfg.vscode then vscode_configuration() end
    i3_configuration()
    graphic_application_configuration()
    if cfg.povray then povray_configuration() end
    internet_configuration()
    if cfg.zoom then zoom_configuration() end
    if cfg.virtualization then virtualization_configuration() end
    if cfg.work then work_configuration() end
    if cfg.work_vpn then work_vpn_configuration() end

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
        answer = term.prompt(question.." [y/n] "):lower():trim():head()
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
        local conf = F.keys(params):map(function(k)
            local v = params[k]
            local fmt = type(v) == "string" and "%q" or "%s"
            return ("_ENV['%%s'] = %s\n"):format(fmt):format(k, v)
        end)
        mkdir(filename:dirname())
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
                        answer = term.prompt(question.." [y/n] "):lower():trim():head()
                    until answer:match "[yn]"
                    return answer:match "y" == "y"
                end,
                ["str"] = function(question)
                    local answer = nil
                    repeat
                        answer = term.prompt(question.." "):trim()
                    until #answer > 0
                    return answer
                end,
                ["num"] = function(question)
                    local answer = nil
                    repeat
                        answer = term.prompt(question.." "):trim()
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

I = F.I(_G) % "%%()"

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
    function self.has(name) return set[name] end
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

dirname = F.compose{fs.dirname, I}
basename = F.compose{fs.basename, I}

file_exist = F.compose{fs.is_file, I}
dir_exist = F.compose{fs.is_dir, I}

function read(path, opt)
    opt = opt or {}
    local content = fs.read(I(path))
    if not opt.raw then
        content = I(content)
    end
    return content
end

function write(path, content, opt)
    opt = opt or {}
    -- atomic file creation to avoid strange interactions with xfce and fonts
    local filename = I(path)
    if not opt.raw then
        content = I(content)
    end
    fs.write(filename..".tmp", content)
    os.rename(filename..".tmp", filename)
end

function modify(path, mod)
    write(path, mod(read(path)))
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
    return fs.read(I(path)):lines()
end

function pipe(cmd, stdin)
    local sh = require "sh"
    cmd = I(cmd)
    if stdin then
        sh.write(cmd)
    else
        local result = sh.read(cmd)
        if result then
            return I(result:trim())
        end
    end
end

function ls(pattern)
    local files = arg[0]:realpath():dirname()/"files"
    local names = fs.glob(files/ I(pattern))
        : map(function(name) return name:sub(#files+2) end)
    local i = 0
    return function()
        i = i+1
        return names[i]
    end
end

with_tmpfile = fs.with_tmpfile
with_tmpdir = fs.with_tmpdir

function with_file(name, f)
    local content = read(name)
    content = f(content)
    write(name, content)
end

function sh(...)
    local sh = require "sh"
    assert(sh.run(F{...}:flatten():map(I)))
end

function download(url)
    local sh = require "sh"
    return assert(sh.read("curl", "-sSL", I(url)))
end

mkdir = F.compose{fs.mkdirs, I}

rm = F.compose{os.remove, I}

function identification()
    local function os_release(param) return pipe(". /etc/os-release; echo $"..param) end
    OS_RELEASE_NAME         = os_release "NAME"
    OS_RELEASE_PRETTY_NAME  = os_release "PRETTY_NAME"
    OS_RELEASE_ID           = os_release "ID"
    OS_RELEASE_VERSION_ID   = os_release "VERSION_ID"

    title(OS_RELEASE_PRETTY_NAME)

    RELEASE = pipe "rpm -E %fedora"

    MYHOSTNAME = cfg.hostname
    log "hostname: %(MYHOSTNAME)"
    log "username: %(USER)"
end

function repo(local_name, name)
    if not file_exist(I(local_name)) then
        name = I(name)
        log("Install repo "..name, 1)
        sh("sudo dnf install -y \""..name.."\"")
    end
end

function copr(local_name, name)
    if not file_exist(local_name) then
        name = I(name)
        log("Install copr "..name, 1)
        sh("sudo dnf copr enable \""..name.."\"")
    end
end

function dnf_install(names)
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if force or update or not installed_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install packages: "..names, 1)
        sh("sudo dnf install "..names.." --skip-broken --best --allowerasing")
        F(new_packages):map(function(name) installed_packages[name] = true end)
    end
end

function pip_install(names)
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if force or update or not installed_pip_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = table.concat(new_packages, " ")
        log("Install pip: "..names, 1)
        sh("PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring pip install --user "..names)
        F(new_packages):map(function(name) installed_pip_packages[name] = true end)
    end
end

function luarocks(names, opts)
    names = I(names):words()
    local new_packages = {}
    for _, name in ipairs(names) do
        if not installed_lua_packages[name] then table.insert(new_packages, name) end
    end
    if #new_packages > 0 then
        names = F(new_packages):unwords()
        log("Install luarocks: "..names, 1)
        for _, name in ipairs(new_packages) do
            sh("luarocks install --local "..(opts or "").." "..name)
        end
        F(new_packages):map(function(name) installed_lua_packages[name] = true end)
    end
end

function upgrade_packages()
    if force or upgrade then
        title "Upgrade packages"
        sh "sudo dnf update --refresh"
        sh "sudo dnf upgrade"
    end
end

function installed(cmd)
    local found = (os.execute("hash "..I(cmd).." 2>/dev/null"))
    return found
end

function script(name, opt)
    opt = opt or {}
    local function template(file_name, dest_name, exe)
        if file_exist(file_name) then
            log("Create "..dest_name, 2)
            mkdir(dirname(dest_name))
            write(dest_name, read(file_name, opt), opt)
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
            sh("cd "..path.." && ( git stash && ( (git checkout master && git reset --hard master) || (git checkout main && git reset --hard main) || true ) ) && git pull")
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

    repo("/etc/yum.repos.d/rpmfusion-free.repo", "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%(RELEASE).noarch.rpm")
    repo("/etc/yum.repos.d/rpmfusion-nonfree.repo", "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%(RELEASE).noarch.rpm")

    dnf_install [[
        dnf-plugins-core dnfdragora
        git
        curl wget
        xmlstarlet
    ]]

    if installed "/usr/sbin/updatedb" then
        sh "sudo dnf remove plocate"
    end

    -- Locale and timezone
    log "Timezone and keyboard"
    sh "sudo timedatectl set-timezone %(TIMEZONE)"
    sh "sudo localectl set-keymap %(KEYMAP)"
    sh "sudo localectl set-locale %(LOCALE)"

    -- No more poweroff
    log "Disable power key"
    if file_exist "/etc/systemd/logind.conf" then
        sh "sudo sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf"
    end

    if cfg.powertop then

        log "Powertop autotune"
        dnf_install "powertop"
        sh("sudo systemctl start powertop.service")
        sh("sudo systemctl enable powertop.service")

    end

    -- Higher inotify limits
    with_tmpfile(function(tmp)
        write(tmp, [[
fs.inotify.max_user_instances = 2048
#fs.inotify.max_user_watches = 121880
]])
        sh("sudo cp "..tmp.." /etc/sysctl.d/99-inotify_limits.conf")
        sh("sudo sysctl -p /etc/sysctl.d/99-inotify_limits.conf")
    end)

end

-- }}}

-- luax packages {{{

function luax_configuration()
    title "luax configuration"

    if force or upgrade or not installed "bang" or not installed "ypp" or not installed "panda" then
        sh "curl -sSL https://cdelord.fr/pub/luax-full.sh | sh"
    end

end

-- }}}

-- Shell configuration {{{

function shell_configuration()
    title "Shell configuration"

    dnf_install [[
        zsh
        powerline-fonts
        bat
        PackageKit-command-not-found
        util-linux-user
        inotify-tools
        htop
        btop
        pwgen
        ripgrep
        eza
        fd-find
        tmux
        tldr
        the_silver_searcher
        hexyl
        zoxide
        dialog
        sqlite
        openssl-devel cmake gcc
        curl
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
    if force or not installed "starship" then
        -- The binary downloaded by install.sh is buggy (crashes on non existing directory)
        -- If Rust is installed, building from sources is better.
        if cfg.rust and cfg.starship_sources then
            gitclone "https://github.com/starship/starship.git"
            sh "cd %(repo_path)/starship && ~/.cargo/bin/cargo install --locked --force --path . --root ~/.local"
        else
            with_tmpfile(function(tmp)
                sh("curl -fsSL https://starship.rs/install.sh -o "..tmp.." && sh "..tmp.." -f -b ~/.local/bin")
            end)
        end
    end

    script "vi"

    gitclone "https://github.com/junegunn/fzf.git"
    sh "cd %(repo_path)/fzf && ./install --key-bindings --completion --no-update-rc"
    gitclone "https://github.com/junegunn/fzf-git.sh.git"

    script ".tmux.conf"

    script "fzfmenu"

    script "clean_path"

    if force or not installed "grc" then
        gitclone "https://github.com/garabik/grc"
        sh "cd %(repo_path)/grc && sudo ./install.sh"
    end

    script "tm" -- tmux helper

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
        lftp
        chkconfig
    ]]

    -- hostname
    sh "sudo hostname %(MYHOSTNAME)"
    rootfile("/etc/hostname", "%(MYHOSTNAME)\n")

    -- ssh
    log "sshd"
    sh "sudo systemctl start sshd"
    sh "sudo systemctl enable sshd"

    log "Disable firewalld"
    sh "sudo systemctl disable firewalld" -- firewalld fails to stop during shutdown.

    script "ssha"

    -- sshd
    log "sshd"
    sh "sudo chkconfig sshd on"
    sh "sudo service sshd start"

    -- wireshark
    log "Wireshark group"
    sh "sudo usermod -a -G wireshark %(USER)"

end

-- }}}

-- Dropbox configuration {{{

function dropbox_configuration()

    dnf_install [[ PyQt4 libatomic ]]

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
        new_version = pipe("curl -sSL https://github.com/nextcloud-releases/desktop/releases/")
            : matches "tag/v([%d%.]+)\""
            : map(function(v) return v:split"%." end)
            : maximum(F.op.ule)
            : str "."
        --[[
        new_version = new_version == "3.9.0" and "3.8.2"
                   or new_version
        --]]
        if new_version ~= version then
            if version then sh("%(HOME)/.local/bin/Nextcloud -q") end
            with_tmpdir(function(tmp)
                sh("wget https://github.com/nextcloud-releases/desktop/releases/download/v"..new_version.."/Nextcloud-"..new_version.."-x86_64.AppImage -O "..tmp.."/Nextcloud")
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

    -- cryfs is already in the Fedora repository
    --copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:fcsm:cryfs.repo", "fcsm/cryfs")

    dnf_install [[
        gparted
        pcmanfm thunar
        backintime-common backintime-qt4
        timeshift
    ]]

    dnf_install [[
        udftools
        encfs
        cryfs
        p7zip p7zip-gui p7zip-plugins
        mc vifm
        pmount
        exfatprogs fuse-exfat
        syslinux
        cryptsetup
        squashfs-tools squashfuse
        baobab ncdu qdirstat
        xz unrar lzip lz4
        archivemount sshfs curlftpfs
        fuse-zip
        zstd
    ]]

    script ".config/vifm/vifmrc"
    script ".config/vifm/colors/christophe.vifm"

    gitclone "https://github.com/vifm/vifm-colors"
    sh "cp -f %(repo_path)/vifm-colors/*.vifm %(HOME)/.config/vifm/colors/"

    gitclone "https://github.com/thimc/vifm_devicons"
    sh "cp -f %(repo_path)/vifm_devicons/favicons.vifm %(HOME)/.config/vifm/"

    -- 7Z
    do
        local curr_version = (pipe("7zzs") or ""):words()[3]
        local version = pipe("curl -sSL https://github.com/ip7z/7zip/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            log "7z"
            with_tmpdir(function(tmp)
                sh("wget https://github.com/ip7z/7zip/releases/download/"..version.."/7z"..(version:gsub("%.", "")).."-linux-x64.tar.xz -O "..tmp.."/7z.tar.xz")
                sh("cd "..tmp.." && tar -xvJf 7z.tar.xz --exclude=MANUAL --exclude='*.txt'")
                sh("cp -af "..tmp.."/7zz* ~/.local/bin")
            end)
        end
    end

end

-- }}}

-- Development environment configuration {{{

function dev_configuration()
    title "Development environment configuration"

    if cfg.R then
        dnf_install [[ R ]]
    end

    dnf_install [[
        git git-gui meld
        gtksourceview5
    ]]

    if cfg.devel then
        dnf_install [[
            git git-gui gitk qgit gitg tig git-lfs
            git-delta
            subversion
            clang llvm clang-tools-extra llvm-devel clang-devel lld-devel
            cppcheck
            cmake
            ninja-build
            ncurses-devel
            readline-devel
            meld
            pl pl-xpce pl-devel
            libev-devel startup-notification-devel xcb-util-devel xcb-util-cursor-devel xcb-util-keysyms-devel xcb-proto xcb-util-wm-devel xcb-util-xrm-devel libxkbcommon-devel libxkbcommon-x11-devel yajl-devel
            gcc-gnat
            pypy
            lua
            luarocks
            lua-devel
            love
            glfw
            flex bison
            perl-ExtUtils-MakeMaker
            SDL2-devel SDL2_ttf-devel SDL2_gfx-devel SDL2_mixer-devel SDL2_image-devel SDL2_net-devel
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
            protobuf-devel python3-protobuf
            xz-devel zlib-devel
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
            doxygen
            graphviz
            musl-clang musl-devel musl-gcc musl-libc-static musl-libc
            pax-utils
            sassc
            glfw-devel glm-devel glew-devel
            libtool
        ]]
    end

    if cfg.freepascal then
        dnf_install [[
            fpc lazarus
        ]]
    end

    if cfg.tokei and (force or update or not installed "tokei") then
        if cfg.rust and cfg.tokei_sources then
            log "Tokei"
            sh "~/.cargo/bin/cargo install tokei --root ~/.local"
        else
            dnf_install [[
                tokei
            ]]
        end
    end

    if cfg.ninja_sources and (force or not file_exist "%(HOME)/.local/bin/ninja") then
        log "Ninja"
        gitclone "https://github.com/ninja-build/ninja"
        sh [[
            cd %(repo_path)/ninja &&
            ./configure.py --bootstrap &&
            strip ninja &&
            install ninja %(HOME)/.local/bin/
        ]]
    end

    if force or not file_exist "%(HOME)/.local/bin/lua" or not pipe"ldd %(HOME)/.local/bin/lua":match"readline" then
        log "Lua"
        sh [[
            cd %(repo_path) &&
            curl -R -O https://www.lua.org/ftp/lua-%(LUA_VERSION).tar.gz &&
            rm -rf lua-%(LUA_VERSION) &&
            tar zxf lua-%(LUA_VERSION).tar.gz &&
            cd lua-%(LUA_VERSION) &&
            sed -i 's#^INSTALL_TOP=.*#INSTALL_TOP=%(HOME)/.local#' Makefile &&
            make -j linux-readline && make install
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

    luarocks "lua-sdl2"

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
    if cfg.pmccabe and (force or not installed "pmccabe") then
        gitclone "https://github.com/datacom-teracom/pmccabe"
        sh "cd %(repo_path)/pmccabe && CC='gcc -Wno-implicit-function-declaration' make && cp pmccabe ~/.local/bin"
    end

    -- interactive scratchpad: https://github.com/metakirby5/codi.vim
    script "codi"

    script "note"

    if cfg.v and cfg.vls then
        if force or not installed "vls" then
            gitclone "https://github.com/nedpals/tree-sitter-v"
            sh "mkdir -p ~/.vmodules/; ln -sf %(repo_path)/tree-sitter-v ~/.vmodules/tree_sitter_v"
            gitclone("https://github.com/vlang/vls.git")
            sh [[ cd %(repo_path)/vls
                git checkout use-tree-sitter
                ~/.local/bin/v -gc boehm -cc gcc cmd/vls ]]
        end
    end

    if cfg.lazygit then
        if force or not installed "lazygit" then
            sh "go install github.com/jesseduffield/lazygit@latest && ln -sf %(HOME)/go/bin/lazygit %(HOME)/.local/bin/lazygit"
        end
    end

    script "ido"
    script "retry"

    -- tup
    if cfg.tup and (force or not installed "tup") then
        dnf_install "fuse3-devel pcre-devel"
        gitclone "https://github.com/gittup/tup.git"
        sh "cd %(repo_path)/tup && ./bootstrap.sh"
        sh "cp %(repo_path)/tup/tup ~/.local/bin/"
        sh "cp %(repo_path)/tup/tup.1 ~/.local/man/man1"
    end

    --[===[
    if force or not installed "jupyter-lab" or not installed "jupyter" or not installed "voila" then
        pip_install [[
            jupyterlab
            notebook
            voila
        ]]
    end
    --]===]

    if force or upgrade or not installed "numbat" then
        log "numbat"
        local curr_version = ((pipe("numbat --version") or ""):lines()[1] or F""):words()[2]
        local version = pipe("curl -sSL https://github.com/sharkdp/numbat/releases/latest/"):match("tag/v([%d%.]+)")
        if version ~= curr_version then
            with_tmpdir(function(tmp)
                sh("wget https://github.com/sharkdp/numbat/releases/download/v"..version.."/numbat-v"..version.."-x86_64-unknown-linux-musl.tar.gz -O "..tmp.."/numbat.tar.gz")
                sh("tar xvzf "..tmp.."/numbat.tar.gz -C ~/.local/bin --strip-components 1 \"*/numbat\"")
            end)
        end
    end
end

function lsp_configuration()

    title "Language servers configuration"

    if cfg.bash_language_server then
        if force or not file_exist "%(HOME)/.local/opt/bash-language-server/node_modules/.bin/bash-language-server" then
            log "Bash Language Server"
            mkdir "%(HOME)/.local/opt/bash-language-server"
            sh "cd ~/.local/opt/bash-language-server && npm install bash-language-server && ln -s -f $PWD/node_modules/.bin/bash-language-server ~/.local/bin/"
        end
    end
    if cfg.dot_language_server then
        if force or not file_exist "%(HOME)/.local/opt/dot-language-server/node_modules/.bin/dot-language-server" then
            log "Dot Language Server"
            mkdir "%(HOME)/.local/opt/dot-language-server"
            sh "cd ~/.local/opt/dot-language-server && npm install dot-language-server && ln -s -f $PWD/node_modules/.bin/dot-language-server ~/.local/bin/"
        end
    end
    if cfg.python_language_server then
        if force or not file_exist "%(HOME)/.local/opt/pyright-langserver/node_modules/.bin/pyright-langserver" then
            log "Python Language Server"
            mkdir "%(HOME)/.local/opt/pyright-langserver"
            sh "cd ~/.local/opt/pyright-langserver && npm install pyright && ln -s -f $PWD/node_modules/.bin/pyright-langserver ~/.local/bin/"
        end
    end
    if cfg.lua_language_server then
        if force or not installed "lua-language-server" then
            log "Lua Language Server"
            gitclone("https://github.com/LuaLS/lua-language-server", {"--recurse-submodules"})
            sh [[ cd %(repo_path)/lua-language-server &&
                ./make.sh
                ln -s -f $PWD/bin/lua-language-server ~/.local/bin/ ]]
        end
    end
    if cfg.teal_language_server then
        if force or not installed "teal-language-server" then
            log "Teal Language Server"
            luarocks("teal-language-server", "--dev")
        end
    end
    if cfg.freepascal and cfg.freepascal_language_server then
        if force or not installed "pasls" then
            log "Pascal Language Server"
            dnf_install [[
                lazarus
                libsqlite3x sqlite-devel
            ]]
            gitclone("https://github.com/genericptr/pascal-language-server", {"--recurse-submodules"})
            sh [[ cd %(repo_path)/pascal-language-server && lazbuild src/standard/pasls.lpi &&
                  ln -s -f %(repo_path)/pascal-language-server/lib/x86_64-linux/pasls ~/.local/bin/ ]]
        end
    end
    if cfg.typescript_language_server then
        if force or not installed "typescript-language-server" then
            log "Typescript Language Server"
            mkdir "%(HOME)/.local/opt/typescript-language-server"
            sh [[ cd ~/.local/opt/typescript-language-server &&
                  npm install typescript typescript-language-server &&
                  ln -s -f $PWD/node_modules/.bin/tsc ~/.local/bin/ &&
                  ln -s -f $PWD/node_modules/.bin/typescript-language-server ~/.local/bin/
            ]]
        end
    end
    if cfg.purescript_language_server then
        if force or not installed "purescript-language-server" then
            log "Purescript Language Server"
            mkdir "%(HOME)/.local/opt/purescript-language-server"
            sh [[ cd ~/.local/opt/purescript-language-server &&
                  npm install purescript spago purescript-language-server &&
                  ln -s -f $PWD/node_modules/.bin/purs ~/.local/bin/ &&
                  ln -s -f $PWD/node_modules/.bin/spago ~/.local/bin/ &&
                  ln -s -f $PWD/node_modules/.bin/purescript-language-server ~/.local/bin/
            ]]
        end
    end
    if cfg.elm_language_server then
        if force or not installed "elm-language-server" then
            log "ELM Language Server"
            mkdir "%(HOME)/.local/opt/elm-language-server"
            sh [[ cd ~/.local/opt/elm-language-server &&
                  npm install elm elm-test elm-format @elm-tooling/elm-language-server &&
                  ln -s -f $PWD/node_modules/.bin/elm ~/.local/bin/ &&
                  ln -s -f $PWD/node_modules/.bin/elm-language-server ~/.local/bin/
            ]]
        end
    end
    if cfg.rust and cfg.typst_language_server then
        if force or not installed "typst-lsp" then
            log "Typst Language Server"
            if cfg.compile_typst_lsp_with_cargo then
                gitclone "https://github.com/nvarner/typst-lsp.git"
                sh "cd %(repo_path)/typst-lsp && ~/.cargo/bin/cargo install --path . --root ~/.local"
            else
                local version = pipe("curl -sSL https://github.com/nvarner/typst-lsp/releases/latest"):match("tag/(v[%d%.]+)")
                version = version == "v0.6.0" and "v0.5.1"
                       or version
                with_tmpdir(function(tmp)
                    sh("wget https://github.com/nvarner/typst-lsp/releases/download/"..version.."/typst-lsp-x86_64-unknown-linux-gnu -O "..tmp.."/typst-lsp")
                    sh("install "..tmp.."/typst-lsp ~/.local/bin/")
                end)
            end
        end
    end
    if cfg.swipl_language_server then
        if force or not file_exist "%(HOME)/.local/share/swi-prolog/pack/lsp_server/prolog/lsp_server.pl" then
            log "Prolog Language Server"
            sh "swipl -g 'pack_install(lsp_server)' -t 'halt'"
        end
    end

end

-- }}}

-- Haskell configuration {{{

function haskell_configuration()
    title "Haskell configuration"

    dnf_install [[
        gcc gcc-c++ gmp gmp-devel make ncurses ncurses-compat-libs xz perl
    ]]

    -- GHCup
    if force or upgrade or not installed "ghcup" then
        sh " export BOOTSTRAP_HASKELL_NONINTERACTIVE=1; \
             export BOOTSTRAP_HASKELL_INSTALL_HLS=1; \
             curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh \
        "
    end

    local HASKELL_STACK_PACKAGES = {
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
        for _, package in ipairs(HASKELL_STACK_PACKAGES) do
            log("Stack install "..package)
            sh(". ~/.ghcup/env; ghcup run stack install -- "..package)
        end
    end

    local HASKELL_CABAL_PACKAGES = {
        "implicit-hie",
    }
    if force or upgrade then
        for _, package in ipairs(HASKELL_CABAL_PACKAGES) do
            log("Cabal install "..package)
            sh(". ~/.ghcup/env; ghcup run cabal install -- --overwrite-policy=always "..package)
        end
    end

end

-- }}}

-- OCaml configuration {{{


function ocaml_configuration()

    title "OCaml installation"

    dnf_install [[
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

    local packages = "dune ocaml-lsp-server odoc ocamlformat utop"

    sh("opam install "..packages)

end

function framac_configuration()

    title "Frama-C installation"

    if not cfg.ocaml then error("Frama-C requires OCaml") end

    dnf_install [[
        z3
    ]]

    if force or not installed "frama-c" then
        log "Frama-C installation"
        sh "opam install alt-ergo"
        sh "opam install frama-c"
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

    if not installed "rustc" then
        title "Rust configuration"
        with_tmpfile(function(tmp)
            sh("curl https://sh.rustup.rs -sSf -o "..tmp.." && sh "..tmp.." -y -v --no-modify-path")
        end)
        sh "~/.cargo/bin/rustup update stable"
    elseif force or upgrade then
        title "Rust upgrade"
        sh "rustup override set stable"
        sh "rustup update stable"
    end

    -- Rust Language Server
    if force or not installed "rust-analyzer" then
        sh "curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer"
        sh "chmod +x ~/.local/bin/rust-analyzer"
        sh "~/.cargo/bin/rustup component add rust-src"
    end

    local RUST_PACKAGES = {
        --{"bottom", "btm"},
        --"hyperfine",
        --"procs",
    }
    for _, package_desc in ipairs(RUST_PACKAGES) do
        local exe = nil
        if type(package_desc) == "table" then
            package, exe = table.unpack(package_desc)
        else
            package = package_desc
            exe = package_desc
        end
        if force or not installed(exe) then
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

    local project = "~/.julia/environments/nvim-lspconfig"
    if force or not dir_exist(project) then

        log "Julia Language Server Protocol"
        if not dir_exist(project) then
            sh(([[julia --project=%s -e 'using Pkg; Pkg.add("LanguageServer")']]):format(project))
        else
            sh(([[julia --project=%s -e 'using Pkg; Pkg.update()']]):format(project))
        end
        sh(([[julia --project=%s -e 'using Pkg; Pkg.instantiate()']]):format(project))

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
        local curr_version = installed "zig" and pipe("zig version")
        local version = ZIG_ARCHIVE:match("/([%d%.]+)/")
        ZIG_VERSION = version

        if version ~= curr_version then
            sh "wget %(ZIG_ARCHIVE) -c -O ~/.local/opt/%(basename(ZIG_ARCHIVE))"
            sh "rm -rf ~/.local/opt/zig/%(ZIG_VERSION)"
            sh "mkdir -p ~/.local/opt/zig/%(ZIG_VERSION)"
            sh "tar xJf ~/.local/opt/%(basename(ZIG_ARCHIVE)) -C ~/.local/opt/zig/%(ZIG_VERSION) --strip-components 1"
            sh "ln -f -s ~/.local/opt/zig/%(ZIG_VERSION)/zig ~/.local/bin/zig"
            sh "rm -f ~/.local/opt/%(basename(ZIG_ARCHIVE))"
        end
    end

    if cfg.zig_language_server and (force or not installed "zls") then
        title "Zig Language Server installation"
        local curr_version = installed_packages.zls_version
        local version = pipe("curl -sSL https://github.com/zigtools/zls/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            with_tmpdir(function(tmp)
                sh("wget https://github.com/zigtools/zls/releases/download/"..version.."/zls-x86_64-linux.tar.xz -O "..tmp.."/zls-x86_64-linux.tar.xz")
                --sh("cd "..tmp.."; tar -l zstd xf x86_64-linux.tar.xz && mv bin/zls %(HOME)/.local/bin/zls && chmod +x %(HOME)/.local/bin/zls")
                sh("cd "..tmp.."; tar xJf zls-x86_64-linux.tar.xz && mv zls %(HOME)/.local/bin/zls && chmod +x %(HOME)/.local/bin/zls")
                installed_packages.zls_version = version
            end)
        end
    end

end

-- }}}

-- Wasmer configuration {{{

function wasmer_configuration()
    if force or not installed "wasmer" then
        title "Wasmer configuration"
        sh "rm -rf ~/.wasmer"
        sh "curl https://get.wasmer.io -sSfL | sh"
    end
end

-- }}}

-- Nim configuration {{{

function nim_configuration()

    if force or not installed "nim" then

        title "Nim configuration"

        NIM_URL = "https://nim-lang.org/install_unix.html"

        local index = pipe("curl -sSL %(NIM_URL)")
        NIM_ARCHIVE = nil
        index:gsub([[(download/(nim%-[0-9.]+)%-linux_x64%.tar%.xz)]], function(url, name)
            if not NIM_ARCHIVE then
                NIM_ARCHIVE = dirname(NIM_URL)..url
                NIM_DIR = name
            end
        end)
        assert(NIM_ARCHIVE and NIM_DIR, "Can not determine Nim version")
        local curr_version = pipe("nim --version"):match("Version ([%d%.]+)")
        local version = NIM_ARCHIVE:match("nim%-([%d%.]+)")

        if version ~= curr_version then
            sh "wget %(NIM_ARCHIVE) -c -O ~/.local/opt/%(basename(NIM_ARCHIVE))"
            sh "rm -rf ~/.local/opt/%(NIM_DIR)"
            sh "tar xJf ~/.local/opt/%(basename(NIM_ARCHIVE)) -C ~/.local/opt"
            sh "ln -f -s ~/.local/opt/%(NIM_DIR)/bin/nim ~/.local/bin/nim"
            sh "ln -f -s ~/.local/opt/%(NIM_DIR)/bin/nimble ~/.local/bin/nimble"
            sh "ln -f -s ~/.local/opt/%(NIM_DIR)/bin/nimsuggest ~/.local/bin/nimsuggest"
        end

    end

    if cfg.nim_language_server and (force or not file_exist "%(HOME)/.nimble/bin/nimlsp") then
        title "Nim Language Server installation"
        NIM_VERSION = pipe("nim --version"):match("Version ([%d%.]+)")
        sh "~/.local/opt/nim-%(NIM_VERSION)/bin/nimble install nimlsp"
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
            libuuid-devel
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

    dnf_install [[
        wkhtmltopdf
        aspell-fr aspell-en
        figlet
        translate-shell
    ]]

    -- PlantUML
    if force or not file_exist "%(HOME)/.local/bin/plantuml.jar" then
        log "PlantUML"
        local index = download "https://plantuml.com/fr/download"
        local latest = assert(index : match 'href="(https://[^"]+%.jar)"')
        local content = download(latest)
        write("%(HOME)/.local/bin/plantuml.jar", content, {raw=true})
    end

    -- ditaa
    if force or not file_exist "%(HOME)/.local/bin/ditaa.jar" then
        log "ditaa"
        local index = download "https://github.com/stathissideris/ditaa/releases/latest"
        local tag = assert(index : match "releases/tag/v([%d%.]+)")
        local content = download("https://github.com/stathissideris/ditaa/releases/download/v"..tag.."/ditaa-"..tag.."-standalone.jar")
        write("%(HOME)/.local/bin/ditaa.jar", content, {raw=true})
    end

end

-- }}}

-- Pandoc configuration {{{

function pandoc_configuration()
    title "Pandoc configuration"

    if cfg.patat then
        dnf_install [[
            patat
        ]]
    end

    --[[ Pandoc is installed by luax, this section is kept for future reference in case the dynamic executable is needed
    if force or upgrade or not installed "pandoc" then
        if cfg.haskell and cfg.compile_pandoc_with_cabal then
            log "Pandoc"
            sh(". ~/.ghcup/env; cabal install pandoc-cli --overwrite-policy=always --install-method=copy --installdir=%(HOME)/.local/bin")
        else
            local curr_version = ((pipe("pandoc --version") or ""):lines()[1] or F""):words()[2]
            local version = pipe("curl -sSL https://github.com/jgm/pandoc/releases/latest/"):match("tag/([%d%.]+)")
            if version ~= curr_version then
                log "Pandoc"
                with_tmpdir(function(tmp)
                    sh("wget https://github.com/jgm/pandoc/releases/download/"..version.."/pandoc-"..version.."-linux-amd64.tar.gz -O "..tmp.."/pandoc.tar.gz")
                    sh("tar xvzf "..tmp.."/pandoc.tar.gz --strip-components 1 -C ~/.local")
                end)
            end
        end
    end
    --]]

    --[[ Typst is installed by luax
    if force or upgrade or not installed "typst" then
        if cfg.rust and cfg.compile_typst_with_rust then
            log "Typst"
            sh "~/.cargo/bin/cargo install --git https://github.com/typst/typst --root ~/.local"
        else
            local curr_version = (pipe("typst --version") or ""):words()[2]
            local version = pipe("curl -sSL https://github.com/typst/typst/releases/latest/"):match("tag/v([%d%.]+)")
            if version ~= curr_version then
                log "Typst"
                with_tmpdir(function(tmp)
                    sh("wget https://github.com/typst/typst/releases/download/v"..version.."/typst-x86_64-unknown-linux-musl.tar.xz -O "..tmp.."/typst.tar.xz")
                    sh("tar xvJf "..tmp.."/typst.tar.xz --strip-components 1 --exclude=LICENSE --exclude=NOTICE --exclude=README.md -C ~/.local/bin")
                end)
            end
        end
    end
    --]]

    if cfg.blockdiag then
        if force or upgrade or not installed "blockdiag" then
            log "Blockdiag"
            pip_install "blockdiag seqdiag actdiag nwdiag"
        end
    end

    if cfg.mermaid then
        if force or upgrade or not installed "mmdc" then
            log "Mermaid"
            mkdir "%(HOME)/.local/opt/mermaid"
            sh "cd ~/.local/opt/mermaid && npm install @mermaid-js/mermaid-cli && ln -s -f $PWD/node_modules/.bin/mmdc ~/.local/bin/"
        end
    end

    if cfg.penrose then
        if force or upgrade or not installed "roger" then
            log "Penrose"
            mkdir "%(HOME)/.local/opt/penrose"
            sh "cd ~/.local/opt/penrose && npm install @penrose/roger && ln -s -f $PWD/node_modules/.bin/roger ~/.local/bin/"
        end
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
    end
end

-- }}}

-- neovim configuration {{{

function neovim_configuration()
    title "neovim configuration"

    -- copr to be removed when Neovim 0.7 is in the Fedora repository
    --copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:agriffis:neovim-nightly.repo", "agriffis/neovim-nightly")

    dnf_install [[
        neovim
        pwgen
        gzip
        jq
        xclip
    ]]

    pip_install "pynvim"

    for config_file in ls ".config/nvim/*.vim" do
        script(config_file)
    end
    for config_file in ls ".config/nvim/*.lua" do
        script(config_file)
    end
    for config_file in ls ".config/nvim/vim/*.vim" do
        script(config_file)
    end
    for config_file in ls ".config/nvim/lua/*.lua" do
        script(config_file)
    end

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

    if cfg.shellcheck then
        if cfg.haskell and cfg.compile_shellcheck_with_stack then
            if force or upgrade or not installed "shellcheck" then
                log "ShellCheck"
                sh ". ~/.ghcup/env; ghcup run stack install -- ShellCheck"
            end
        else
            dnf_install "ShellCheck"
        end
    end

    -- Notes, TO-DO lists and password manager
    mkdir "%(WIKI)"

    -- spell directory containing word lists
    mkdir "%(HOME)/.local/share/nvim/site/spell"

    -- numbat colors
    do
        local url = "https://raw.githubusercontent.com/irevoire/tree-sitter-numbat/main/queries/highlights.scm"
        local highlights_path = "%(HOME)/.local/share/nvim/lazy/nvim-treesitter/queries/numbat/highlights.scm"
        if force or upgrade or not file_exist(highlights_path) then
            local highlights = download(url)
            mkdir(fs.dirname(highlights_path))
            write(highlights_path, highlights, {raw=true})
        end
    end

    -- ccrypt
    if force or not installed "ccrypt" then
        local url = "https://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11.linux-x86_64.tar.gz"
        local archive = repo_path/url:basename()
        if not fs.is_file(archive) then
            sh("curl -fsSL", url, "-o", archive)
        end
        fs.with_tmpdir(function(tmp)
            sh("cd", tmp, "&&", "tar -xvzf", archive, "--strip-components 1", "&&", "cp", tmp/"ccrypt", "~/.local/bin/")
        end)
    end

end

-- }}}

-- helix configuration {{{

function helix_configuration()
    title "helix configuration"

    if force or upgrade or not installed "hx" then
        if cfg.rust and cfg.helix_sources then
            log "Helix"
            gitclone "https://github.com/helix-editor/helix"
            sh "cd %(repo_path)/helix && ~/.cargo/bin/cargo install --path helix-term --locked --root ~/.local"
            sh "ln -sf %(repo_path)/helix/runtime ~/.config/helix/runtime"
        else
            local curr_version = ((pipe("hx --version") or ""):lines()[1] or F""):words()[2]
            local version = pipe("curl -sSL https://github.com/helix-editor/helix/releases/latest/"):match("tag/([%d%.]+)")
            if version ~= curr_version then
                log "Helix"
                with_tmpdir(function(tmp)
                    sh("wget https://github.com/helix-editor/helix/releases/download/"..version.."/helix-"..version.."-x86_64-linux.tar.xz -O "..tmp.."/helix.tar.xz")
                    sh("cd "..tmp.." && tar xvJf helix.tar.xz --strip-components 1")
                    mkdir "%(HOME)/.config/helix"
                    sh("install "..tmp.."/hx ~/.local/bin")
                    sh("cp -af "..tmp.."/runtime ~/.config/helix/runtime")
                end)
            end
        end
    end

end

-- }}}

-- VSCode configuration {{{

function vscode_configuration()
    title "VSCode configuration"

    if force or not installed "code" then
        with_tmpdir(function(tmp)
            sh("cd "..tmp.." && "
               .."sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&"
               ..[=[ sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' ]=]
            )
        end)
        dnf_install "code"
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
    if cfg.nerd_fonts then
        local release = nil
        local font_cache_update = false
        local function install_font(name, file)
            if force or not file_exist("%(HOME)/.local/share/fonts/"..file) then
                log("Font: "..name)
                release = release or pipe("curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/"):match("tag/(v[%d%.]+)")
                sh("wget https://github.com/ryanoasis/nerd-fonts/releases/download/"..release.."/"..name..".zip -c -O %(repo_path)/"..name.."-"..release..".zip")
                mkdir "%(HOME)/.local/share/fonts"
                sh("unzip -j -u %(repo_path)/"..name.."-"..release..".zip '*.ttf' -d %(HOME)/.local/share/fonts/")
                font_cache_update = true
            end
        end
        install_font("SourceCodePro", "SauceCodeProNerdFont-Regular.ttf")
        install_font("FiraCode", "FiraCodeNerdFont-Regular.ttf")
        if font_cache_update then
            log "Font: update cache"
            sh "fc-cache -f"
        end
    end

    -- alacritty
    if force or not installed "alacritty" then
        log "Alacritty"
        if cfg.rust and cfg.alacritty_sources then
            -- Prerequisites
            dnf_install [[ cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ ]]
            -- Get sources
            gitclone "https://github.com/alacritty/alacritty.git"
            -- Build
            --sh "cd %(repo_path)/alacritty && ~/.cargo/bin/cargo build --release"
            sh "cd %(repo_path)/alacritty && ~/.cargo/bin/cargo build --release --no-default-features --features=x11"
            -- Terminfo
            sh "cd %(repo_path)/alacritty && sudo tic -xe alacritty,alacritty-direct extra/alacritty.info"
            -- Install Alacritty (or replace the existing executable)
            sh "rm -f %(HOME)/.local/bin/alacritty"
            sh "cp %(repo_path)/alacritty/target/release/alacritty %(HOME)/.local/bin"
            sh "strip %(HOME)/.local/bin/alacritty"
            -- Desktop Entry
            sh "sudo cp %(repo_path)/alacritty/extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg"
            sh "cd %(repo_path)/alacritty && sudo desktop-file-install extra/linux/Alacritty.desktop"
            sh "sudo update-desktop-database"
            -- Manual Page
            mkdir "%(HOME)/.local/share/man/man1"
            sh "cd %(repo_path)/alacritty && gzip -c extra/alacritty.man | sudo tee %(HOME)/.local/share/man/man1/alacritty.1.gz > /dev/null"
            sh "cd %(repo_path)/alacritty && gzip -c extra/alacritty-msg.man | sudo tee %(HOME)/.local/share/man/man1/alacritty-msg.1.gz > /dev/null"
        else
            dnf_install "alacritty"
        end
    end

    -- WezTerm
    if cfg.rust and cfg.wezterm then
        if force or not installed "wezterm" then
            log "WezTerm"
            gitclone("https://github.com/wez/wezterm.git", { "--depth=1", "--branch=main", "--recursive" })
            sh "cd %(repo_path)/wezterm && git submodule update --init --recursive && ./get-deps"
            sh "cd %(repo_path)/wezterm && ~/.cargo/bin/cargo build --release --no-default-features --features vendored-fonts"
            sh "cd %(repo_path)/wezterm && install -vm755 target/release/wezterm -t ~/.local/bin"
            sh "cd %(repo_path)/wezterm && install -vm755 target/release/wezterm-gui -t ~/.local/bin"
            sh "cd %(repo_path)/wezterm && install -vm755 target/release/wezterm-mux-server -t ~/.local/bin"
            sh "cd %(repo_path)/wezterm && install -vm755 target/release/strip-ansi-escapes -t ~/.local/bin"
            sh "cd %(repo_path)/wezterm && install -vm755 assets/open-wezterm-here -t ~/.local/bin"
            sh "cd %(repo_path)/wezterm && sudo install -vm644 assets/shell-integration/* -t /etc/profile.d"
            sh "cd %(repo_path)/wezterm && sudo install -vm644 assets/shell-completion/zsh /usr/local/share/zsh/site-functions/_wezterm"
            sh "cd %(repo_path)/wezterm && sudo install -vm644 assets/shell-completion/bash /etc/bash_completion.d/wezterm"
        end
        script ".config/wezterm/wezterm.lua"
    end

    -- urxvt
    if force or upgrade or not file_exist "%(HOME)/.urxvt/ext/font-size" then
        log "Urxvt font-size"
        gitclone "https://github.com/majutsushi/urxvt-font-size"
        mkdir "%(HOME)/.urxvt/ext/"
        sh "cp %(repo_path)/urxvt-font-size/font-size %(HOME)/.urxvt/ext/"
    end

    -- st
    if force or not file_exist "%(HOME)/.local/bin/st" then
        log "st"
        local version = "0.9"
        gitclone("https://git.suckless.org/st")
        sh "cd %(repo_path)/st && git reset --hard master && git checkout master && git clean -dfx && git fetch && git rebase"
        sh("cd %(repo_path)/st && git checkout "..version)
        local function patch(url)
            local file = repo_path.."/st-patches/"..basename(url)
            if not file_exist(file) then
                mkdir(dirname(file))
                sh("wget "..url.." -O "..file)
            end
            sh("cd %(repo_path)/st && patch -p1 < "..file)
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
        with_file("%(repo_path)/st/config.def.h", function(config)
            config = config:gsub("font = \".-\";", I"font = \"%(FONT):style=%(FONT_VARIANT):size=%(FONT_SIZE):antialias=true:autohint=true\";")
            config = config:gsub("worddelimiters = L\".-\";", I"worddelimiters = L\" `'\\\"()[]{}\";")
            for i, c in pairs(colors) do
                config = config:gsub('(%['..i..'%]) = "(#......)"', '%1 = "'..c..'"')
            end
            return config
        end)

        sh[[cd %(repo_path)/st && sed -i 's#PREFIX =.*#PREFIX = %(HOME)/.local#' config.mk]]
        sh[[cd %(repo_path)/st && sed -i 's#MANPREFIX =.*#MANPREFIX = %(HOME)/.local/man#' config.mk]]
        sh "cd %(repo_path)/st && make install"
    end
    script "plumb"

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
    --mime_default "thunar.desktop"
    mime_default "pcmanfm.desktop"
    mime_default "ristretto.desktop" -- shall be configured after atril to overload atril associations
    mime_default "vlc.desktop"
    mime_default "wireshark.desktop"
    mime_default "nvim.desktop"

    script ".config/alacritty/alacritty.toml"
    script ".Xdefaults"

    script ".config/i3/config"
    script ".xsession"
    script ".xsessionrc"

    script ".config/dunst/dunstrc"

    script ".config/rofi/config.rasi"

    script "wallpaper_of_the_day"
    script "every"
    script "batmon"

    script "xi3"

    script ".config/gtk-3.0/settings.ini"
    script ".config/qt5ct/qt5ct.conf"
    script ".gtkrc-2.0"

    script "xprompt"
    script "xsudo"

    -- script ".config/kwalletrc"

    --[[
    if force or not installed "xcwd" then
        log "xcwd"
        gitclone "https://github.com/CDSoft/xcwd.git"
        sh "cd %(repo_path)/xcwd && make && make install"
    end
    if force or not installed "xpwd" then
        log "xpwd"
        gitclone "https://github.com/CDSoft/xpwd.git"
        sh "cd %(repo_path)/xpwd && make && make install"
    end
    --]]
    script("xpwd.lua", {raw=true})

    script("transient_clipboard.lua", {raw=true})

    if force or not installed "hsetroot" then
        dnf_install "imlib2-devel libXinerama-devel"
        gitclone "https://github.com/himdel/hsetroot"
        sh "cd %(repo_path)/hsetroot && make && DESTDIR=%(HOME) PREFIX=/.local make install"
    end

    pipe("base64 -d > ~/.config/i3/empty.wav", "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=")

    script ".config/i3/status"
    sh "sudo setcap cap_net_admin=ep %(pipe 'which i3status')"

    script "lock"

    script "screenshot"
    sh "mkdir -p ~/Images/ksnip"
    script ".config/ksnip/ksnip.conf"

    script "lrandr"

    script "menu"
    script "idle"

    script "brightness"
    script "notify_volume"

    script ".config/volumeicon/volumeicon"

    script "remote"

    script "netmon"

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

    -- Some word lists from https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases
    script ".config/keepassxc/wordlists/eff_large_wordlist.txt"
    script ".config/keepassxc/wordlists/eff_short_wordlist_1.txt"
    script ".config/keepassxc/wordlists/eff_short_wordlist_2_0.txt"

    -- Logitech tools to fix mousewheel speed issues
    if cfg.logitech_tools then
        dnf_install "solaar"
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
        evince okular mupdf
        atril
        xournal
        curl

        vlc ffmpeg mplayer
        gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras
    ]]

    -- GeoGebra
    -- [[
    if cfg.geogebra then
        if force or update or not installed "geogebra" then
            title "GeoGebra installation"
            local GEOGEBRA_URL = "https://download.geogebra.org/installers/6.0/"
            local GEOGEBRA_ARCHIVE
            pipe("curl -i "..GEOGEBRA_URL):gsub('href="(GeoGebra%-Linux64%-Portable%-(.-)%.zip)"', function(archive)
                GEOGEBRA_ARCHIVE = GEOGEBRA_URL/archive:trim()
            end)
            if not file_exist("~/.local/opt/"..GEOGEBRA_ARCHIVE:basename()) then
                sh("curl --output-dir ~/.local/opt/ -O "..GEOGEBRA_ARCHIVE)
            end
            sh("cd ~/.local/opt/ && rm -rf GeoGebra-linux-x64 && unzip "..GEOGEBRA_ARCHIVE:basename())
            sh("ln -f -s ~/.local/opt/GeoGebra-linux-x64/GeoGebra ~/.local/bin/geogebra")
        end
    end
    --]]
    --script "geogebra" -- to use GeoGebra online

end

-- }}}

-- Povray configuration {{{

function povray_configuration()
    title "Povray configuration"

    dnf_install [[ povray ]]

end

-- }}}

-- Internet configuration {{{

function internet_configuration()
    title "Internet configuration"

    dnf_install [[
        firefox
        torbrowser-launcher
        surf
        thunderbird
        transmission
        dnf-plugins-core
    ]]

   if cfg.chromium then
        dnf_install "chromium"
    end

    -- Default browser
    log "Default browser"
    sh "BROWSER= xdg-settings set default-web-browser %(BROWSER).desktop || true"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop text/html"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/http"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/https"
    sh "BROWSER= xdg-mime default %(BROWSER).desktop x-scheme-handler/about"

    -- Firefox configuration
    -- https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
    -- https://askubuntu.com/questions/239543/get-the-default-firefox-profile-directory-from-bash
    if file_exist("%(HOME)/.mozilla/firefox/profiles.ini") then
        log "Firefox configuration"
        readlines("%(HOME)/.mozilla/firefox/profiles.ini"):foreach(function(line)
            for profile in line:gmatch("Path=(.*)") do
                write("%(HOME)/.mozilla/firefox/"..profile.."/user.js", read "%(src_files)/user.js")
            end
        end)
    end

    -- Thunderbird extensions
    if force or upgrade or not file_exist "%(repo_path)/reply_as_original_recipient.xpi" then
        gitclone "https://github.com/qiqitori/reply_as_original_recipient.git"
        sh "cd %(repo_path)/reply_as_original_recipient && zip -r ../reply_as_original_recipient.xpi *"
    end

    -- Remove unecessary language symlinks
    log "Remove unecessary language symlinks"
    sh "sudo find /usr/share/myspell -type l -exec rm -v {} \\;"

    -- DLNA server
    if cfg.minidlna then
        dnf_install "minidlna"
        mkdir "%(HOME)/dlna"
        sh "sudo sed -i 's#^media_dir=.*#media_dir=%(HOME)/dlna#' /etc/minidlna.conf"
        sh "sudo service minidlna stop"
        sh "sudo service minidlna start"
        --sh "sudo update-rc.d minidlna defaults"
    end

    -- Kodi
    if cfg.kodi then
        dnf_install [[
            kodi
            kodi-inputstream-adaptive
            kodi-pvr-iptvsimple
        ]]
    end

    -- Quick web browser launch menu
    script "menu-web"

end

-- }}}

-- Zoom configuration {{{

function zoom_configuration()
    title "Zoom configuration"

    if force or not installed "zoom" then
        with_tmpdir(function(tmp)
            sh("wget https://zoom.us/client/latest/zoom_x86_64.rpm -O "..tmp.."/zoom_x86_64.rpm")
            sh("sudo dnf install "..tmp.."/zoom_x86_64.rpm")
        end)
        mime_default "Zoom.desktop"
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
        qemu-img
    ]]
    dnf_install "akmod-VirtualBox kernel-devel-%(pipe 'uname -r')"

    script "vm"
    script "sshfs-host"
    script "sshfs-mount"

end

-- }}}

-- Work configuration {{{

function work_configuration()
    title "Work configuration"

    dnf_install "dnf-plugins-core"

    --[==[
    dnf_install [[
        moby-engine grubby
    ]]
    ]==]

    dnf_install [[
        astyle
    ]]

    -- AWS
    if force or upgrade then
        log "AWS configuration"
        pip_install "awscli boto3"
        sh "sudo groupadd docker || true"
        sh "sudo usermod -a -G docker %(USER)"
        sh "sudo systemctl enable docker || true"
    end
    script "aws-login"

    -- Docker
    if force or upgrade then
        --[[
        log "Docker configuration"
        -- https://github.com/docker/cli/issues/2104
        sh "sudo grubby --update-kernel=ALL --args=\"systemd.unified_cgroup_hierarchy=0\""
        sh "sudo systemctl start docker || true"
        sh "sudo usermod -a -G docker %(USER)"
        --]]

        -- https://docs.docker.com/engine/install/fedora/
        sh "sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo --overwrite"
        dnf_install [[
            docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ]]
        sh "sudo systemctl start docker || true"
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

    pip_install [[
        appdirs
        awscli
        click
        google-api-python-client
        google-auth-httplib2
        google-auth-oauthlib
        junitparser
        junit-xml
        matplotlib
        pyaml
        pydantic
        python-can
        scipy
        tftpy
        tqdm
    ]]

    -- ROS: http://wiki.ros.org/Installation/Source
    if cfg.ros then
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
    end

    if cfg.lazydocker then
        if force or not installed "lazydocker" then
            sh "go install github.com/jesseduffield/lazydocker@latest && ln -sf %(HOME)/go/bin/lazydocker %(HOME)/.local/bin/lazydocker"
        end
    end

end

function work_vpn_configuration()
    title "Work VPN configuration"

    -- VPN
    if not file_exist "/etc/resolv.conf.orig" then
        dnf_install "NetworkManager-openvpn-gnome"
        sh "systemctl disable --now systemd-networkd"
        if file_exist "/etc/resolv.conf" then
            sh "sudo mv /etc/resolv.conf /etc/resolv.conf.orig"
        end
        sh "systemctl restart NetworkManager"
    end
    -- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening
    --sh "sudo update-crypto-policies --set LEGACY"
    fs.with_tmpdir(function(tmp)
        local pmod = "RSA1024.pmod"
        fs.write(tmp/pmod, F.unlines {
            "# Allow certificates with 1024-bits RSA keys",
            "min_rsa_size = 1024",
        })
        sh("sudo cp "..tmp/pmod.." /etc/crypto-policies/policies/modules/")
    end)
    sh "sudo update-crypto-policies --set DEFAULT:RSA1024"

end

-- }}}

os.exit(main())
