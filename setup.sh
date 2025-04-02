#!/usr/bin/env bash

PACKAGES=$(cat packages)
DOTFILES_REPO=$(cat dotfiles_repo)

bold() {
    echo -e "\e[1m$*\e[0m"
}

green_bold() {
    echo -e "\e[1;32m$*\e[0m"
}

red_bold() {
    echo -e "\e[1;31m$*\e[0m"
}

get_os() {
    if [[ $(uname) == "Linux" ]]; then
        . /etc/os-release
        OS=$ID
    elif [[ $(uname) == "Darwin" ]]; then
        OS="macOS"
    else
        red_bold "OS not recognized. Aborting setup"
        exit 1
    fi
}

get_package_manager() {
    local OS=$1
    if [[ $OS == "arch" || $OS == "endeavouros" ]]; then
        INSTALL_PKG="sudo pacman -S --needed"
        PACKAGE_MANAGER="pacman"
    elif [[ $OS == "macOS" ]]; then
        if ! command -v brew > /dev/null; then
            red_bold "homebrew not installed. Aborting setup" >&2
            exit 1
        fi
        INSTALL_PKG="brew install"
        PACKAGE_MANAGER="brew"
    else
        red_bold "Unsupported OS. Aborting setup"
        exit 1
    fi
}

setup_shell() {
    shell=$(basename "$SHELL")
    if [[ $shell == "fish" || $shell == "zsh" ]]; then
        bold "Shell installed: $shell"
        return
    fi
    echo -e "\nInstall and set default shell?"
    read -p "Select shell: fish zsh (default=none): " shell
    if [[ $shell == "fish" || $shell == "zsh" ]]; then
        if ! command -v $shell > /dev/null; then
            $INSTALL_PKG $shell
        fi
        chsh -s $(which $shell)
    else
        bold "Skipping shell install"
    fi
}

install_packages() {
    echo -e "\nPackages to install: $PACKAGES"
    read -p "Continue? (default=yes): " confirm
    if [[ $confirm == "" ]]; then
        $INSTALL_PKG $PACKAGES
    else
        bold "Installation skipped"
    fi
}

sync_dotfiles() {
    echo -e "\nInstall stow and sync dotfiles?"
    read -p "Directory to be created: $HOME/.dotfiles (default=yes): " confirm
    if [[ $confirm == "" ]]; then
        $INSTALL_PKG stow
        cd $HOME
        git clone $DOTFILES_REPO .dotfiles
        green_bold "dotfiles synced, go ahead and manually symlink with stow"
    else
        bold "dotfiles sync skipped"
    fi
}

# Script
get_os
bold "OS detected: $OS"

get_package_manager "$OS"
bold "Package manager: $PACKAGE_MANAGER"

setup_shell
install_packages

if [[ $USER != "root" && ! -d $HOME/.dotfiles ]]; then
    sync_dotfiles
fi

green_bold "Setup complete"
