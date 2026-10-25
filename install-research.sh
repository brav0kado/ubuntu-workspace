#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo "Run as your normal user, without sudo." >&2; exit 1; fi
base="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
  --dry-run) echo "Install network packages, pinned research binaries, and isolated mitmproxy. No scans or service configuration."; exit 0 ;;
  --user-tools) ;;
  ""|--system-packages) source /etc/os-release
      [[ $ID == ubuntu ]] || { echo "Ubuntu required" >&2; exit 1; }
      sudo apt-get update
      sudo apt-get install -y nmap wireshark tshark tcpdump bind9-dnsutils whois socat netcat-openbsd jq curl openssl ca-certificates
      if [[ ${1:-} == --system-packages ]]; then echo "Network packages installed."; exit 0; fi
      ;;
  *) echo "Usage: $0 [--dry-run|--user-tools|--system-packages]" >&2; exit 2 ;;
esac
export PATH="$HOME/.local/bin:$PATH"
command -v uv >/dev/null || { echo "Install development tools first (uv required)." >&2; exit 1; }
python3 "$base/install-research-binaries.py"
uv tool install --python 3.13 mitmproxy==12.3.0
mkdir -p "$HOME/.local/state/workstation-setup"
{
  date -Is
  subfinder -version
  dnsx -version
  httpx -version
  nuclei -version
  ffuf -V
  mitmdump --version
} > "$HOME/.local/state/workstation-setup/research-versions.txt" 2>&1
cat "$HOME/.local/state/workstation-setup/research-versions.txt"
echo "Research tools installed. No target traffic or packet capture was started."
