if FORCE or not installed "code" then
    fs.with_tmpdir(function(tmp)
        run {
            "cd", tmp,
            "&&",
            "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc",
            "&&",
            [=[ sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' ]=],
        }
    end)
    dnf_install "code"
end
