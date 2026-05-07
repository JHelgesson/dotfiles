#!/usr/bin/env bash
set -euo pipefail

oh_my_zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
custom_plugins_dir="${ZSH_CUSTOM:-$oh_my_zsh_dir/custom}/plugins"

clone_or_update() {
  local name="$1"
  local repo="$2"
  local target="$custom_plugins_dir/$name"

  if [[ -d "$target/.git" ]]; then
    git -C "$target" pull --ff-only
    return
  fi

  git clone "$repo" "$target"
}

if [[ ! -d "$oh_my_zsh_dir/.git" ]]; then
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$oh_my_zsh_dir"
fi

mkdir -p "$custom_plugins_dir"

clone_or_update "fzf-tab" "https://github.com/Aloxaf/fzf-tab"
clone_or_update "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_or_update "zsh-completions" "https://github.com/zsh-users/zsh-completions"
clone_or_update "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
clone_or_update "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
