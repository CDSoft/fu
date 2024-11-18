title(...)

if FORCE or not installed "mmdc" then
    fs.mkdirs(HOME/".local/opt/mermaid")
    run "cd ~/.local/opt/mermaid && npm install @mermaid-js/mermaid-cli && ln -s -f $PWD/node_modules/.bin/mmdc ~/.local/bin/"
end
