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
stow ghostty
stow git
stow mise
stow nvim
stow opencode
stow starship
stow tabtab
stow tmux
stow zsh

# Update submodule
git submodule update --init --recursive

# Install tools via mise
source <(mise activate zsh)
mise install
