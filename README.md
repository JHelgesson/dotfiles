# Dotfiles

Dotfiles för macOS med `zsh`, `Ghostty` och `oh-my-posh`.

## Innehåll

- `Brewfile`: CLI-verktyg och delade terminalberoenden som installeras via Homebrew
- `Brewfile.apps`: GUI-appar och fonter som installeras via Homebrew Cask
- `install.sh`: installerar eller uppdaterar den lokala miljön
- `bootstrap/`: installerar `Oh My Zsh` och dina plugins
- `zsh/`: `.zprofile`, `.zshrc` och delad zsh-konfiguration
- `ghostty/`: Ghostty-konfiguration för macOS
- `oh-my-posh/`: prompttema

## Användning

Allt:

```sh
./install.sh
```

Endast CLI-verktyg:

```sh
./install.sh --cli
```

Endast GUI-appar:

```sh
./install.sh --apps
```

Endast dotfiles och symlänkar:

```sh
./install.sh --dotfiles
```

Kombinera delar vid behov:

```sh
./install.sh --cli --dotfiles
```

## Översikt

`./install.sh`

- kör allt: CLI-verktyg från `Brewfile`, GUI-appar från `Brewfile.apps` och dotfiles-bootstrap med symlänkar

`./install.sh --cli`

- kör bara `brew bundle --file=Brewfile`
- installerar eller uppdaterar CLI-verktyg och delade terminalberoenden
- kör inte app-installation eller dotfiles-bootstrap

`./install.sh --apps`

- kör bara `brew bundle --file=Brewfile.apps`
- installerar eller uppdaterar GUI-appar och fonter via Homebrew Cask
- kör inte CLI-installation eller dotfiles-bootstrap

`./install.sh --dotfiles`

- bootstrappper eller uppdaterar `Oh My Zsh` och dess plugins
- backar upp konflikterande filer eller gamla symlänkar
- applicerar `zsh`, `ghostty` och `oh-my-posh` som symlänkar med `stow`
- kör inte `brew bundle`

Kombinationer, till exempel `./install.sh --cli --dotfiles`

- kör bara de delar som motsvarar de flaggor du anger
- är användbart när du vill uppdatera shellmiljön utan att röra GUI-appar, eller tvärtom

## Vad `install.sh` gör

- kör `brew bundle --file=Brewfile` när `--cli` är vald eller när du kör utan flaggor
- kör `brew bundle --file=Brewfile.apps` när `--apps` är vald eller när du kör utan flaggor
- installerar eller uppdaterar `Oh My Zsh` och custom-plugins när `--dotfiles` är vald eller när du kör utan flaggor
- backar upp befintliga filer eller gamla symlänkar innan de ersätts av symlänkar
- skapar `~/.config/zsh/local.zsh` från mall om den saknas
- applicerar dotfiles som symlänkar med `stow`

## Viktigt

- `install.sh` är idempotent och kan köras både vid första installation och vid uppdateringar.
- `~/.zprofile`, `~/.zshrc`, Ghostty-konfigen och `~/.config/ohmyposh/atomic.omp.json` backas upp automatiskt om de redan finns som vanliga filer eller som symlänkar från en annan dotfiles-klon.
- `~/.oh-my-zsh` versionshanteras inte. Det bootstrapas i stället.
- `--dotfiles` förutsätter att `git` och `stow` redan finns installerade. Kör `./install.sh` eller `./install.sh --cli` först på en ny maskin.
- `local.zsh` är för maskinspecifika eller känsliga tillägg och checkas inte in.
- Homebrew initieras i `.zprofile`. Delad `PATH` ligger i `~/.config/zsh/path.zsh`.
- `~/bin` finns i `PATH`, men innehållet i `~/bin` synkas inte automatiskt.

## Arbetsflöde

1. Ändra filer i repot.
2. Kör `./install.sh`.
3. Verifiera lokalt.
4. Commita och pusha.
