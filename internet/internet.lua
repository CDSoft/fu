title(...)

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

-- Remove unecessary language symlinks
run "sudo find /usr/share/myspell -type l -exec rm -v {} \\;"
