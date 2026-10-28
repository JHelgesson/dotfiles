# Only greet new Ghostty login shells, not scripts or nested shells.
[[ -o interactive && -o login && -t 1 && ${TERM_PROGRAM:-} == ghostty && ${DOTFILES_WELCOME:-1} != 0 ]] || return 0
[[ ${_dotfiles_welcome_shown:-0} == 0 ]] || return 0
typeset _dotfiles_welcome_shown=1

() {
  emulate -L zsh
  zmodload zsh/datetime

  local hour greeting docker_status welcome_name index
  local accent='' muted='' reset=''
  local -a tips kube_commands kube_descriptions terminal_commands terminal_descriptions
  welcome_name=${DOTFILES_WELCOME_NAME:-Jonas}
  strftime -s hour '%H' "$EPOCHSECONDS"

  case $hour in
    0[5-9]|10) greeting='Good morning' ;;
    11|12) greeting='Good day' ;;
    1[3-7]) greeting='Good afternoon' ;;
    *) greeting='Good evening' ;;
  esac

  if [[ $TERM != dumb && ! -v NO_COLOR ]]; then
    accent=$'\e[1;38;2;250;189;47m'
    muted=$'\e[38;2;168;153;132m'
    reset=$'\e[0m'
  fi

  docker_status='CLI not installed'
  if (( $+commands[docker] )); then
    docker_status='status not checked (Python not installed)'
    if (( $+commands[python3] )); then
      # Bound daemon checks so an unavailable Docker endpoint cannot hold up login.
      docker_status=$(command python3 -c '
import subprocess
import sys
try:
    result = subprocess.run(
        [sys.argv[1], "info", "--format", "{{.ServerVersion}}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=0.7,
    )
    print("running" if result.returncode == 0 else "unavailable")
except subprocess.TimeoutExpired:
    print("no response within 0.7 s")
except OSError:
    print("could not check status")
' "$commands[docker]" 2>/dev/null)
      docker_status=${docker_status:-could not check status}
    fi
  fi

  tips=(
    'kubectx - takes you back to the previous context.'
    'kubens opens a searchable namespace menu.'
    'klogin --list shows your saved clusters.'
    'klogin CLUSTER --show displays the login command without connecting.'
    'Type docker followed by a space to see the selected Docker context.'
    'gs is your shortcut for git status.'
    'Ctrl-R searches your command history.'
    'Ctrl-T selects a file and inserts its path.'
    'z DIRECTORY jumps to a directory you have visited before.'
    'zi opens a searchable menu of your visited directories.'
    'bat FILE displays a file with syntax highlighting and line numbers.'
    'Reading long files in bat: / searches and q quits the pager.'
    'fd deployment searches filenames in the current directory and its subdirectories.'
    'fd -e yaml lists files with the yaml extension.'
    'fd --hidden NAME also searches hidden files.'
    'Ctrl-T previews files with bat before you select; Ctrl-/ toggles the preview.'
    'k9s opens Kubernetes in the terminal using the selected context.'
    'In k9s: ? shows help and :q quits.'
    'In k9s: :pods shows pods and / filters the list.'
    'Type kubectl followed by a space to see the full active context name.'
    'direnv allow approves the current project environment after you review .envrc.'
  )

  kube_commands=(klogin kubectx kubens k9s)
  kube_descriptions=('Log in' 'Switch context' 'Switch namespace' 'Explore cluster')
  terminal_commands=('z / zi' 'Ctrl-R' 'Ctrl-T' 'bat / fd')
  terminal_descriptions=('Jump between directories' 'Search command history' 'Find and preview files' 'Read and find files')

  printf '\n%s%s, %s.%s\n\n' "$accent" "$greeting" "$welcome_name" "$reset"
  printf '%smacOS  ·  Ghostty  ·  zsh%s\n' "$muted" "$reset"
  printf 'Docker: %s\n\n' "$docker_status"

  # Pad plain text separately from color escapes to keep the columns aligned.
  if (( COLUMNS >= 70 )); then
    printf '%s%-32s%s%s%s%s\n' "$accent" 'Kubernetes' "$reset" "$accent" 'Terminal workflow' "$reset"
    for index in {1..4}; do
      printf '  %s%-7s%s %-22s  %s%-8s%s %s\n' \
        "$accent" "$kube_commands[index]" "$reset" "$kube_descriptions[index]" \
        "$accent" "$terminal_commands[index]" "$reset" "$terminal_descriptions[index]"
    done
  else
    printf '%sKubernetes%s\n' "$accent" "$reset"
    for index in {1..4}; do
      printf '  %s%-7s%s %s\n' "$accent" "$kube_commands[index]" "$reset" "$kube_descriptions[index]"
    done
    printf '\n%sTerminal workflow%s\n' "$accent" "$reset"
    for index in {1..4}; do
      printf '  %s%-8s%s %s\n' "$accent" "$terminal_commands[index]" "$reset" "$terminal_descriptions[index]"
    done
  fi
  printf '\n'
  printf '%sTip: %s%s\n\n' "$muted" "${tips[$(( RANDOM % ${#tips} + 1 ))]}" "$reset"
}
