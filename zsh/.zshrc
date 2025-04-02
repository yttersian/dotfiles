check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

need_cmd() {
    if ! check_cmd "$1"; then
        return 1
    fi
}

# Navigation
if need_cmd eza; then
    alias ls="eza -F"
    alias ll="eza -lah --group-directories-first"
    alias tree="eza --tree"
fi

if need_cmd bat; then
    alias cat="bat"
fi

# Git
alias gs="git status"
alias gco="git checkout"
alias gl="git log --all --decorate --oneline --graph"
alias gls="gl --simplify-by-decoration"

# Initialize starship
eval "$(starship init zsh)"
