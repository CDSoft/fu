# https://wiki.debian.org/Xsession
# note that the ~/.xsession file is only read if you are using a Debian X session.
# If you login with gdm3 and choose a GNOME session, the ~/.xsession file will be ignored completely.
# (But you may still use ~/.xsessionrc.)

[ -z "$SSH_AGENT_PID" ] && eval "$(ssh-agent -s)"

export PATH=~/.local/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)

# Same pixel ratio on all screens
export WINIT_X11_SCALE_FACTOR=1
# https://unix.stackexchange.com/questions/596887/how-to-scale-the-resolution-display-of-the-desktop-and-or-applications
export QT_AUTO_SCREEN_SET_FACTOR=0
export QT_SCALE_FACTOR=1
export QT_FONT_DPI=96
export GDK_SCALE=1
export GDK_DPI_SCALE=1

export QT_QPA_PLATFORMTHEME=qt5ct
