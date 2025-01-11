# Environment variables

export PATH=~/.local/bin:~/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)
export MANPAGER='nvim +Man!'
#export TERM=gnome-256color

export QT_QPA_PLATFORMTHEME=qt5ct

export LANG=%(LOCALE)

# Haskell and ocaml environment

[ -f ~/.ghcup/env ] && . ~/.ghcup/env
[ -f /usr/bin/opam ] && eval "$(opam env)"

# Third-party configuration

[ -r ~/.opam/opam-init/init.zsh ] && . ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
[ -f ~/.cargo/env ] && . ~/.cargo/env
if [ -f /usr/bin/ppcx64 ]
then
    export FPCDIR='/usr/share/fpcsrc'       # FPC source directory (This is the only required option for the server to work).
    export PP='/usr/bin/ppcx64'             # Path to the Free Pascal compiler executable.
    export LAZARUSDIR='/usr/lib64/lazarus'  # Path to the Lazarus sources.
    export FPCTARGET=''                     # Target operating system for cross compiling.
    export FPCTARGETCPU='x86_64'            # Target CPU for cross compiling.
fi
[ -f ~/.wasmer/wasmer.sh ] && . ~/.wasmer/wasmer.sh

# luarocks
[ -x /usr/bin/luarocks ] && eval "$(luarocks path --bin)"

# LuaX environment
eval "$(\luax env)"       # \luax to skip the luax alias and let mc start faster

# fzf environment

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="-m"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# no warnings in Wine
export WINEDEBUG=-all

# Other user configuration from ~/.myconf

%(myconf.zshenv or "")

# Clean PATH (fix fzf PATH order)
eval "$(clean_path)"
