#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"
run_cli=false
run_apps=false
run_dotfiles=false
selected_components=false

usage() {
  cat <<'EOF'
Usage:
  ./install.sh                     # install CLI tools, apps and dotfiles
  ./install.sh apply|install|update
  ./install.sh --cli               # install or update CLI tools from Brewfile
  ./install.sh --apps              # install or update GUI apps from Brewfile.apps
  ./install.sh --dotfiles          # bootstrap Oh My Zsh and apply symlinks
  ./install.sh --cli --dotfiles    # combine components as needed
  ./install.sh --help
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
  local cmd="$1"
  local hint="${2:-}"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    if [[ -n "$hint" ]]; then
      fail "Missing required command: $cmd. $hint"
    fi

    fail "Missing required command: $cmd"
  fi
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

install_brewfile() {
  local label="$1"
  local brewfile="$2"

  log "Installing and updating $label"
  brew bundle --file="$repo_dir/$brewfile"
}

apply_app_preferences() {
  log "Applying shared app preferences"
  "$repo_dir/bootstrap/scroll-reverser.sh"
}

apply_dotfiles() {
  require_cmd git
  require_cmd stow "Run ./install.sh --cli first, or install stow manually."

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
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    apply|install|update)
      ;;
    --cli)
      run_cli=true
      selected_components=true
      ;;
    --apps)
      run_apps=true
      selected_components=true
      ;;
    --dotfiles)
      run_dotfiles=true
      selected_components=true
      ;;
    --all)
      run_cli=true
      run_apps=true
      run_dotfiles=true
      selected_components=true
      ;;
    help|-h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      fail "Unknown argument: $1"
      ;;
  esac

  shift
done

if ! $selected_components; then
  run_cli=true
  run_apps=true
  run_dotfiles=true
fi

cd "$repo_dir"

if $run_cli || $run_apps; then
  require_cmd brew
fi

if $run_cli; then
  install_brewfile "CLI Homebrew dependencies" "Brewfile"
fi

if $run_apps; then
  apply_app_preferences
  install_brewfile "Homebrew cask apps" "Brewfile.apps"
fi

if $run_dotfiles; then
  apply_dotfiles
fi

if $run_dotfiles; then
  log "Done. Restart your shell with: exec zsh"
else
  log "Done."
fi
