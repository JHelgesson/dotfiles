# Dotfiles

Dotfiles för macOS med `zsh`, `Ghostty` och `oh-my-posh`.

## Innehåll

- `Brewfile`: verktyg och appar som installeras via Homebrew
- `install.sh`: installerar eller uppdaterar den lokala miljön
- `bootstrap/`: installerar `Oh My Zsh` och dina plugins
- `zsh/`: `.zprofile`, `.zshrc` och delad zsh-konfiguration
- `ghostty/`: Ghostty-konfiguration för macOS
- `oh-my-posh/`: prompttema

## Användning

Ny Mac:

```sh
./install.sh
```

Uppdatera befintlig miljö:

```sh
git pull
./install.sh
```

## Vad `install.sh` gör

- kör `brew bundle`
- installerar eller uppdaterar `Oh My Zsh` och custom-plugins
- backar upp befintliga filer eller gamla symlänkar innan de ersätts av symlänkar
- skapar `~/.config/zsh/local.zsh` från mall om den saknas
- applicerar konfigurationen med `stow`

## Viktigt

- `install.sh` är idempotent och kan köras både vid första installation och vid uppdateringar.
- `~/.zprofile`, `~/.zshrc`, Ghostty-konfigen och `~/.config/ohmyposh/atomic.omp.json` backas upp automatiskt om de redan finns som vanliga filer eller som symlänkar från en annan dotfiles-klon.
- `~/.oh-my-zsh` versionshanteras inte. Det bootstrapas i stället.
- `local.zsh` är för maskinspecifika eller känsliga tillägg och checkas inte in.
- Homebrew initieras i `.zprofile`. Delad `PATH` ligger i `~/.config/zsh/path.zsh`.
- `~/bin` finns i `PATH`, men innehållet i `~/bin` synkas inte automatiskt.

## Arbetsflöde

1. Ändra filer i repot.
2. Kör `./install.sh`.
3. Verifiera lokalt.
4. Commita och pusha.
