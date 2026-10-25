# Ubuntu Workspace

Run `./install-terminal.sh --dry-run` to preview, then `./install-terminal.sh` as your normal user. You will be asked for sudo authentication in your terminal. GNOME settings are not modified.

The installer backs up existing configuration under `~/.local/state/workstation-setup/backups/`, installs Ubuntu packages, deploys Zsh and LazyVim, synchronizes plugins and switches the login shell only after checks succeed. Network access is required. Separate installers cover terminal/editor, language, development and research tools. A unified laptop installer is still pending.

Existing Starship configuration is preserved. On a machine without Starship, Zsh falls back to its standard prompt. A Nerd Font is recommended for LazyVim icons; font installation and terminal font selection are still pending. Language servers can be selected later with `:LazyExtras` and `:Mason`.

## Shortcuts

- Zsh: Ctrl-R history search, Tab completion, right arrow accepts suggestions; `z folder` jumps to a visited directory.
- Neovim: Space opens the shortcut menu; Space f f finds files; Space / searches the project; Space e opens the file explorer; Space g g opens the Git UI when its optional dependency is installed; `:Mason` manages language tools.
- tmux: Ctrl-b is the prefix; then `|` splits side by side, `-` splits vertically, `d` detaches. `tmux attach` reconnects.

## Recovery

To return to Bash: `chsh -s /bin/bash`. Restore individual files from the printed backup directory. Existing Neovim data/state folders are preserved; plugin upgrades can modify their contents. The Neovim configuration is based on [LazyVim starter](https://github.com/LazyVim/starter); its Apache-2.0 licence is retained in `config/nvim/LICENSE`. Upstream plugin versions are recorded by LazyVim in lazy-lock.json after installation.

## Language dependencies

Run `./install-languages.sh` after the terminal installer. This installs Go, Ruby including Gem, SQLite, PHP CLI, LuaRocks and Tree-sitter CLI, then the configured Neovim parsers. Tree-sitter is built with Cargo because Ubuntu provides an older CLI; the first build may take several minutes. Use `gem install --user-install PACKAGE` for user gems and `luarocks --local install PACKAGE` for user rocks. This script can run independently without replacing terminal configuration.

## Development environment

Run `./install-development.sh` as your normal user. `--user-tools` installs only uv and Ruff without sudo. Python tools use isolated environments; Ubuntu Python is preserved. Existing Node.js/npm are retained; use project-local `npm install --save-dev` for JavaScript tooling, `bundle` for Ruby projects, and Composer for PHP projects. Neovim language extras are configured for Python, Go, Ruby, PHP, Rust, C/C++, JSON, YAML, TOML, Docker, Markdown, and TypeScript when supported by the installed LazyVim release. Open Neovim and run `:Lazy sync`, then `:Mason` to review language-server installation.

For Python projects: `uv init`, `uv add requests`, `uv add --dev pytest ruff`, then `uv run pytest`. For an existing project use its existing dependency manager and lockfile. No global Git identity, credentials, or project files are changed.

## Web/API and network research

Run `./install-research.sh` as your normal user. `--user-tools` installs the tools that do not need sudo. Official release versions and SHA-256 hashes are pinned in `research-tools.lock.json` (currently Linux x86_64). Tools go into `~/.local/bin`; existing binaries are backed up. mitmproxy uses a uv-managed Python 3.13 environment. No scans, proxy listeners, certificate trust changes, capture-permission changes, firewall changes, or background services are started. Version output is recorded in `~/.local/state/workstation-setup/research-versions.txt`.

The `httpx` command is ProjectDiscovery's probing tool; Python's HTTPX library is a separate package. Keep target scope, request limits, raw evidence and reports in each research project's own folder. Nuclei templates can be downloaded explicitly later with `nuclei -update-templates`; none are executed during setup. Burp Suite's existing installation is preserved.

To install only the Ubuntu network packages after user tools are ready: `./install-research.sh --system-packages`. mitmproxy is pinned to 12.3.0.

## Terminal appearance

The chosen appearance is Ubuntu Mono 12 with the Tokyo Night palette, normal cell spacing, an I-beam cursor and a compact two-line Starship prompt. Symbols Nerd Font Mono provides icon fallback. The Zsh template uses eza for coloured file listings and icons when available.

These appearance settings were tested on a Ptyxis desktop. **The installer does not yet install Starship, eza or fonts, or apply Ptyxis settings.** Those steps still need to be packaged before this setup can reproduce the full appearance on another machine.

## Project status

This repository contains setup scripts and configuration templates, not local backups or credentials. Review scripts before running them. The complete setup has not yet been tested on a clean laptop. The terminal installer requires Neovim 0.11.2 or newer; availability depends on the Ubuntu release.
