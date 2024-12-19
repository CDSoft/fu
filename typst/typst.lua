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
