function !rust
    if not set -q argv[1]
        echo "Usage: !rust [SEARCH_TERM]"
        return
    end
    set search_term $argv[1]
    set url "https://doc.rust-lang.org/std/index.html?search=$search_term"
    open $url
end
