#!/bin/bash

# Initialize git global config
git config --global user.email "torbjorn.yttersian@gmail.com"
git config --global user.name "Torbjørn Yttersian"

# Install necessary packages
echo "Installing essential packages ..."
if [ "$(uname)" == "Darwin" ]; then
    brew install zsh stow
else
    sudo apt install zsh stow build-essential
fi
echo "Installing Rust ..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"

# Install navigation tools
echo "Installing navigation tools"
cargo install --locked bat eza starship

echo "Changing default login shell to zsh"
chsh -s $(which zsh)
stow .
