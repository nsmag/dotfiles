#!/bin/zsh

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install things in Brewfile
brew bundle

# Stow
stow bat
stow git
stow karabiner
stow kitty
stow nvim
stow rtx
stow starship
stow tmux
stow zsh

# Install tools via rtx
source <(rtx activate zsh)
rtx install
