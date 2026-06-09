eval export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

eval "$(/opt/homebrew/bin/brew shellenv)"

### PATH
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:${PATH+:$PATH}"
export PATH="$HOME/.pub-cache/bin:${PATH+:$PATH}"
export PATH="$HOME/.local/bin:${PATH+:$PATH}"
export PATH="$HOME/.local/share/mise/shims:${PATH+:$PATH}"
