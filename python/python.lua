-- Python language server
if FORCE or not fs.is_file(HOME/".local/opt/pyright-langserver/node_modules/.bin/pyright-langserver") then
    fs.mkdirs(HOME/".local/opt/pyright-langserver")
    run {
        "cd ~/.local/opt/pyright-langserver",
        "&&",
        "npm install pyright",
        "&&",
        "ln -s -f $PWD/node_modules/.bin/pyright-langserver ~/.local/bin/",
    }
end
