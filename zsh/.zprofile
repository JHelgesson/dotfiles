# Initialize Homebrew for login shells before the rest of zsh loads.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$brew_bin" ]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done

if [ -f "$HOME/.config/zsh/path.zsh" ]; then
  source "$HOME/.config/zsh/path.zsh"
fi
