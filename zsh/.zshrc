### Editor and locale
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

### Path
export PATH="$(go env GOPATH)/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

### ZSH Autosuggestions
if [ -d "$HOMEBREW_PREFIX/share/zsh-autosuggestions" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

### ZSH Syntax highlighting
if [ -d "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

### gh
if [ "$(command -v gh)" ]; then
  eval "$(gh completion -s zsh)"
fi

### Flutter
if [ "$(command -v flutter)" ]; then
  eval "$(flutter bash-completion)"
fi

### FNM
if [ "$(command -v fnm)" ]; then
  eval "$(fnm env --use-on-cd)"
fi

### Ruby
if [ -d "$HOMEBREW_PREFIX/opt/chruby/share/chruby" ]; then
  source "$HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh"
  source "$HOMEBREW_PREFIX/opt/chruby/share/chruby/auto.sh"
fi

### Starship
if [ "$(command -v starship)" ]; then
  eval "$(starship init zsh)"
fi

### Google Cloud SDK
if [ -d "$HOMEBREW_PREFIX/share/google-cloud-sdk" ]; then
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
fi

### Kubectl
if [ "$(command -v kubectl)" ]; then
  source <(kubectl completion zsh)
fi

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


