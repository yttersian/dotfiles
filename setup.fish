#!/usr/bin/env fish

set PACKAGES (cat packages)
set DOTFILES_REPO (cat dotfiles_repo)

function get_package_manager
    switch (uname)
        case Linux
            if test -f /etc/arch-release
                set -g INSTALL_PKG "sudo pacman -S --needed"
                set -g PACKAGE_MANAGER "pacman"
            end
        case Darwin
            if not command -q brew
                echo (set_color -o red)"Homebrew not installed. Aborting setup"(set_color normal)
                exit 1
            end
            set -g INSTALL_PKG "brew install"
            set -g PACKAGE_MANAGER "brew"
        case '*'
            echo (set_color -o red)"Unsupported OS. Aborting setup"(set_color normal)
            exit 1
    end
end

function install_packages
    # Select packages
    echo -e "\nPackages to install:"
    for i in (seq 1 (count $PACKAGES))
        echo "$i " (echo $PACKAGES[$i])
    end
    read -P "Select by index (space separated, default=all): " indices
    if test -z $indices
        set selection $PACKAGES
    else
        for i in (string split " " $indices)
            if test $i -ge 1 -a $i -le (count $PACKAGES)
                set -a selection $PACKAGES[$i]
            end
        end
    end

    # Install selection
    read -P "Install [$selection]? (y/N): " confirm
    if test "$confirm" = "y" -o "$confirm" = "Y"
        eval $INSTALL_PKG $selection
    else
        echo (set_color -o)"Installation skipped"(set_color normal)
    end
end

function sync_dotfiles

end

get_package_manager
echo (set_color -o)"Package manager: $PACKAGE_MANAGER"(set_color normal)

install_packages

if test $USER != "root" -a ! -d $HOME/.dotfiles
    sync_dotfiles
end
