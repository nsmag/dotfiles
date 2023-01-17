### Editor and locale
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

### PATH
export PATH="/usr/local/sbin:$PATH"

if [ -x "$(command -v go)" ]; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

### ZSH
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="spaceship"
export HIST_STAMPS="yyyy-mm-dd"

plugins=(
  gcloud
  gh
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

zstyle ':omz:update' frequency 1

source "$ZSH/oh-my-zsh.sh"

unsetopt autocd

### Ruby
if [ -d "/usr/local/opt/chruby/share/chruby" ]; then
  source "/usr/local/opt/chruby/share/chruby/chruby.sh"
  source "/usr/local/opt/chruby/share/chruby/auto.sh"
fi

### Flutter
eval "$(flutter bash-completion)"

### fnm
eval "$(fnm env --use-on-cd)"

### Aliases
unalias -m 'vi'
alias vi="$EDITOR"

unalias -m 'vim'
alias vim="$EDITOR"

if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp'
fi

if [ "$(command -v exa)" ]; then
  unalias -m 'ls'
  alias ls='exa --icons -s type'
fi

if [ "$(command -v kubectl)" ]; then
  unalias -m 'k'
  alias k='kubectl'
fi
