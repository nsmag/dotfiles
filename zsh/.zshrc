export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

autoload colors
colors

if [ ! "$(command -v brew)" ]; then
  echo "$fg[yellow][WARN]$fg[default] brew is not installed, the rest of the .zshrc will not be executed"
  return
fi

### completion
FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
autoload -Uz compinit bashcompinit
compinit
bashcompinit

### PATH
export GEM_HOME="$HOME/.gem"
export PATH="$HOME/.pub-cache/bin:$GEM_HOME/bin:$PATH"

### zsh-autosuggestions
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

### zsh-syntax-highlighting
if [ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

### starship
if [ "$(command -v starship)" ]; then
  # fix "starship_zle-keymap-select-wrapped:1: maximum nested function level reached; increase FUNCNEST?"
  # ref: https://github.com/starship/starship/issues/3418#issuecomment-2477375663
  if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
        "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
  fi

  source <(starship init zsh --print-full-init)
fi

### mise
if [ "$(command -v mise)" ]; then
  source <(mise activate zsh)
  source <(mise completion zsh)
fi

### pnpm
if [ "$(command -v pnpm)" ]; then
  source <(pnpm completion zsh)
fi

### flutter
if [ "$(command -v flutter)" ]; then
  source <(flutter bash-completion)
  export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
fi

### google-cloud-sdk
if [ -d "$(brew --prefix)/share/google-cloud-sdk" ]; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

### azure-cli
if [ -f "$(brew --prefix)/etc/bash_completion.d/az" ]; then
  source "$(brew --prefix)/etc/bash_completion.d/az"
fi

### terraform
if [ "$(command -v terraform)" ]; then
  complete -o nospace -C "$(brew --prefix)/bin/terraform" terraform
fi

### Aliases
unalias -m "vi"
alias vi="$EDITOR"

unalias -m "vim"
alias vim="$EDITOR"

if [ "$(command -v bat)" ]; then
  unalias -m "cat"
  alias cat='bat -pp'
fi

if [ "$(command -v dust)" ]; then
  unalias -m "du"
  alias du='dust'
fi

if [ "$(command -v eza)" ]; then
  unalias -m "ls"
  alias ls='eza --icons -s type'
fi

if [ "$(command -v kubectl)" ]; then
  unalias -m "k"
  alias k='kubectl'
fi
