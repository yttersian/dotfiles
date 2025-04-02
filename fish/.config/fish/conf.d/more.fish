function fish_greeting
    # echo twice is the best gg
end

if not contains "$HOME/.local/bin" $PATH
    set -x PATH "$HOME/.local/bin" $PATH
end
