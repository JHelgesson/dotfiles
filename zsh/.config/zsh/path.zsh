typeset -U path PATH

path=(
  "$HOME/bin"
  "$HOME/.lmstudio/bin"
  "$HOME/go/bin"
  $path
  "$HOME/.docker/bin"
)

export PATH
