export PATH=~/.local/bin:/var/lib/snapd/snap/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)

export QT_QPA_PLATFORMTHEME=qt5ct

# Get the aliases and functions
if [ -f ~/.zshrc ]; then
    . ~/.zshrc
fi

# User specific environment and startup programs
eval "$(ssh-agent -s)"
