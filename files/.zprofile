export PATH=~/.local/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)

# Get the aliases and functions
if [ -f ~/.zshrc ]; then
    . ~/.zshrc
fi

# User specific environment and startup programs
eval "$(ssh-agent -s)"
