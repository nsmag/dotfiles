#!/bin/zsh

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install things in Brewfile
brew bundle

# Install node
fnm install --lts

# Install oh-my-zsh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Download spaceship theme
git clone https://github.com/spaceship-prompt/spaceship-prompt "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Download zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Download zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Stow
stow amethyst
stow bat
stow git
stow kitty
stow nvim

ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
  rm "$ZSHRC"
fi

stow zsh
