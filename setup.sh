#!/bin/zsh

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install things in Brewfile
brew bundle

# Install node
fnm install --lts

# Stow
stow bat
stow git
stow kitty
stow nvim
stow starship
stow tmux
stow zsh
