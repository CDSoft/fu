title(...)

if UPDATE or not installed "numbat" then
    local curr_version = (read("numbat --version || true"):lines()[1] or F""):words()[2]
    local version = read("curl -sSL https://github.com/sharkdp/numbat/releases/latest/"):match("tag/v([%d%.]+)")
    if version ~= curr_version then
        fs.with_tmpdir(function(tmp)
            run { "wget", "https://github.com/sharkdp/numbat/releases/download/v"..version.."/numbat-v"..version.."-x86_64-unknown-linux-musl.tar.gz", "-O", tmp/"numbat.tar.gz" }
            run { "tar xvzf", tmp/"numbat.tar.gz", "-C ~/.local/bin", "--strip-components 1", "\"*/numbat\"" }
        end)
    end
end

-- neovim numbat colors
do
    local url = "https://raw.githubusercontent.com/irevoire/tree-sitter-numbat/main/queries/highlights.scm"
    local highlights_path = HOME/".local/share/nvim/lazy/nvim-treesitter/queries/numbat/highlights.scm"
    if UPDATE or not fs.is_file(highlights_path) then
        local highlights = download(url)
        fs.mkdirs(fs.dirname(highlights_path))
        fs.write(highlights_path, highlights)
    end
end

