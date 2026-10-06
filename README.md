# Dotfiles

Personlig konfiguration för macOS: zsh, Ghostty och oh-my-posh.
Verktyg och appar installeras med Homebrew. Konfigurationsfiler länkas till
hemkatalogen med GNU Stow.

## Installation

Förutsätter macOS, Homebrew och Git. Kör från repots rot:

```sh
./install.sh
```

Öppna en ny terminalflik efter installationen.

| Kommando | Omfattning |
| --- | --- |
| `./install.sh` | Verktyg, appar, appinställningar och dotfiles. |
| `./install.sh --cli` | Verktyg från `Brewfile`. |
| `./install.sh --apps` | Appar och fonter från `Brewfile.apps`, samt appinställningar. |
| `./install.sh --dotfiles` | Oh My Zsh, plugins och symlänkar till konfigurationen. |

Flaggor kan kombineras, exempelvis `./install.sh --cli --dotfiles`.
`--dotfiles` kräver att Git och Stow redan är installerade.

Homebrew installerar saknade paket och uppdaterar befintliga. Dotfiles-steget
hämtar Oh My Zsh om det saknas och uppdaterar dess custom-plugins. Befintliga
symlänkar till samma repo behålls. Konflikterande filer och symlänkar flyttas
till `<sökväg>.backup.<tidsstämpel>` innan Stow länkar konfigurationen.

## Filer

| Sökväg | Innehåll |
| --- | --- |
| `Brewfile` | CLI-verktyg, inklusive kubectl, kubectx, kubens och fzf. |
| `Brewfile.apps` | Appar och fonter. |
| `install.sh` | Installation och applicering av konfiguration. |
| `bootstrap/` | Oh My Zsh, plugins och Scroll Reverser-inställningar. |
| `zsh/` | Shellkonfiguration, PATH och mall för lokala tillägg. |
| `ghostty/` | Terminalkonfiguration. |
| `oh-my-posh/` | Prompttema. |

De aktiva konfigurationsfilerna är symlänkar till repot. Ändringar i dem sparas
därför direkt i repot.

## Lokal konfiguration

`~/.config/zsh/local.zsh` skapas från en mall om filen saknas. Använd den för
maskinspecifika inställningar och hemligheter; filen versionshanteras inte.

Homebrew initieras i `.zprofile`. Gemensam PATH finns i
`zsh/.config/zsh/path.zsh`. `~/bin` ligger före Homebrew, och
`~/.docker/bin` ingår. Innehållet i `~/bin` versionshanteras inte.
Homebrews zsh-kompletteringar laddas före Oh My Zsh.

Scroll Reverser konfigureras för omvänd vertikal musrullning och oförändrad
styrplatta, med naturlig rullning aktiverad i macOS. Appen måste startas och
få sina macOS-behörigheter lokalt.

## Kubernetes

`kubectx` väljer bland contexts i den befintliga kubeconfigen. `kubens` väljer
namespace. Med fzf installerat visas sökbara menyer.

```sh
kubectx       # välj context
kubens        # välj namespace
kubectx -     # återgå till föregående context
```

För vSphere används `kubectl vsphere login` för inloggning och förnyelse.
Hämta miljöns kubectl och vSphere-plugin från rätt Supervisor-portal och lägg
dem i `~/bin`. Dessa binärer och klusteruppgifter ingår inte i repot.
