#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:-apply}"
timestamp="$(date +%Y%m%d%H%M%S)"

usage() {
  cat <<'EOF'
Usage:
  ./install.sh           # install or update local machine from this repo
  ./install.sh apply     # same as default
  ./install.sh update    # same as default
  ./install.sh help
EOF
}

log() {
  printf '%s\n' "$1"
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

backup_if_regular_file() {
  local path="$1"
  local backup_path

  if [[ -e "$path" && ! -L "$path" ]]; then
    backup_path="${path}.backup.${timestamp}"
    mv "$path" "$backup_path"
    log "Backed up $path -> $backup_path"
  fi
}

symlink_points_to_repo() {
  local path="$1"
  local link_target
  local resolved_target
  local resolved_parent

  [[ -L "$path" ]] || return 1

  link_target="$(readlink "$path")" || return 1

  if [[ "$link_target" = /* ]]; then
    resolved_target="$link_target"
  else
    resolved_target="$(cd "$(dirname "$path")" && pwd -P)/$link_target"
  fi

  if resolved_parent="$(cd "$(dirname "$resolved_target")" 2>/dev/null && pwd -P)"; then
    resolved_target="$resolved_parent/$(basename "$resolved_target")"
  fi

  [[ "$resolved_target" == "$repo_dir"/* ]]
}

backup_if_conflicting_path() {
  local path="$1"
  local backup_path

  if [[ -L "$path" ]]; then
    if symlink_points_to_repo "$path"; then
      return
    fi

    backup_path="${path}.backup.${timestamp}"
    mv "$path" "$backup_path"
    log "Backed up conflicting symlink $path -> $backup_path"
    return
  fi

  backup_if_regular_file "$path"
}

case "$mode" in
  apply|install|update)
    ;;
  help|-h|--help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
esac

require_cmd git
require_cmd brew

cd "$repo_dir"

log "Installing and updating Homebrew dependencies"
brew bundle --file="$repo_dir/Brewfile"

require_cmd stow

log "Installing or updating Oh My Zsh and custom plugins"
"$repo_dir/bootstrap/oh-my-zsh.sh"

log "Preparing target directories"
mkdir -p \
  "$HOME/.config/zsh" \
  "$HOME/.config/ghostty" \
  "$HOME/.config/ohmyposh" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty"

log "Backing up existing files when needed"
backup_if_conflicting_path "$HOME/.zprofile"
backup_if_conflicting_path "$HOME/.zshrc"
backup_if_conflicting_path "$HOME/.config/ghostty/config"
backup_if_conflicting_path "$HOME/.config/ghostty/config.ghostty"
backup_if_conflicting_path "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
backup_if_conflicting_path "$HOME/.config/ohmyposh/atomic.omp.json"
backup_if_conflicting_path "$HOME/.config/zsh/path.zsh"
backup_if_conflicting_path "$HOME/.config/zsh/local.example.zsh"

if [[ ! -f "$HOME/.config/zsh/local.zsh" ]]; then
  cp "$repo_dir/zsh/.config/zsh/local.example.zsh" "$HOME/.config/zsh/local.zsh"
  log "Created $HOME/.config/zsh/local.zsh from template"
fi

log "Applying dotfiles with stow"
stow --target="$HOME" --restow zsh ghostty oh-my-posh

log "Done. Restart your shell with: exec zsh"
