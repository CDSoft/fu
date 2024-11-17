# Environment variables

export PATH=~/.local/bin:~/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)
export MANPAGER='nvim +Man!'
#export TERM=gnome-256color

export QT_QPA_PLATFORMTHEME=qt5ct

export LANG=%(LOCALE)

# Aliases

[ -e /etc/grc.zsh ] && . /etc/grc.zsh

alias ls="eza --classify --git"
alias ll='ls -lh'
alias la='ll -a'
#alias lt='ll -rt'
alias lt='ll --sort newest'

alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

alias more=less
alias df='df -h'
alias du='du -h'
alias ncdu='ncdu --color dark'

#alias luax='rlwrap -m -s 10000 luax'
#alias calculadoira='rlwrap -m -s 10000 calculadoira'
alias ocaml='rlwrap -m -s 10000 ocaml'
alias luajit='rlwrap -m -s 10000 luajit'

alias subup='git submodule sync && git submodule update --init --recursive'

function gd()
{
    local filepath="$(fd "$1" | fzf)"
    [ -f "$filepath" ] && filepath="$(dirname "$filepath")"
    cd "$filepath"
}

# Force compression level with tar

export GZIP_OPT="-9"
export XZ_OPT="-9"

# OMZ scripts

. %(FU_PATH)/ohmyzsh/lib/completion.zsh
. %(FU_PATH)/ohmyzsh/lib/correction.zsh
. %(FU_PATH)/ohmyzsh/lib/history.zsh
. %(FU_PATH)/ohmyzsh/lib/key-bindings.zsh

# Haskell and ocaml environment

[ -f ~/.ghcup/env ] && . ~/.ghcup/env
[ -f /usr/bin/opam ] && eval "$(opam env)"

# Completion

zstyle ':completion:*:*:make:*' tag-order 'targets'

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

[ -f ~/.local/bin/pandoc ] && eval "$(pandoc --bash-completion)"

[ -f ~/.ghcup/bin/stack ] && eval "$(stack --bash-completion-script stack)"

# zoxide

eval "$(zoxide init zsh)"

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

# Plugins

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="-m"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f %(FU_PATH)/fzf-git.sh/fzf-git.sh ] && source %(FU_PATH)/fzf-git.sh/fzf-git.sh

gco() {
  local selected=$(_fzf_git_each_ref --no-multi)
  [ -n "$selected" ] && git checkout "$selected"
}

# Starship: https://starship.rs
hash starship 2>/dev/null && eval "$(starship init zsh)"

function precmd_set_win_title()
{
    echo -ne "\033]0;${PWD/#$HOME/~}\007"
}

function preexec_set_win_title()
{
    echo -ne "\033]0;$1\007"
}

precmd_functions+=(precmd_set_win_title)
preexec_functions+=(preexec_set_win_title)

# https://github.com/zsh-users/zsh-syntax-highlighting

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md

# Only highlight small lines
ZSH_HIGHLIGHT_MAXLENGTH=512

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

# Override highlighter colors
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[globbing]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=red,bold'

. %(FU_PATH)/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# https://github.com/zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_STRATEGY=(history)

. %(FU_PATH)/zsh-autosuggestions/zsh-autosuggestions.zsh

# luarocks
eval "$(luarocks path --bin)"

# LuaX environment
eval "$(\luax env)"       # \luax to skip the luax alias and let mc start faster

# Lua Language Server
alias luamake=%(FU_PATH)/lua-language-server/3rd/luamake/luamake

%(when(HOSTNAME=="work") [==[
# Work configuration

#alias docker='docker -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v /dev/bus/usb:/dev/bus/usb --privileged -p host_port:container_port/tcp'
xhost +local:root >/dev/null 2>/dev/null

alias stop_containers="docker ps -q | xargs --no-run-if-empty docker stop"
alias rm_containers="docker ps -a -q | xargs --no-run-if-empty docker rm"
alias rm_dang_images="docker images -q --filter \"dangling=true\" | xargs --no-run-if-empty docker rmi"
alias rm_dang_volumes="docker volume ls -q -f=\"dangling=true\" | xargs --no-run-if-empty docker volume rm"

[ -f /usr/lib64/ros/setup.zsh ] && . /usr/lib64/ros/setup.zsh
]==])

# no warnings in Wine
export WINEDEBUG=-all

# Other user configuration from ~/.myconf

%(myconf.zsh or "")

# User specific environment and startup programs
[ -n "$SSH_AGENT_PID" ] || eval "$(ssh-agent -s)"

# Clean PATH (fix fzf PATH order)
eval "$(clean_path)"
