local starship_sources = db.default_configuration=="XXX"

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
    if starship_sources then
        gitclone "https://github.com/starship/starship.git"
        run {
            "cd", FU_PATH/"starship",
            "&&",
            "~/.cargo/bin/cargo install --locked --force --path . --root ~/.local",
        }
    else
        fs.with_tmpfile(function(tmp)
            run {
                "curl -fsSL https://starship.rs/install.sh -o", tmp,
                "&&",
                "sh", tmp, "-f -b ~/.local/bin"
            }
        end)
    end
end

-- FZF
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
