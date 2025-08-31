function fish_greeting
    # echo twice is the best gg
end

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

fish_add_path --global --move "$HOME/.local/bin"

set -x XCOMPOSEFILE ~/.XCompose
