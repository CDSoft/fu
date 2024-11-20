title(...)

-- dnf configuration

local dnf_conf = fs.read("/etc/dnf/dnf.conf")
local function add_param(name, val)
    local n
    dnf_conf, n = dnf_conf:gsub(name.."=(.-)\n", name.."="..val.."\n")
    if n == 0 then dnf_conf = dnf_conf..name.."="..val.."\n" end
end
add_param("fastestmirrors", "true")
add_param("max_parallel_downloads", "10")
add_param("defaultyes", "true")
fs.with_tmpfile(function(tmp)
    fs.write(tmp, dnf_conf)
    run { "sudo cp", tmp, "/etc/dnf/dnf.conf" }
end)

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
run { "sudo timedatectl set-timezone", TIMEZONE }
run { "sudo localectl set-keymap", KEYMAP }
run { "sudo localectl set-locale", LOCALE }

-- No more poweroff (power key disabled)
if fs.is_file "/etc/systemd/logind.conf" then
    run "sudo sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf"
end

-- Powertop autotune
if read "upower -e" : match "battery" then
    dnf_install "powertop"
    run "sudo systemctl start powertop.service"
    run "sudo systemctl enable powertop.service"
end

-- Higher inotify limits
run "sudo sysctl -q -p /etc/sysctl.d/99-inotify_limits.conf"
