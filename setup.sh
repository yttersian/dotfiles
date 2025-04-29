#!/usr/bin/env bash

set -euo pipefail

PACKAGES=(
    starship
    helix
    eza
    zoxide
    fd
    ripgrep
    bat
    tokei
)

APT_PACKAGES=(
    fish
    stow
)

SNAP_PACKAGES=(
    ghostty
)

DOTFILES_REPO="https://github.com/yttersian/dotfiles.git"

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
ORANGE="$(tput setaf 214 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
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

blank_line() {
    printf '%s\n'
}

confirm() {
    printf "%s " "${BLUE}?${NO_COLOR} $* ${BOLD}[y/N]${NO_COLOR}"
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

install_with() {
    local MANAGER=$1
    shift
    local PACKAGES=("$@")
    local INSTALL_PKG
    local ICON="🚀"
    local COLOR="$CYAN"

    case $MANAGER in
        pacman)
            INSTALL_PKG="sudo pacman -S --needed"
            ;;
        apt)
            INSTALL_PKG="sudo apt install -qq -y"
            ;;
        snap)
            INSTALL_PKG="sudo snap install --classic"
            COLOR="$MAGENTA"
            ICON="📦"
            ;;
        brew)
            INSTALL_PKG="brew install -q"
            COLOR=$YELLOW
            ICON="🍺"
            ;;
        *)
            error "Unsupported package manager: $manager"
            return 1
            ;;
    esac

    printf "\n${BOLD}${COLOR}$ICON Packages to install with $MANAGER:${NO_COLOR}\n"

    for package in "${PACKAGES[@]}"; do
        info "$package"
    done
    if confirm "Confirm?"; then
        info "Installing ..."
        $INSTALL_PKG "${PACKAGES[@]}"
        completed "Done"
    else
        info "Skipped"
    fi
}

install_homebrew() {
    if ! has brew; then
        info "Installing Homebrew ..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        completed "Homebrew installed"
    else
        info "Updating Homebrew packages ..."
        brew update
        brew upgrade
    fi
}

install_rust() {
    if ! has cargo; then
        info "Installing Rust ..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
        printf "${BOLD}${ORANGE}🦀 Oxidized${NO_COLOR}\n"
    else
        printf "${BOLD}${ORANGE}🦀 You're already oxidized${NO_COLOR}\n"
        rustup check
    fi
    blank_line
}

install_uv() {
    if ! has uv; then
        info "Installing uv ..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        completed "uv installed"
    else
        info "Updating uv ..."
        uv self update
    fi
    blank_line
}

setup_shell() {
    if [[ $(basename "$SHELL") != "fish" ]]; then
        if confirm "Set fish as the default shell?"; then
            chsh -s "$(command -v fish)"
        else
            return
        fi
        completed "Login shell set to fish, restart your terminal to apply the changes"
    fi
}

sync_dotfiles() {
    if [[ "$USER" != "root" && ! -d "$HOME/.dotfiles" ]]; then
        info "Sync dotfiles?"
        if confirm "Directory to be created: ${BOLD}${UNDERLINE}$HOME/.dotfiles${NO_COLOR}"; then
            cd "$HOME"
            git clone "$DOTFILES_REPO" .dotfiles
            completed "dotfiles synced, go ahead and manually symlink with stow"
        else
            info "dotfiles sync skipped"
        fi
    fi
}

setup_arch() {
    install_with pacman "$PACKAGES $APT_PACKAGES $SNAP_PACKAGES"
    if ! has hx; then
        sudo ln -s $(command -v helix) /usr/local/bin/hx
    fi
}

setup_ubuntu() {
    info "Updating system ..."
    DEBIAN_FRONTEND=noninteractive sudo apt update -qq 2>&1 | grep -v "stable CLI interface" | grep -v "Skipping acquire"
    DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y -qq 2>&1 | grep -v "stable CLI interface" | grep -v "Skipping acquire"
    sudo apt install -qq -y build-essential git curl >/dev/null 2>&1
    install_homebrew
    install_with apt "${APT_PACKAGES[@]}"
    install_with snap "${SNAP_PACKAGES[@]}"
    install_with brew "${PACKAGES[@]}"
}

setup_mac() {
    install_homebrew
    install_with brew "$PACKAGES $APT_PACKAGES"
}

# Script
get_os
completed "OS detected: $OS"

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
blank_line

install_rust
install_uv

setup_shell
sync_dotfiles

completed "Setup complete"
