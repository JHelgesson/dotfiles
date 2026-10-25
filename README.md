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
| `./install.sh --dotfiles` | Oh My Zsh, plugins, klogin och symlänkar till konfigurationen. |

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
| `tools/` | Generiska kommandon som länkas till `~/bin`. |
| `examples/` | Mallar för lokal konfiguration. |

De aktiva konfigurationsfilerna är symlänkar till repot. Ändringar i dem sparas
därför direkt i repot.

## Lokal konfiguration

`~/.config/zsh/local.zsh` skapas från en mall om filen saknas. Använd den för
maskinspecifika inställningar och hemligheter; filen versionshanteras inte.

Homebrew initieras i `.zprofile`. Gemensam PATH finns i
`zsh/.config/zsh/path.zsh`. `~/bin` ligger före Homebrew, och
`~/.docker/bin` ingår. Egna binärer i `~/bin` versionshanteras inte; `klogin` länkas från repot.
Homebrews zsh-kompletteringar laddas före Oh My Zsh.

## Terminalarbete

Ghostty, Oh My Posh, fzf och välkomstpanelen använder Gruvbox-färger.
Ghosttys bakgrund har opacitet 0.9 för tydligare kontrast.

| Genväg eller kommando | Funktion |
| --- | --- |
| `Ctrl-R` | Sök i kommandohistoriken med fzf; valet placeras på kommandoraden. |
| `Ctrl-T` | Välj filer med fzf, se innehållet med bat och klistra in sökvägarna. |
| `Ctrl-/` i filväljaren | Visa eller dölj förhandsvisningen. |
| `Tab` | Befintlig completion med fzf-tab. |
| `z dotfiles` | Hoppa till en tidigare besökt katalog som matchar namnet. |
| `zi` | Välj bland tidigare besökta kataloger med fzf. |
| `bat FIL` | Läs en fil med syntaxfärger och radnummer; q avslutar läsaren. |
| `fd deployment` | Sök rekursivt efter filnamn som innehåller deployment. |
| `fd -e yaml` | Lista filer med filändelsen yaml. |

zoxide lär sig katalogerna när du besöker dem. Vanlig `cd` fungerar fortfarande.
fzf laddar bara sina tangentbindningar; Tab hanteras av fzf-tab.
Ctrl-T hämtar filer via fd, inkluderar dolda filer och respekterar `.gitignore`.
`.git` tas inte med. Förhandsvisningen visar upp till 300 rader med bat i
Gruvbox-tema. Vanlig `fd` döljer dolda filer; använd `fd --hidden NAMN` vid behov.
Vanliga `cat` och `find` finns kvar som tidigare.

direnv laddar projektets miljövariabler från en `.envrc` efter att du godkänt
filen, och återställer dem när du lämnar katalogen. Exempel på `.envrc`:

```sh
export APP_ENV=development
```

Kör `direnv allow` i projektkatalogen efter att du granskat filen. Ändringar
kräver nytt godkännande. Hemligheter ska ligga i ignorerade lokala filer.
Inloggning och byte av Kubernetes-context görs fortfarande med dina kommandon.

Scroll Reverser konfigureras för omvänd vertikal musrullning och oförändrad
styrplatta, med naturlig rullning aktiverad i macOS. Appen måste startas och
få sina macOS-behörigheter lokalt.

## Välkomstpanel

Nya interaktiva Ghostty-login-skal visar en hälsning till Jonas, Docker-status,
Kubernetes-genvägar och ett slumpat tips, inklusive exempel för bat, fd och k9s.
Docker kontrolleras mot valt endpoint
med en timeout på 0,7 sekunder. Panelen finns i `zsh/.config/zsh/welcome.zsh`.

Anpassa i `~/.config/zsh/local.zsh`:

```zsh
DOTFILES_WELCOME_NAME='Jonas'
# DOTFILES_WELCOME=0  # stäng av panelen
```

`zsh/.hushlogin` länkas till `~/.hushlogin` och döljer macOS inloggningsmeddelanden,
inklusive `Last login`, även i andra terminaler. Själva välkomstpanelen visas bara
i Ghostty. Kör `./install.sh --dotfiles` och öppna sedan en ny Ghostty-flik.

## Prompt

Ghostty använder FiraCode Nerd Font Mono i storlek 16, en variant av typsnittet i
[Starships demo](https://starship.rs/faq/#what-is-the-configuration-used-in-the-demo-gif).
Fonten installeras via `Brewfile.apps`. Ladda om Ghosttys konfiguration efter
fontbyte; om fonten inte syns direkt, avsluta och starta om Ghostty.

Oh My Posh visar en tooltip med valt Docker-context till höger på
inmatningsraden när du skriver `docker` följt av mellanslag. Kubernetes-context
och namespace visas fortfarande i den vanliga prompten.

Contextnamn längre än 36 tecken förkortas visuellt genom att behålla början
och slutet. Skriv `kubectl`, `k`, `kubectx`, `kubens`, `k9s` eller `klogin`
följt av mellanslag för en tooltip med hela det aktiva contextnamnet.
Tooltipen visar nuvarande context, inte ett eventuellt mål i kommandots argument.

Context med en separat namndel `prod`, `production` eller `prd` markeras med
röd bakgrund och texten `PROD`, oberoende av stora eller små bokstäver.
Exempelvis markeras `example-prod`, men inte `example-nonprod`. Detta är en
namnbaserad visuell påminnelse och ändrar varken context, behörigheter eller
inloggning. Fullständiga contextnamn behålls i den förenklade historikprompten;
produktionsmarkeringen följer med även där.

Efter körda kommandon förenklas prompten till en rad med Kubernetes-context,
namespace och en kommandopil. Informationen hämtas från den tidigare prompten,
så att klustret som var valt innan kommandot kördes finns kvar i historiken.
Kommandon som tar över två sekunder får sin körtid visad i nästa fulla prompt.

Efter ändringar i prompttemat: kör `./install.sh --dotfiles` och sedan
`exec zsh`. Testa genom att skriva `docker ` utan att trycka Enter; avbryt med
Ctrl-C. Tooltipen visar context, inte om Docker-motorn är igång.

Konfigurationen finns i `oh-my-posh/.config/ohmyposh/atomic.omp.json`, under
`tooltips`. Ta bort `tooltips` och `tooltips_action` för att stänga av funktionen.
Ta bort `transient_prompt` för att behålla fulla prompter i historiken.

## Kubernetes

`kubectx` väljer bland contexts i den befintliga kubeconfigen. `kubens` väljer
namespace. Med fzf installerat visas sökbara menyer.

```sh
kubectx       # välj context
kubens        # välj namespace
kubectx -     # återgå till föregående context
k9s           # öppna Kubernetes-gränssnittet för valt context
```

I k9s: `?` visar hjälp, `:pods` öppnar poddvyn, `/` filtrerar och `:q` avslutar.
k9s använder din befintliga kubeconfig och behörigheter. För vSphere: logga in
med `klogin` först om inloggningen har gått ut. Ingen anslutning körs av
installationsskriptet.

För vSphere används `kubectl vsphere login` för inloggning och förnyelse.
Hämta miljöns kubectl och vSphere-plugin från rätt Supervisor-portal och lägg
dem i `~/bin`. Dessa binärer och klusteruppgifter ingår inte i repot.

### klogin

`klogin` läser `~/.config/vgr/kubernetes.toml`, startar vSphere-inloggningen och
väljer workload-context efter lyckad inloggning. Python 3.11 eller senare krävs;
Python installeras via `Brewfile`. Lösenord anges i vSphere-verktygets dialog.

```sh
klogin                         # välj kluster i en meny
klogin example-dev             # logga in på ett sparat kluster
klogin example-dev --show      # visa kommandon utan att ansluta
klogin --list                  # lista sparade kluster
```

Anslutningsfilen skapas manuellt, utanför repot:

```sh
install -d -m 0700 ~/.config/vgr
(umask 077; cp -n examples/kubernetes.example.toml ~/.config/vgr/kubernetes.toml)
```

Ersätt mallens värden med dina lokala uppgifter. Installation och uppdatering
ändrar inte anslutningsfilen. Den privata filen omfattas också av `.gitignore`
om den av misstag kopieras till repot.

```toml
[supervisors.example]
server = "supervisor.example.invalid"
insecureSkipTLSVerify = false

[clusters.example-dev]
supervisor = "example"
supervisorNamespace = "example-shared-dev"
```

Lägg till ett `[clusters.KLUSTERNAMN]`-block för varje nytt kluster. Referensen
`supervisor` ska finnas under `supervisors`. `supervisorNamespace` avser
namespace på Supervisorn. Arbetsnamespace väljs separat med `kubens`.
`insecureSkipTLSVerify` är valfritt och har standardvärdet `false`.
Alternativ anslutningsfil kan anges med `klogin --config /sökväg/kubernetes.toml`.

Verifiera kommandot med `python3 -m unittest discover -s tests`.
