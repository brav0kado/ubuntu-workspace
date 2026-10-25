#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo "Run as your normal user, not with sudo." >&2; exit 1; fi
base="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ${1:-} == --dry-run ]]; then
  echo "Install Ubuntu terminal packages; back up and deploy Zsh, tmux and LazyVim configs; install plugins; switch login shell after validation. Install the terminal appearance and apply Tokyo Night when Ptyxis is available."
  exit 0
fi
source /etc/os-release
[[ $ID == ubuntu ]] || { echo "This installer currently supports Ubuntu." >&2; exit 1; }
sudo apt-get update
sudo apt-get install -y zsh neovim tmux zsh-autosuggestions zsh-syntax-highlighting ripgrep fd-find fzf bat zoxide git curl unzip xclip build-essential
nvim --headless -u NONE '+lua if vim.fn.has("nvim-0.11.2") == 0 then vim.cmd("cquit 1") end' +qa
backup="$HOME/.local/state/workstation-setup/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/bin"
for item in .zshrc .tmux.conf .config/nvim .config/starship.toml; do
  if [[ -e "$HOME/$item" || -L "$HOME/$item" ]]; then
    mkdir -p "$backup/$(dirname "$item")"
    cp -a "$HOME/$item" "$backup/$item"
  fi
done
if [[ -e "$HOME/.config/nvim" || -L "$HOME/.config/nvim" ]]; then
  mv "$HOME/.config/nvim" "$backup/nvim-original"
fi
cp "$base/config/zshrc" "$HOME/.zshrc"
cp "$base/config/tmux.conf" "$HOME/.tmux.conf"
cp -a "$base/config/nvim" "$HOME/.config/nvim"
# Preserve an existing Starship prompt, including on the laptop.
[[ -e "$HOME/.config/starship.toml" ]] || cp "$base/config/starship.toml" "$HOME/.config/starship.toml"
"$base/install-appearance.sh"
zsh -n "$HOME/.zshrc"
zsh -ic 'print "Zsh configuration loaded successfully"'
nvim --headless '+Lazy! sync' +qa
if [[ $(getent passwd "$USER" | cut -d: -f7) != /usr/bin/zsh ]]; then
  sudo chsh -s /usr/bin/zsh "$USER"
fi
printf 'Done. Backups: %s\nOpen a new login session for Zsh, or run: exec zsh\nRun nvim and :LazyHealth to review editor dependencies.\n' "$backup"
