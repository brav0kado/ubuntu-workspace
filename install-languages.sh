#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo "Run as your normal user, without sudo." >&2; exit 1; fi
if [[ ${1:-} == --dry-run ]]; then
  echo "Install Go, Ruby/Gem, SQLite, PHP CLI, LuaRocks and build dependencies; build Tree-sitter CLI 0.26.3; install configured Neovim parsers."
  exit 0
fi
source /etc/os-release
[[ $ID == ubuntu ]] || { echo "Ubuntu is required." >&2; exit 1; }
sudo apt-get update
sudo apt-get install -y golang-go ruby-full ruby-dev sqlite3 libsqlite3-dev php-cli php-mbstring php-xml php-curl php-sqlite3 luarocks liblua5.1-0-dev neovim cargo rustc build-essential pkg-config libssl-dev curl git unzip
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
mkdir -p "$HOME/.local/bin"
# Ubuntu 26.04's CLI 0.25.9 is older than the installed plugin requires.
if ! command -v tree-sitter >/dev/null || ! tree-sitter --version | awk '{split($2,v,"."); exit !(v[1]>0 || v[2]>26 || (v[2]==26 && v[3]>=1))}'; then
  cargo install --locked --root "$HOME/.local" tree-sitter-cli --version 0.26.3
fi
for tool in go ruby gem sqlite3 php luarocks nvim tree-sitter; do
  command -v "$tool" >/dev/null || { echo "Missing command: $tool" >&2; exit 1; }
done
nvim --headless '+lua require("lazy").load({plugins={"nvim-treesitter"}}); local opts=require("lazy.core.plugin").values(require("lazy.core.config").plugins["nvim-treesitter"],"opts",false); require("nvim-treesitter").install(opts.ensure_installed):wait(300000)' +qa
go version
ruby --version
gem --version
sqlite3 --version
php --version
luarocks --version
tree-sitter --version
echo "Language packages installed. In Neovim, run :checkhealth nvim-treesitter to verify parser health."
