-- VPN
if not fs.is_file "/etc/resolv.conf.orig" then
    dnf_install "NetworkManager-openvpn-gnome"
    run "systemctl disable --now systemd-networkd"
    if fs.is_file "/etc/resolv.conf" then
        run "sudo mv /etc/resolv.conf /etc/resolv.conf.orig"
    end
    run "systemctl restart NetworkManager"
end

--[[
-- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening
--sh "sudo update-crypto-policies --set LEGACY"
fs.with_tmpdir(function(tmp)
    local pmod = "RSA1024.pmod"
    fs.write(tmp/pmod, F.unlines {
        "# Allow certificates with 1024-bits RSA keys",
        "min_rsa_size = 1024",
    })
    run { "sudo cp", tmp/pmod, "/etc/crypto-policies/policies/modules/" }
end)
run "sudo update-crypto-policies --set DEFAULT:RSA1024"
--]]
