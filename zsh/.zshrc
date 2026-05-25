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

# Make autosuggestions readable against Ghostty's transparent background.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=246'

# Give fzf-tab a clearer, higher-contrast picker.
zstyle ':fzf-tab:*' fzf-flags \
  '--height=60%' \
  '--layout=reverse' \
  '--border=rounded' \
  '--info=inline' \
  '--prompt=> ' \
  '--pointer=> ' \
  '--marker=* ' \
  '--color=fg:#d0d7de,bg:#161b22,hl:#58a6ff,fg+:#ffffff,bg+:#1f2630,hl+:#79c0ff,info:#7ee787,prompt:#58a6ff,pointer:#ffa657,marker:#e3b341,border:#30363d'

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
