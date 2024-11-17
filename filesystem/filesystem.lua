title(...)

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
do
    local curr_version = (read "7zzs || true" or ""):words()[3]
    local version = read("curl -sSL https://github.com/ip7z/7zip/releases/latest/"):match("tag/([%d%.]+)")
    if version ~= curr_version then
        fs.with_tmpdir(function(tmp)
            run { "wget", "https://github.com/ip7z/7zip/releases/download/"..version.."/7z"..(version:gsub("%.", "")).."-linux-x64.tar.xz", "-O", tmp/"7z.tar.xz" }
            run { "cd", tmp, "&& tar -xvJf 7z.tar.xz --exclude=MANUAL --exclude='*.txt'" }
            run { "cp -af", tmp/"7zz*", "~/.local/bin" }
        end)
    end
end
