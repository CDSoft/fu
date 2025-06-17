local install_latest_neovim = true

dnf_install [[
    neovim
    pwgen
    gzip
    jq
    xclip
]]

pip_install "pynvim"

-- To render LaTeX equations: (also need ":TSInstall latex" in neovim)
--pip_install "pylatexenc" -- for 'MeanderingProgrammer/render-markdown.nvim'

-- spell directory containing word lists
fs.mkdirs(HOME/".local/share/nvim/site/spell")

-- ccrypt
if FORCE or not installed "ccrypt" then
    local url = "https://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11.linux-x86_64.tar.gz"
    local archive = FU_PATH/fs.basename(url)
    if not fs.is_file(archive) then
        download(url, archive)
    end
    fs.with_tmpdir(function(tmp)
        run {
            "cd", tmp,
            "&&",
            "tar -xvzf", archive, "--strip-components 1",
            "&&",
            "cp", tmp/"ccrypt", "~/.local/bin/",
        }
    end)
end

-- Latest Neovim
if install_latest_neovim then
    if FORCE or not fs.is_file(HOME/".local/bin/nvim") then
        local neovim_url = "https://github.com/neovim/neovim/releases"
        local neovim_version = github_tag(neovim_url/"latest")
        local latest_url = neovim_url/"download"/neovim_version/"nvim-linux-x86_64.tar.gz"
        local curr_version = read { HOME/".local/bin/nvim", "--version", "|| true" } : words()[2]
        if neovim_version ~= curr_version then
            local archive = FU_PATH/latest_url:basename()
            download(latest_url, archive)
            run { "tar xaf", archive, "-C", HOME/".local", "--strip-components 1" }
        end
    end
end
