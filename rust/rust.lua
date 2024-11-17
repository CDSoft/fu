title(...)

dnf_install "curl"

if not installed "rustc" then
    fs.with_tmpfile(function(tmp)
        run { "curl https://sh.rustup.rs -sSf -o", tmp }
        run { "sh", tmp, "-y -v --no-modify-path" }
    end)
    run "~/.cargo/bin/rustup update stable"
elseif UPDATE then
    run "rustup override set stable"
    run "rustup update stable"
end

-- Rust Language Server
if FORCE or not installed "rust-analyzer" then
    run "curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer"
    run "chmod +x ~/.local/bin/rust-analyzer"
    run "~/.cargo/bin/rustup component add rust-src"
end
