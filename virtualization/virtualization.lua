dnf_install [[
    VirtualBox
    virtualbox-guest-additions
    qemu-system-x86
    qemu-img
]]
dnf_install "akmod-VirtualBox kernel-devel-%(read 'uname -r')"
