dnf_install [[
    nmon
    openssh openssh-server
    nmap
    blueman
    network-manager-applet NetworkManager-tui
    socat
    sshpass
    minicom
    wireshark
    tigervnc
    openvpn
    telnet
    curl
    wget
    python3-pip
    lftp
    chkconfig
]]

db:once(FORCE, "network_configured", function()

    -- sshd
    run "sudo systemctl start sshd.service"
    run "sudo systemctl enable sshd.service"

    -- Disable firewalld
    --run "sudo systemctl disable firewalld" -- firewalld fails to stop during shutdown.

    -- wireshark
    run { "sudo usermod -a -G wireshark", USER }

end)
