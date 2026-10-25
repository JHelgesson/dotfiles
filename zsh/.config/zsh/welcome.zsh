# Only greet new Ghostty login shells, not scripts or nested shells.
[[ -o interactive && -o login && -t 1 && ${TERM_PROGRAM:-} == ghostty && ${DOTFILES_WELCOME:-1} != 0 ]] || return 0
[[ ${_dotfiles_welcome_shown:-0} == 0 ]] || return 0
typeset _dotfiles_welcome_shown=1

() {
  emulate -L zsh
  zmodload zsh/datetime

  local hour greeting docker_status welcome_name
  local accent='' muted='' reset=''
  local -a tips
  welcome_name=${DOTFILES_WELCOME_NAME:-Jonas}
  strftime -s hour '%H' "$EPOCHSECONDS"

  case $hour in
    0[5-9]|10) greeting='God morgon' ;;
    11|12) greeting='God dag' ;;
    1[3-7]) greeting='God eftermiddag' ;;
    *) greeting='God kväll' ;;
  esac

  if [[ $TERM != dumb && ! -v NO_COLOR ]]; then
    accent=$'\e[1;38;2;250;189;47m'
    muted=$'\e[38;2;168;153;132m'
    reset=$'\e[0m'
  fi

  docker_status='CLI saknas'
  if (( $+commands[docker] )); then
    docker_status='status ej kontrollerad (Python saknas)'
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
    print("igång" if result.returncode == 0 else "ej tillgänglig")
except subprocess.TimeoutExpired:
    print("svarar inte inom 0,7 s")
except OSError:
    print("kunde inte kontrolleras")
' "$commands[docker]" 2>/dev/null)
      docker_status=${docker_status:-kunde inte kontrolleras}
    fi
  fi

  tips=(
    'kubectx - tar dig tillbaka till föregående context.'
    'kubens öppnar en sökbar meny för namespace.'
    'klogin --list visar dina sparade kluster.'
    'klogin KLUSTER --show visar inloggningskommandot utan att ansluta.'
    'Skriv docker och mellanslag för att se valt Docker-context.'
    'gs är ditt kortkommando för git status.'
    'Ctrl-R söker bland dina tidigare kommandon.'
    'Ctrl-T väljer en fil och klistrar in sökvägen.'
    'z KATALOG hoppar till en katalog du besökt tidigare.'
    'zi öppnar en sökbar meny över dina besökta kataloger.'
    'bat FIL visar en fil med syntaxfärger och radnummer.'
    'Långa filer i bat: / söker och q avslutar läsaren.'
    'fd deployment söker efter filnamn i aktuell katalog och underkataloger.'
    'fd -e yaml visar filer med filändelsen yaml.'
    'fd --hidden NAMN söker även bland dolda filer.'
    'Ctrl-T visar filinnehåll med bat innan du väljer; Ctrl-/ döljer förhandsvisningen.'
    'k9s öppnar Kubernetes i terminalen med valt context.'
    'I k9s: ? visar hjälp och :q avslutar.'
    'I k9s: :pods visar poddar och / filtrerar listan.'
    'Skriv kubectl och mellanslag för att se hela namnet på aktivt context.'
  )

  printf '\n%s%s, %s.%s\n\n' "$accent" "$greeting" "$welcome_name" "$reset"
  printf '%smacOS  ·  Ghostty  ·  zsh%s\n' "$muted" "$reset"
  printf 'Docker: %s\n\n' "$docker_status"
  printf '  %sklogin%s   Logga in på Kubernetes\n' "$accent" "$reset"
  printf '  %skubectx%s  Byt kluster\n' "$accent" "$reset"
  printf '  %skubens%s   Byt namespace\n' "$accent" "$reset"
  printf '  %sk9s%s      Visa klustret interaktivt\n\n' "$accent" "$reset"
  printf '%sTips: %s%s\n\n' "$muted" "${tips[$(( RANDOM % ${#tips} + 1 ))]}" "$reset"
}
