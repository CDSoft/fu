# Aliases

alias ls="exa --classify"
alias ll='ls -lh'
alias la='ll -a'
#alias lt='ll -rt'
alias lt='ll --sort newest'

alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

alias more=less
alias df='grc df -h'
alias du='grc du -h'
alias ncdu='ncdu --color dark'

alias top='procs -w --sortd UsageCpu'

alias ocaml='rlwrap ocaml'
alias luajit='rlwrap luajit'

function gd()
{
    local filepath="$(fd "$1" | fzf)"
    [ -f "$filepath" ] && filepath="$(dirname "$filepath")"
    cd "$filepath"
}

# OMZ scripts

. %(repo_path)/ohmyzsh/lib/completion.zsh
. %(repo_path)/ohmyzsh/lib/correction.zsh
. %(repo_path)/ohmyzsh/lib/history.zsh
. %(repo_path)/ohmyzsh/lib/key-bindings.zsh

# Completion

zstyle ':completion:*:*:make:*' tag-order 'targets'

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

%(cfg_yesno("haskell", "Install Haskell?") and 'eval "$(stack --bash-completion-script stack)"' or '')
eval "$(pandoc --bash-completion)"

# Third-party configuration

%(cfg_yesno("ocaml", "Install OCaml?") and '. ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true' or '')
%(cfg_yesno("rust", "Install Rust?") and '. ~/.cargo/env' or '')

# Plugins

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="-m"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

%( cfg_yesno("work", "Install work configuration") and [==[
# Work configuration

#alias docker='docker -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v /dev/bus/usb:/dev/bus/usb --privileged -p host_port:container_port/tcp'
xhost +local:root >/dev/null 2>/dev/null

alias subup='git submodule sync && git submodule update --init --recursive'

alias stop_containers="docker ps -q | xargs --no-run-if-empty docker stop"
alias rm_containers="docker ps -a -q | xargs --no-run-if-empty docker rm"
alias rm_dang_images="docker images -q --filter \"dangling=true\" | xargs --no-run-if-empty docker rmi"
alias rm_dang_volumes="docker volume ls -q -f=\"dangling=true\" | xargs --no-run-if-empty docker volume rm"

. /usr/lib64/ros/setup.zsh
]==] or ""
)

# cd with vifm

vicd()
{
    local dst="$(command vifm -c only --choose-dir - "$@")"
    if [ -z "$dst" ]; then
        echo 'Directory picking cancelled/failed'
        return 1
    fi
    cd "$dst"
}

# Other user configuration

if [ -f ~/.zuser ]
then
    . ~/.zuser
fi
