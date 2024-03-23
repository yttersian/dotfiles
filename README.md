# My dotfiles

This directory contains the config files for my system

## Installation

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles

Once installed, check out the dotfiles repo in the `$HOME` directory using git

```sh
git clone git@github.com:yttersian/dotfiles.git
cd dotfiles
```

then use stow to create symlinks

```sh
stow .
```

Et voilà!
