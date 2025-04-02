function check_cmd
    command -q $argv[1]
end

if check_cmd eza
    alias ls "eza -F"
    alias ll "eza -lh --group-directories-first"
    alias la "eza -lah --group-directories-first"
    alias tree "eza --tree"
end

if check_cmd bat
    alias cat "bat"
end

if check_cmd ripgrep
    alias rg "ripgrep"
end

if check_cmd git
    abbr -a gs git status
    abbr -a gco git checkout
    abbr -a gl git log --all --decorate --oneline --graph
    abbr -a gls git log --all --decorate --oneline --graph --simplify-by-decoration
end
