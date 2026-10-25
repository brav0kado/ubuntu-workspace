#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo 'Run as your normal desktop user, without sudo.' >&2; exit 1; fi
base="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ${1:-} == --dry-run ]]; then
  echo 'Install Starship, eza, Ubuntu Mono and icon fonts; back up and deploy Zsh/Starship configs; apply Tokyo Night to the default Ptyxis profile when available.'
  exit 0
fi
source /etc/os-release
[[ $ID == ubuntu ]] || { echo 'Ubuntu is required.' >&2; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
sudo apt-get update
sudo apt-get install -y curl ca-certificates unzip fontconfig fonts-ubuntu eza
mkdir -p "$HOME/.local/bin"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
if ! command -v starship >/dev/null; then
  curl --fail --location --show-error https://starship.rs/install.sh -o "$work/starship-install.sh"
  sh "$work/starship-install.sh" --yes --bin-dir "$HOME/.local/bin"
fi
starship --version
eza --version
fontdir="$HOME/.local/share/fonts/SymbolsNerdFont"
mkdir -p "$fontdir"
curl --fail --location --show-error https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip -o "$work/symbols.zip"
unzip -q "$work/symbols.zip" 'SymbolsNerdFontMono-Regular.ttf' -d "$work/fonts"
install -m 644 "$work/fonts/SymbolsNerdFontMono-Regular.ttf" "$fontdir/"
backup="$HOME/.local/state/workstation-setup/backups/$(date +%Y%m%d-%H%M%S)-appearance-$$"
mkdir -p "$backup" "$HOME/.config/fontconfig/conf.d"
for item in .zshrc .config/starship.toml .config/fontconfig/conf.d/70-ubuntu-mono-symbols.conf; do
  if [[ -e "$HOME/$item" || -L "$HOME/$item" ]]; then
    mkdir -p "$backup/$(dirname "$item")"
    cp -a "$HOME/$item" "$backup/$item"
  fi
done
cp "$base/config/zshrc" "$HOME/.zshrc"
cp "$base/config/starship.toml" "$HOME/.config/starship.toml"
cat > "$HOME/.config/fontconfig/conf.d/70-ubuntu-mono-symbols.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias><family>Ubuntu Mono</family><prefer><family>Ubuntu Mono</family><family>Symbols Nerd Font Mono</family></prefer></alias>
</fontconfig>
XML
fc-cache -f "$fontdir"
zsh -n "$HOME/.zshrc"
if command -v gsettings >/dev/null && gsettings list-schemas | grep -qx org.gnome.Ptyxis; then
  profile=$(gsettings get org.gnome.Ptyxis default-profile-uuid)
  profile=${profile//\'/}
  if [[ -n $profile ]]; then
    schema="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$profile/"
    for key in font-name use-system-font interface-style cursor-shape; do
      printf '%s: ' "$key" >> "$backup/ptyxis-settings.txt"
      gsettings get org.gnome.Ptyxis "$key" >> "$backup/ptyxis-settings.txt"
    done
    for key in palette cell-height-scale cell-width-scale; do
      printf '%s: ' "$key" >> "$backup/ptyxis-settings.txt"
      gsettings get "$schema" "$key" >> "$backup/ptyxis-settings.txt"
    done
    gsettings set org.gnome.Ptyxis font-name 'Ubuntu Mono 12'
    gsettings set org.gnome.Ptyxis use-system-font false
    gsettings set org.gnome.Ptyxis interface-style dark
    gsettings set org.gnome.Ptyxis cursor-shape ibeam
    gsettings set "$schema" palette 'Tokyo Night'
    gsettings set "$schema" cell-height-scale 1.0
    gsettings set "$schema" cell-width-scale 1.0
  fi
else
  echo 'Ptyxis was not detected. In your terminal preferences, select Ubuntu Mono 12 and a Tokyo Night palette manually.'
fi
printf 'Appearance installed. Backups: %s\nRun: exec zsh\n' "$backup"
