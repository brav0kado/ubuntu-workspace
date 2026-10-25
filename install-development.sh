#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo "Run as your normal user." >&2; exit 1; fi
if [[ ${1:-} == --dry-run ]]; then
  echo "Install Python isolation tools, compiler/debugger support, ShellCheck, shfmt, Composer; install uv and Ruff in user environments."
  exit 0
fi
if [[ ${1:-} != --user-tools ]]; then
  source /etc/os-release
  [[ $ID == ubuntu ]] || { echo "Ubuntu required" >&2; exit 1; }
  sudo apt-get update
  sudo apt-get install -y python3-venv python3-dev pipx build-essential cmake ninja-build pkg-config gdb clangd lazygit shellcheck shfmt composer ruby-dev libssl-dev libffi-dev
fi
mkdir -p "$HOME/.local/share/workstation-setup" "$HOME/.local/bin"
venv="$HOME/.local/share/workstation-setup/uv-venv"
[[ -x "$venv/bin/python" ]] || python3 -m venv "$venv"
"$venv/bin/python" -m pip install uv
# Keep commands owned by other installations intact.
if [[ ! -e "$HOME/.local/bin/uv" && ! -L "$HOME/.local/bin/uv" ]]; then
  ln -s "$venv/bin/uv" "$HOME/.local/bin/uv"
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
"$venv/bin/uv" tool install ruff
"$venv/bin/uv" --version
ruff --version
printf 'Development tools installed. Open Neovim, run :Lazy sync, then :Mason and :checkhealth.\n'
