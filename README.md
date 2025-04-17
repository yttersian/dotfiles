# My dotfiles

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles

Once installed, check out the dotfiles repo in the `$HOME` directory using git

```sh
git clone https://github.com/yttersian/dotfiles.git .dotfiles
cd .dotfiles
```

then use stow to create symlinks

```sh
stow [package name]
```

Et voilà!

## Setup

Run this command to bootstrap a fresh system

```sh
curl -fsSL https://raw.githubusercontent.com/yttersian/dotfiles/main/setup.sh | bash
```
