-- cryfs is already in the Fedora repository
--copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:fcsm:cryfs.repo", "fcsm/cryfs")

dnf_install [[
    gparted
    pcmanfm thunar
    backintime-common backintime-qt4
    timeshift
]]

dnf_install [[
    udftools
    encfs
    cryfs
    p7zip p7zip-gui p7zip-plugins
    mc vifm
    pmount
    exfatprogs fuse-exfat
    syslinux
    cryptsetup
    squashfs-tools squashfuse
    baobab ncdu qdirstat
    xz unrar lzip lz4
    archivemount sshfs curlftpfs
    fuse-zip
    zstd
]]

gitclone "https://github.com/vifm/vifm-colors"
run { "cp -f", FU_PATH/"vifm-colors/*.vifm", HOME/".config/vifm/colors/" }

gitclone "https://github.com/thimc/vifm_devicons"
run { "cp -f", FU_PATH/"vifm_devicons/favicons.vifm", HOME/".config/vifm/" }

-- 7Z
if UPDATE or not installed "7zzs" then
    local curr_version = (read "7zzs || true" or ""):words()[3]
    local version = download("https://github.com/ip7z/7zip/releases/latest/"):match("tag/([%d%.]+)")
    if version ~= curr_version then
        fs.with_tmpdir(function(tmp)
            download("https://github.com/ip7z/7zip/releases/download/"..version.."/7z"..(version:gsub("%.", "")).."-linux-x64.tar.xz", tmp/"7z.tar.xz")
            run { "cd", tmp, "&& tar -xvJf 7z.tar.xz --exclude=MANUAL --exclude='*.txt'" }
            run { "cp -af", tmp/"7zz*", "~/.local/bin" }
        end)
    end
end

-- Lzip
if UPDATE or not fs.is_file(HOME/".local/bin/lzip") or not fs.is_file(HOME/".local/bin/plzip") or not fs.is_file(HOME/".local/bin/tarlz") then
    local curr_version = db.lzip_build
    local version = download("https://github.com/CDSoft/lzip-builder/releases/latest/"):match("tag/(r%d+)")
    if version ~= curr_version then
        fs.with_tmpdir(function(tmp)
            download("https://github.com/CDSoft/lzip-builder/releases/download/"..version.."/lzip-build-"..version.."-linux-x86_64.tar.gz", tmp/"lzip-build.tar.gz")
            run { "tar -xvzf", tmp/"lzip-build.tar.gz", "-C", HOME/".local/bin" }
        end)
        db.lzip_build = version
        db:save()
    end
end
