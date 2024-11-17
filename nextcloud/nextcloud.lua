local nextcloud_installed = fs.is_file(HOME/".local/bin/Nextcloud")
if UPDATE or not nextcloud_installed then
    title(...)

    local version, new_version
    if nextcloud_installed then
        version = read(HOME/".local/bin/Nextcloud", "-v"):match("version%s+([%d%.]+)")
    end
    new_version = read "curl -sSL https://github.com/nextcloud-releases/desktop/releases/"
        : matches "tag/v([%d%.]+)\""
        : map(function(v) return v:split"%." end)
        : maximum(F.op.ule)
        : str "."
    --[[
    new_version = new_version == "3.9.0" and "3.8.2"
                or new_version
    --]]
    if new_version ~= version then
        if version then run { HOME/".local/bin/Nextcloud", "-q" } end
        fs.with_tmpdir(function(tmp)
            run {
                "wget", "https://github.com/nextcloud-releases/desktop/releases/download/v"..new_version.."/Nextcloud-"..new_version.."-x86_64.AppImage", "-O", tmp/"Nextcloud",
                "&&",
                "mv -f", tmp/"Nextcloud", HOME/".local/bin/Nextcloud",
                "&&",
                "chmod +x", HOME/".local/bin/Nextcloud",
            }
        end)
    end
end

