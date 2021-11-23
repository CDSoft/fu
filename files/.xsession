# https://wiki.debian.org/Xsession
# note that the ~/.xsession file is only read if you are using a Debian X session.
# If you login with gdm3 and choose a GNOME session, the ~/.xsession file will be ignored completely.
# (But you may still use ~/.xsessionrc.)

[ -z "$SSH_AGENT_PID" ] && eval "$(ssh-agent -s)"

export PATH=~/.local/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)

export QT_QPA_PLATFORMTHEME=qt5ct

%(when(cfg_yesno("rust", "Install Rust?")) '. ~/.cargo/env')
