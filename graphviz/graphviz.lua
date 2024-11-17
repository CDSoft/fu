title(...)

-- Graphviz language server
if FORCE or not fs.is_file(HOME/".local/opt/dot-language-server/node_modules/.bin/dot-language-server") then
    fs.mkdirs(HOME/".local/opt/dot-language-server")
    run {
        "cd ~/.local/opt/dot-language-server",
        "&&",
        "npm install dot-language-server",
        "&&",
        "ln -s -f $PWD/node_modules/.bin/dot-language-server ~/.local/bin/",
    }
end
