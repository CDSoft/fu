local starship_sources = false

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

-- Current shell
if not os.getenv "SHELL" :match "/bin/zsh" then
    run { "chsh -s /bin/zsh", USER }
end

-- Oh My Zsh
gitclone "https://github.com/ohmyzsh/ohmyzsh.git" -- not installed, some scripts will be sourced
gitclone "https://github.com/zsh-users/zsh-syntax-highlighting.git"
gitclone "https://github.com/zsh-users/zsh-autosuggestions"

-- Starship prompt
if FORCE or not installed "starship" then
    -- The binary downloaded by install.sh is buggy (crashes on non existing directory)
    -- If Rust is installed, building from sources is better.
    if starship_sources and fs.is_file(HOME/".cargo/bin/cargo") then
        gitclone "https://github.com/starship/starship.git"
        run {
            "cd", FU_PATH/"starship",
            "&&",
            "~/.cargo/bin/cargo install --locked --force --path . --root ~/.local",
        }
    else
        fs.with_tmpfile(function(tmp)
            download("https://starship.rs/install.sh", tmp)
            run { "sh", tmp, "-f -b ~/.local/bin" }
        end)
    end
end

-- fzf
if FORCE or not installed "fzf" then
    gitclone "https://github.com/junegunn/fzf.git"
    run {
        "cd", FU_PATH/"fzf",
        "&&",
        "./install --key-bindings --completion --no-update-rc"
    }
    gitclone "https://github.com/junegunn/fzf-git.sh.git"
end

-- grc
if FORCE or not installed "grc" then
    gitclone "https://github.com/garabik/grc"
    run {
        "cd", FU_PATH/"grc",
        "&&",
        "sudo ./install.sh",
    }
end

-- eza
if UPDATE or not fs.is_file(HOME/".local/bin/eza") then
    local eza_url = "https://github.com/eza-community/eza/releases"
    local eza_version = read { "curl", "-Ls", "-o /dev/null", '-w "%{url_effective}"', eza_url/"latest" } : basename()
    local curr_version = read "eza --version || true" : lines()[2] : words()[1]
    if eza_version ~= curr_version then
        local url = "https://github.com/eza-community/eza/releases/download/"..eza_version.."/eza_x86_64-unknown-linux-gnu.tar.gz"
        download(url, FU_PATH/url:basename())
        run { "tar -C ~/.local/bin -xzvf", FU_PATH/url:basename() }
    end
end
