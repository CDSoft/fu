-- dnf configuration

if FORCE or not db.dnf_configured then
    local dnf_conf = fs.read("/etc/dnf/dnf.conf")
    local function add_param(name, val)
        local n
        dnf_conf, n = dnf_conf:gsub(name.."=(.-)\n", name.."="..val.."\n")
        if n == 0 then dnf_conf = dnf_conf..name.."="..val.."\n" end
    end
    add_param("fastestmirrors", "true")
    add_param("max_parallel_downloads", "10")
    add_param("defaultyes", "true")
    if dnf_conf ~= fs.read("/etc/dnf/dnf.conf") then
        fs.with_tmpfile(function(tmp)
            fs.write(tmp, dnf_conf)
            run { "sudo cp", tmp, "/etc/dnf/dnf.conf" }
        end)
    end
    db.dnf_configured = true
    db:save()
end

repo("/etc/yum.repos.d/rpmfusion-free.repo", "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%(RELEASE).noarch.rpm")
repo("/etc/yum.repos.d/rpmfusion-nonfree.repo", "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%(RELEASE).noarch.rpm")

dnf_install [[
    dnf-plugins-core dnfdragora
    git
    curl wget
    xmlstarlet
]]

if fs.is_file "/usr/sbin/updatedb" then
    run "sudo dnf remove plocate"
end

-- Locale and timezone
if FORCE or not db.timezone_configured then
    run { "sudo timedatectl set-timezone", TIMEZONE }
    run { "sudo localectl set-keymap", KEYMAP }
    run { "sudo localectl set-locale", LOCALE }
    db.timezone_configured = true
    db:save()
end

-- No more poweroff (power key disabled)
if fs.is_file "/etc/systemd/logind.conf" then
    if FORCE or not db.poweroff_configured then
        if not fs.read("/etc/systemd/logind.conf"):match("HandlePowerKey=ignore") then
            run "sudo sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf"
        end
        db.poweroff_configured = true
        db:save()
    end
end

-- Powertop autotune
if FORCE or not db.powertop_configured then
    if read "upower -e" : match "battery" then
        dnf_install "powertop"
        run "sudo systemctl start powertop.service"
        run "sudo systemctl enable powertop.service"
    end
    db.powertop_configured = true
    db:save()
end

-- Higher inotify limits
if FORCE or not db.inotify_limits_configured then
    run "sudo sysctl -q -p /etc/sysctl.d/99-inotify_limits.conf"
    db.inotify_limits_configured = true
    db:save()
end
