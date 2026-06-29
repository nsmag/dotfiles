export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

autoload colors
colors

### brew
if [ ! "$(command -v brew)" ]; then
  echo "$fg[yellow][WARN]$fg[default] brew is not installed, the rest of the .zshrc will not be executed"
  return
fi

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
fi

### completion
fpath=(~/.zsh/completion $(brew --prefix)/share/zsh/site-functions $fpath)
autoload -Uz compinit bashcompinit
compinit
bashcompinit

if [ "$(command -v mise)" ]; then
  source <(mise completion zsh)
fi

### pnpm
if [ "$(command -v corepack)" ]; then
  corepack enable pnpm
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
