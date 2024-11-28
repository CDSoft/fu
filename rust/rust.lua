if not installed "rustc" then
    fs.with_tmpfile(function(tmp)
        download("https://sh.rustup.rs", tmp)
        run { "sh", tmp, "-y -v --no-modify-path" }
    end)
    run "~/.cargo/bin/rustup update stable"
elseif FORCE then
    run "rustup override set stable"
    run "rustup update stable"
end

-- Rust Language Server
if FORCE or not installed "rust-analyzer" then
    fs.with_tmpdir(function(tmp)
        download("https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz", tmp/"rust-analyzer.gz")
        run { "gunzip", tmp/"rust-analyzer.gz", "-o", HOME/".local/bin/rust-analyzer" }
    end)
    fs.chmod(HOME/".local/bin/rust-analyzer", fs.aR|fs.uW|fs.uX)
    run "~/.cargo/bin/rustup component add rust-src"
end
