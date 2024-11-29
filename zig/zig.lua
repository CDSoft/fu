if FORCE or not installed "zig" or not installed "zls" then

    -- zig
    do
        local ZIG_URL = "https://ziglang.org/download/"
        local index = download(ZIG_URL)
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
            fs.mkdirs(HOME/".local/opt")
            download(ZIG_ARCHIVE, "~/.local/opt"/fs.basename(ZIG_ARCHIVE))
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
        local version = download("https://github.com/zigtools/zls/releases/latest/"):match("tag/([%d%.]+)")
        if version ~= curr_version then
            fs.with_tmpdir(function(tmp)
                download("https://github.com/zigtools/zls/releases/download"/version/"zls-x86_64-linux.tar.xz", tmp/"zls-x86_64-linux.tar.xz")
                run { "tar xJf", tmp/"zls-x86_64-linux.tar.xz", "-C", HOME/".local/bin", "zls" }
                fs.touch(HOME/".local/bin/zls", tmp/"zls-x86_64-linux.tar.xz")
            end)
            db.zls_version = version
            db:save()
        end
    end

end
