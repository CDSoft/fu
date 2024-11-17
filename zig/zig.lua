if FORCE or not installed "zig" or not installed "zls" then

    title(...)

    -- zig
    do
        local ZIG_URL = "https://ziglang.org/download/"
        local index = read { "curl -sSL", ZIG_URL }
        local ZIG_ARCHIVE = nil
        local ZIG_DIR
        index:gsub([[(https://ziglang%.org/download/[0-9.]+/(zig%-linux%-x86_64%-[0-9.]+)%.tar%.xz)]], function(url, name)
            if not ZIG_ARCHIVE then
                ZIG_ARCHIVE = url
                ZIG_DIR = name
            end
        end)
        assert(ZIG_ARCHIVE and ZIG_DIR, "Can not determine Zig version")
        local curr_version = installed "zig" and read("zig version")
        local version = ZIG_ARCHIVE:match("/([%d%.]+)/")
        local ZIG_VERSION = version

        if version ~= curr_version then
            run { "wget", ZIG_ARCHIVE, "-c", "-O", "~/.local/opt"/fs.basename(ZIG_ARCHIVE) }
            run { "rm -rf", "~/.local/opt/zig"/ZIG_VERSION }
            run { "mkdir -p", "~/.local/opt/zig"/ZIG_VERSION }
            run { "tar xJf", "~/.local/opt"/fs.basename(ZIG_ARCHIVE), "-C", "~/.local/opt/zig"/ZIG_VERSION, "--strip-components 1" }
            run { "ln -f -s", "~/.local/opt/zig"/ZIG_VERSION/"zig", "~/.local/bin/zig" }
            run { "rm -f", "~/.local/opt"/fs.basename(ZIG_ARCHIVE) }
        end
    end

    -- zls
    do
        local curr_version = installed "zls" and db.zls_version
        local version = read("curl -sSL https://github.com/zigtools/zls/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            fs.with_tmpdir(function(tmp)
                run { "wget", "https://github.com/zigtools/zls/releases/download"/version/"zls-x86_64-linux.tar.xz", "-O", tmp/"zls-x86_64-linux.tar.xz" }
                run {
                    "cd", tmp,
                    "&&",
                    "tar xJf zls-x86_64-linux.tar.xz",
                    "&&",
                    "mv", "zls", HOME/".local/bin/zls",
                    "&&",
                    "chmod +x", HOME/".local/bin/zls",
                }
                db.zls_version = version
            end)
            db:save()
        end
    end

end