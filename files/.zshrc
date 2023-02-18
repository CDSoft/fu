# Environment variables

export PATH=~/.local/bin:~/bin:$PATH

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=%(BROWSER)
export MANPAGER='nvim +Man!'
export TERM=gnome-256color

export QT_QPA_PLATFORMTHEME=qt5ct

export LANG=%(LOCALE)

# Aliases

[ -e /etc/grc.zsh ] && . /etc/grc.zsh

alias ls="exa --classify"
alias ll='ls -lh'
alias la='ll -a'
#alias lt='ll -rt'
alias lt='ll --sort newest'

alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

alias more=less
alias df='df -h'
alias du='du -h'
alias ncdu='ncdu --color dark'

alias ocaml='rlwrap ocaml'
alias luajit='rlwrap luajit'

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

. %(repo_path)/ohmyzsh/lib/completion.zsh
. %(repo_path)/ohmyzsh/lib/correction.zsh
. %(repo_path)/ohmyzsh/lib/history.zsh
. %(repo_path)/ohmyzsh/lib/key-bindings.zsh

%(when(cfg.haskell or cfg.ocaml) [=[# Haskell and ocaml environment

%(when(cfg.haskell) '[ -f ~/.ghcup/env ] && . ~/.ghcup/env')
%(when(cfg.ocaml) 'eval "$(opam env)"')
]=])

# Completion

zstyle ':completion:*:*:make:*' tag-order 'targets'

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

eval "$(pandoc --bash-completion)"

%(when(cfg.haskell) 'eval "$(stack --bash-completion-script stack)"')

# zoxide

eval "$(zoxide init zsh)"

# Third-party configuration

%(when(cfg.frama_c) '[ -r ~/.opam/opam-init/init.zsh ] && . ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true')
%(when(cfg.rust) '. ~/.cargo/env')
%(when(cfg.freepascal_language_server) [=[
export FPCDIR='/usr/share/fpcsrc'       # FPC source directory (This is the only required option for the server to work).
export PP='/usr/bin/ppcx64'             # Path to the Free Pascal compiler executable.
export LAZARUSDIR='/usr/lib64/lazarus'  # Path to the Lazarus sources.
export FPCTARGET=''                     # Target operating system for cross compiling.
export FPCTARGETCPU='x86_64'            # Target CPU for cross compiling.
]=])

# Plugins

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="-m"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f %(repo_path)/fzf-git.sh/fzf-git.sh ] && source %(repo_path)/fzf-git.sh/fzf-git.sh

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

. %(repo_path)/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

# Override highlighter colors
ZSH_HIGHLIGHT_STYLES[globbing]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=red,bold'

# https://github.com/zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_STRATEGY=(history)

. %(repo_path)/zsh-autosuggestions/zsh-autosuggestions.zsh

# luarocks
eval "$(luarocks path --bin)"

# LuaX environment
eval "$(luax env)"

# Lua Language Server
alias luamake=%(repo_path)/lua-language-server/3rd/luamake/luamake

%(when(cfg.work) [==[
# Work configuration

#alias docker='docker -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v /dev/bus/usb:/dev/bus/usb --privileged -p host_port:container_port/tcp'
xhost +local:root >/dev/null 2>/dev/null

alias subup='git submodule sync && git submodule update --init --recursive'

alias stop_containers="docker ps -q | xargs --no-run-if-empty docker stop"
alias rm_containers="docker ps -a -q | xargs --no-run-if-empty docker rm"
alias rm_dang_images="docker images -q --filter \"dangling=true\" | xargs --no-run-if-empty docker rmi"
alias rm_dang_volumes="docker volume ls -q -f=\"dangling=true\" | xargs --no-run-if-empty docker volume rm"

%(when(FEDORA and cfg.ros)
    ". /usr/lib64/ros/setup.zsh")
]==])

# no warnings in Wine
export WINEDEBUG=-all

# Other user configuration

if [ -f ~/.zuser ]
then
    . ~/.zuser
fi

# User specific environment and startup programs
[ -n "$SSH_AGENT_PID" ] || eval "$(ssh-agent -s)"
