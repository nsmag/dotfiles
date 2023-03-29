### Editor and locale
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

### Brew env
eval "$(brew shellenv)"

### Path
export PATH="$(go env GOPATH)/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

### Ruby
if [ -d "/usr/local/opt/chruby/share/chruby" ]; then
  source "/usr/local/opt/chruby/share/chruby/chruby.sh"
  source "/usr/local/opt/chruby/share/chruby/auto.sh"
fi

### gh
eval "$(gh completion -s zsh)"

### Flutter
eval "$(flutter bash-completion)"

### FNM
eval "$(fnm env --use-on-cd)"

### Starship
eval "$(starship init zsh)"

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

### Autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

### Syntax highlighting
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
