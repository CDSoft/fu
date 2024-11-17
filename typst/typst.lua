title(...)

-- Typst language server
if FORCE or not installed "typst-lsp" then
    if fs.is_file(HOME/".cargo/bin/cargo") then
        gitclone "https://github.com/nvarner/typst-lsp.git"
        run {
            "cd", FU_PATH/"typst-lsp",
            "&&",
            "~/.cargo/bin/cargo install --path . --root ~/.local",
        }
    else
        local version = read("curl -sSL https://github.com/nvarner/typst-lsp/releases/latest"):match("tag/(v[%d%.]+)")
        version = version == "v0.6.0" and "v0.5.1"
                or version
        fs.with_tmpdir(function(tmp)
            run { "wget", "https://github.com/nvarner/typst-lsp/releases/download"/version/"typst-lsp-x86_64-unknown-linux-gnu", "-O", tmp/"typst-lsp" }
            run { "install", tmp/"typst-lsp", "~/.local/bin/" }
        end)
    end
end
