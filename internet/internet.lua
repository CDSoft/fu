dnf_install [[
    firefox
    torbrowser-launcher
    surf
    thunderbird
    transmission
    dnf-plugins-core
    chromium
]]

-- Default browser
run { "BROWSER= xdg-settings set default-web-browser", BROWSER..".desktop || true" }
run { "BROWSER= xdg-mime default", BROWSER..".desktop text/html" }
run { "BROWSER= xdg-mime default", BROWSER..".desktop x-scheme-handler/http" }
run { "BROWSER= xdg-mime default", BROWSER..".desktop x-scheme-handler/https" }
run { "BROWSER= xdg-mime default", BROWSER..".desktop x-scheme-handler/about" }

-- Firefox configuration
-- https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
-- https://askubuntu.com/questions/239543/get-the-default-firefox-profile-directory-from-bash
if fs.is_file(HOME/".mozilla/firefox/profiles.ini") then
    fs.read(HOME/".mozilla/firefox/profiles.ini"):lines():foreach(function(line)
        for profile in line:gmatch("Path=(.*)") do
            fs.copy("internet/user.js", HOME/".mozilla/firefox"/profile/"user.js")
        end
    end)
end

-- Thunderbird extensions
if FORCE or not fs.is_file(FU_PATH/"reply_as_original_recipient.xpi") then
    gitclone "https://github.com/qiqitori/reply_as_original_recipient.git"
    run { "cd", FU_PATH/"reply_as_original_recipient", "&&", "zip -r ../reply_as_original_recipient.xpi *" }
end

-- Remove unnecessary language symlinks
run "find /usr/share/myspell -type l -exec sudo rm -v {} \\;"

-- NextDNS
if myconf.nextdns then

    local resolved = F{
        fs.read("/etc/systemd/resolved.conf")
        : lines()
        : filter(function(line)
            local key = line:match "^%s*(%w+)%s*="
            return not myconf.nextdns[key]
        end),
        F(myconf.nextdns) : items() : map(function(key_val)
            local key, val = F.unpack(key_val)
            if type(val) == "table" then
                return F(val) : map(function(item)
                    return ("%s=%s"):format(key, item)
                end)
            else
                return ("%s=%s"):format(key, val)
            end
        end),
    } : flatten() : unlines()

    if resolved ~= fs.read("/etc/systemd/resolved.conf") then
        fs.with_tmpfile(function(tmp)
            fs.write(tmp, resolved)
            run { "sudo cp -f", tmp, "/etc/systemd/resolved.conf" }
        end)
    end

end
