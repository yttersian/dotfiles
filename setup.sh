#!/usr/bin/env bash

PACKAGES="\
starship \
helix \
eza \
zoxide \
fd \
ripgrep \
bat"

APT_PACKAGES="\
fish \
stow"

DOTFILES_REPO="https://github.com/yttersian/dotfiles.git"

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
  printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

warn() {
  printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

error() {
  printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

completed() {
  printf '%s\n' "${GREEN}✓${NO_COLOR} $*"
}

confirm() {
    printf "%s " "${MAGENTA}?${NO_COLOR} $* ${BOLD}[y/N]${NO_COLOR}"
    read -r yn </dev/tty
    [[ "$yn" == "y" || "$yn" == "yes" ]]
}

has() {
  command -v "$1" 1>/dev/null 2>&1
}

get_os() {
    if [[ $(uname) == "Linux" ]]; then
        . /etc/os-release
        OS=$ID
    elif [[ $(uname) == "Darwin" ]]; then
        OS="macOS"
    else
        error "OS not recognized. Aborting setup"
        exit 1
    fi
}

setup_shell() {
    if [[ $(basename "$SHELL") != "fish" ]]; then
        if confirm "Set fish as the default shell?"; then
            chsh -s $(which fish)
        else
            return
        fi
    fi
    completed "Login shell: fish"
}

install_rust() {
    if ! has cargo; then
        info "Installing Rust"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        . ~/.cargo/env
        completed "Rust installed"
    fi
}

install_homebrew() {
    if ! has brew; then
        info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        completed "Homebrew installed"
    fi
}

install_with() {
    local MANAGER=$1
    shift
    local PACKAGES=("$@")
    local INSTALL_PKG

    case $MANAGER in
        pacman)
            INSTALL_PKG="sudo pacman -S --needed"
            ;;
        apt)
            INSTALL_PKG="sudo apt install -q"
            ;;
        snap)
            INSTALL_PKG="sudo snap install --classic"
            ;;
        brew)
            INSTALL_PKG="brew install"
            ;;
        *)
            error "Unsupported package manager: $manager"
            return 1
            ;;
    esac

    info "Packages to install with $MANAGER:"
    for package in $PACKAGES; do
        info $package
    done
    if confirm "Confirm?"; then
        $INSTALL_PKG $PACKAGES
    else
        info "Installation skipped"
    fi
}

sync_dotfiles() {
    if [[ $USER != "root" && ! -d $HOME/.dotfiles ]]; then
        info "Sync dotfiles?"
        if confirm "Directory to be created: ${BOLD}${UNDERLINE}$HOME/.dotfiles${NO_COLOR}"; then
            cd $HOME
            git clone $DOTFILES_REPO .dotfiles
            completed "dotfiles synced, go ahead and manually symlink with stow"
        else
            info "dotfiles sync skipped"
        fi
    fi
}

setup_arch() {
    install_with pacman "$PACKAGES $APT_PACKAGES"
    sudo ln -s $(which helix) /usr/local/bin/hx
}

setup_ubuntu() {
    sudo apt update && sudo apt upgrade -y
    install_with apt "build-essential git curl $APT_PACKAGES"
    install_homebrew
    install_with brew "$PACKAGES"
}

setup_mac() {
    install_homebrew
    install_with brew "$PACKAGES"
}

# Script
get_os
completed "OS detected: $OS"

setup_shell
install_rust

case "$OS" in
    arch|endeavouros)
        setup_arch
        ;;
    ubuntu)
        setup_ubuntu
        ;;
    macOS)
        setup_mac
        ;;
    *)
        error "Unsupported OS. Aborting setup"
        exit 1
        ;;
esac

sync_dotfiles

completed "Setup complete"
