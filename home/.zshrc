export ZSH="$HOME/.zsh/oh-my-zsh"
ZSH_THEME="spaceship"

plugins=(zsh-autosuggestions git)

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
  history-search-forward
  history-search-backward
  history-beginning-search-forward
  history-beginning-search-backward
  history-substring-search-up
  history-substring-search-down
  up-line-or-beginning-search
  down-line-or-beginning-search
  up-line-or-history
  down-line-or-history
  accept-line
  copy-earlier-word
  bracketed-paste
)

source "$ZSH/oh-my-zsh.sh"

# Aliases
alias cat="batcat --style plain"
alias bat="batcat"
alias grep="rg"
alias jwt-decode="jq -R 'split(\".\") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<<"

# Enable fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# Enable sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
