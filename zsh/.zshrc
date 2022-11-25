### Editor and locale
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

### PATH
export PATH="/usr/local/sbin:$PATH"

if [ -d "/usr/local/opt/ruby/bin" ]; then
  export PATH="/usr/local/opt/ruby/bin:$PATH"
  export PATH="`gem environment gemhome`/bin:$PATH"
  export PATH="`gem environment user_gemhome`/bin:$PATH"
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
