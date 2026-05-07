export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

if [ -f "$HOME/.config/zsh/path.zsh" ]; then
  source "$HOME/.config/zsh/path.zsh"
fi

typeset -U fpath FPATH

if [ -d "$HOME/.docker/completions" ]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

plugins=(
  git
  kubectl
  zsh-autosuggestions
  zsh-completions
  fzf-tab
  zsh-history-substring-search
  zsh-syntax-highlighting
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias gs="git status"
alias k="kubectl"

if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  source "$HOME/.config/zsh/local.zsh"
fi

eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/atomic.omp.json")"
