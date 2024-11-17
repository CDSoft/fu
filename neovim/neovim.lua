title(...)

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

-- spell directory containing word lists
fs.mkdirs(HOME/".local/share/nvim/site/spell")

-- ccrypt
if FORCE or not installed "ccrypt" then
    local url = "https://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11.linux-x86_64.tar.gz"
    local archive = FU_PATH/fs.basename(url)
    if not fs.is_file(archive) then
        run { "curl -fsSL", url, "-o", archive }
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
