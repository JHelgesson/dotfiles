export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

if [ -f "$HOME/.config/zsh/path.zsh" ]; then
  source "$HOME/.config/zsh/path.zsh"
fi

typeset -U fpath FPATH

# Load Homebrew completions before Oh My Zsh initializes completion.
_dotfiles_brew_prefix=''
if command -v brew >/dev/null 2>&1; then
  _dotfiles_brew_prefix=$(brew --prefix)
  fpath=("$_dotfiles_brew_prefix/share/zsh/site-functions" $fpath)
fi

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
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#a89984'

# Use Gruvbox for both shell widgets and completion pickers.
_dotfiles_fzf_colors='fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#fbf1c7,bg+:#3c3836,hl+:#fe8019,info:#a89984,prompt:#b8bb26,pointer:#83a598,marker:#d3869b,border:#665c54,header:#a89984'
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border=rounded --info=inline --color=$_dotfiles_fzf_colors"
export BAT_THEME='gruvbox-dark'
if command -v fd >/dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude .git'
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --paging=never --line-range=:300 -- {}' --preview-window=right,55%,border-left --bind 'ctrl-/:toggle-preview' --header 'Ctrl-/: visa/dölj förhandsvisning'"
fi
zstyle ':fzf-tab:*' fzf-flags \
  '--height=60%' \
  '--layout=reverse' \
  '--border=rounded' \
  '--info=inline' \
  '--prompt=> ' \
  '--pointer=> ' \
  '--marker=* ' \
  "--color=$_dotfiles_fzf_colors"

unset _dotfiles_fzf_colors

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Load after Oh My Zsh, which otherwise replaces Ctrl-R. Keep fzf-tab on Tab.
if [[ -n $_dotfiles_brew_prefix && -r "$_dotfiles_brew_prefix/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$_dotfiles_brew_prefix/opt/fzf/shell/key-bindings.zsh"
fi
unset _dotfiles_brew_prefix

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias gs="git status"
alias k="kubectl"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  source "$HOME/.config/zsh/local.zsh"
fi

if [ -f "$HOME/.config/zsh/welcome.zsh" ]; then
  source "$HOME/.config/zsh/welcome.zsh"
fi

eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/atomic.omp.json")"
# BEGIN dev-agent PATH
export PATH="$HOME"/.local/bin:"$PATH"
# END dev-agent PATH

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
