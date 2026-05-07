# Den här filen är avsiktligt inte en del av den delade grundsetupen.
# Lägg till sådant här per maskin som inte ska eller bör versionshanteras.
#
# Delad PATH finns redan i:
# - ~/.zprofile
# - ~/.config/zsh/path.zsh
#
# Exempel på lokala tillägg:
#
# Extra PATH för den här maskinen:
# path=("$HOME/.local/bin" $path)
# export PATH
#
# Om du använder .NET global tools på just den här maskinen:
# path=("$HOME/.dotnet/tools" $path)
# export PATH
#
# Lokala miljövariabler eller tokens:
# export SOME_API_TOKEN="..."
#
# Lokala alias eller funktioner:
# alias workvpn="scutil --nc start CompanyVPN"
