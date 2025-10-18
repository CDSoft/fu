if UPDATE or not installed "zig" or not installed "zls" then

    local sys = require "sys"

    local ZIG_VERSION = "0.15.2"
    local ZIG_KEY = "RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"

    dnf_install "curl minisign"

    -- zig
    do
        local curr_version = installed "zig" and read("zig version")
        if ZIG_VERSION ~= curr_version then
            fs.mkdirs(HOME/".local/opt")
            local mirrors = download "https://ziglang.org/download/community-mirrors.txt" : lines() : shuffle()
            local tarball = "zig-"..sys.arch.."-"..sys.os.."-"..ZIG_VERSION..".tar.xz"
            run { "rm -f", "~/.local/opt"/tarball, "~/.local/opt"/tarball..".minisig" }
            for _, mirror in ipairs(mirrors) do
                try_download(mirror.."/"..tarball, HOME/".local/opt"/tarball)
                if fs.is_file(HOME/".local/opt"/tarball) then
                    download(mirror.."/"..tarball..".minisig", HOME/".local/opt"/tarball..".minisig")
                    run { "minisign", "-Vm", HOME/".local/opt"/tarball, "-x", HOME/".local/opt"/tarball..".minisig", "-P", ZIG_KEY }
                    break
                end
            end
            assert(fs.is_file(HOME/".local/opt"/tarball))
            run { "rm -rf", "~/.local/opt/zig"/ZIG_VERSION }
            run { "mkdir -p", "~/.local/opt/zig"/ZIG_VERSION }
            run { "tar xJf", "~/.local/opt"/tarball, "-C", "~/.local/opt/zig"/ZIG_VERSION, "--strip-components 1" }
            run { "rm -f", "~/.local/opt"/tarball, "~/.local/opt"/tarball..".minisig" }
        end
        run { "ln -f -s", "~/.local/opt/zig"/ZIG_VERSION/"zig", "~/.local/bin/zig" }
    end

    -- zls
    do
        local curr_version = installed "zls" and db.zls_version
        local version = github_tag "https://github.com/zigtools/zls/releases/latest"
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
