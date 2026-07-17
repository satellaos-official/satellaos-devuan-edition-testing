# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ── History ───────────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# ── General shell options ─────────────────────────────────────────────────────
shopt -s checkwinsize
#shopt -s globstar

# ── Color support ─────────────────────────────────────────────────────────────
if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

# ── Distrobox / Host detection ────────────────────────────────────────────────
if [ -f /run/.containerenv ]; then
    IN_CONTAINER=1
    . /etc/os-release
    PROMPT_ID="distrobox@${ID}-${VERSION_ID}"
else
    IN_CONTAINER=0
    PROMPT_ID="\u@\h"
fi

# ── Prompt colors ─────────────────────────────────────────────────────────────
NEWLINE_BEFORE_PROMPT=yes

if [ "$color_prompt" = yes ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1

    if [ "$EUID" -eq 0 ]; then
        C1="\[\033[1;31m\]"   # root: red
        C2="\[\033[1;31m\]"
    else
        C1="\[\033[38;2;127;63;191m\]"   # purple
        C2="\[\033[1;38;2;127;63;191m\]" # bold purple
    fi
    RESET="\[\033[0m\]"
else
    C1=""
    C2=""
    RESET=""
fi

# ── Prompt ────────────────────────────────────────────────────────────────────
PS1="${C1}┌──${VIRTUAL_ENV:+(${RESET}\[\033[0;1m\]\$(basename \$VIRTUAL_ENV)${C1})}(${C2}${PROMPT_ID}${C1})-[\[\033[0;1m\]\w${C1}]
${C1}└─${C2}\$${RESET} "

[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"

# ── xterm title bar ───────────────────────────────────────────────────────────
[[ "$TERM" == xterm* ]] && PS1="\[\e]0;\u@\h: \w\a\]$PS1"

# ── Color support: ls, less, man ──────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    if [ -n "${HOME:-}" ] && test -r "$HOME/.dircolors"; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
    export LS_COLORS="$LS_COLORS:ow=30;44:"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'
    export LESS_TERMCAP_md=$'\E[1;36m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;33m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[1;32m'
    export LESS_TERMCAP_ue=$'\E[0m'
fi

# ── Per-user bash_aliases ─────────────────────────────────────────────────────
if [ -n "${HOME:-}" ] && [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# ── Tab completion ────────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ── PATH & input method ───────────────────────────────────────────────────────
export PATH=$PATH:/sbin:/usr/sbin
export GTK_IM_MODULE=uim
export QT_IM_MODULE=uim
export XMODIFIERS="@im=uim"

# ── Distrobox title ───────────────────────────────────────────────────────────
if [ "$IN_CONTAINER" -eq 1 ]; then
    echo -ne "\033]0;${PROMPT_ID}\007"
fi

# ── Fastfetch ─────────────────────────────────────────────────────────────────
alias fastfetch='fastfetch --logo-color-1 "38;2;127;63;191" --logo /usr/share/satellaos-core/pictures/ascii-art/satellaos.asc'
