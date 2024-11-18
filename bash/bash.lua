title(...)

local shellcheck_sources = false

-- Bash language server
if FORCE or not fs.is_file(HOME/".local/opt/bash-language-server/node_modules/.bin/bash-language-server") then
    fs.mkdirs(HOME/".local/opt/bash-language-server")
    run {
        "cd ~/.local/opt/bash-language-server",
        "&&",
        "npm install bash-language-server",
        "&&",
        "ln -s -f $PWD/node_modules/.bin/bash-language-server ~/.local/bin/",
    }
end

-- ShellCheck
if fs.is_file(HOME/".ghcup/env") and shellcheck_sources then
    if FORCE or not installed "shellcheck" then
        run ". ~/.ghcup/env; ghcup run stack install -- ShellCheck"
    end
else
    dnf_install "ShellCheck"
end
