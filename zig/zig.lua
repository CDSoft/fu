if UPDATE or not installed "zig" or not installed "zls" then

    local ZIG_VERSION = "0.14.1" -- undefine for autodetection

    -- zig
    do
        local ZIG_URL = "https://ziglang.org/download/"
        local ZIG_ARCHIVE = nil
        local ZIG_DIR
        if not ZIG_VERSION then
            local index = download(ZIG_URL)
            index:gsub([[(https://ziglang%.org/download/[0-9.]+/(zig%-linux%-x86_64%-[0-9.]+)%.tar%.xz)]], function(url, name)
                if not ZIG_ARCHIVE then
                    ZIG_ARCHIVE = url
                    ZIG_DIR = name
                end
            end)
            assert(ZIG_ARCHIVE and ZIG_DIR, "Can not determine Zig version")
            ZIG_VERSION = ZIG_ARCHIVE:match("/([%d%.]+)/")
        else
            ZIG_ARCHIVE = "https://ziglang.org/download/"..ZIG_VERSION.."/zig-x86_64-linux-"..ZIG_VERSION..".tar.xz"
        end
        local curr_version = installed "zig" and read("zig version")

        if ZIG_VERSION ~= curr_version then
            fs.mkdirs(HOME/".local/opt")
            download(ZIG_ARCHIVE, "~/.local/opt"/fs.basename(ZIG_ARCHIVE))
            run { "rm -rf", "~/.local/opt/zig"/ZIG_VERSION }
            run { "mkdir -p", "~/.local/opt/zig"/ZIG_VERSION }
            run { "tar xJf", "~/.local/opt"/fs.basename(ZIG_ARCHIVE), "-C", "~/.local/opt/zig"/ZIG_VERSION, "--strip-components 1" }
            run { "rm -f", "~/.local/opt"/fs.basename(ZIG_ARCHIVE) }
        end
        run { "ln -f -s", "~/.local/opt/zig"/ZIG_VERSION/"zig", "~/.local/bin/zig" }
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
