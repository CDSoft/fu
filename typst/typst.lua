-- Typst

if UPDATE or not fs.is_file(HOME/".local/bin/typst") then
    local version = download("https://github.com/typst/typst/releases/latest/"):match("tag/v([%d%.]+)")
    local curr_version = read "typst --version || true":words()[2]
    if version ~= curr_version then
        local url = "https://github.com/typst/typst/releases/download/v"..version.."/typst-x86_64-unknown-linux-musl.tar.xz"
        download(url, FU_PATH/url:basename())
        run { "tar -C ~/.local/bin -xJvf", FU_PATH/url:basename(), "--strip-components=1", "*/typst" }
    end
end

-- Typst language server

--[[
if FORCE or not installed "typst-lsp" then
    if fs.is_file(HOME/".cargo/bin/cargo") then
        gitclone "https://github.com/nvarner/typst-lsp.git"
        run {
            "cd", FU_PATH/"typst-lsp",
            "&&",
            "~/.cargo/bin/cargo install --path . --root ~/.local",
        }
    else
        local version = download("https://github.com/nvarner/typst-lsp/releases/latest"):match("tag/(v[%d%.]+)")
        version = version == "v0.6.0" and "v0.5.1"
                or version
        fs.with_tmpdir(function(tmp)
            download("https://github.com/nvarner/typst-lsp/releases/download"/version/"typst-lsp-x86_64-unknown-linux-gnu", tmp/"typst-lsp")
            run { "install", tmp/"typst-lsp", "~/.local/bin/" }
        end)
    end
end

if FORCE or not installed "tinymist" then
    if fs.is_file(HOME/".cargo/bin/cargo") then
        gitclone "https://github.com/Myriad-Dreamin/tinymist"
        run {
            "cd", FU_PATH/"tinymist",
            "&&",
            "~/.cargo/bin/cargo install --path . --root ~/.local",
        }
    else
        local version = download("https://github.com/Myriad-Dreamin/tinymist/releases/latest"):match("tag/(v[%d%.]+)")
        fs.with_tmpdir(function(tmp)
            download("https://github.com/Myriad-Dreamin/tinymist/releases/download"/version/"tinymist-linux-x64", tmp/"tinymist")
            run { "install", tmp/"tinymist", "~/.local/bin/" }
        end)
    end
end
--]]
