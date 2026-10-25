#!/usr/bin/env python3
"""Install pinned official Linux x86_64 releases after SHA-256 verification."""
import datetime, hashlib, json, os, platform, shutil, tarfile, tempfile, urllib.request, zipfile
from pathlib import Path
root = Path(__file__).resolve().parent
if platform.system() != "Linux" or platform.machine() != "x86_64":
    raise SystemExit("Pinned research binaries currently support Linux x86_64 only.")
bindir = Path.home() / ".local/bin"
bindir.mkdir(parents=True, exist_ok=True)
backup = Path.home() / ".local/state/workstation-setup/backups" / ("research-" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
for tool in json.loads((root / "research-tools.lock.json").read_text()):
    name, version = tool["name"], tool["version"]
    filename = f"{name}_{version}_linux_amd64.{tool['archive']}"
    url = f"https://github.com/{tool['repo']}/releases/download/v{version}/{filename}"
    print(f"Installing {name} {version}", flush=True)
    with tempfile.TemporaryDirectory(prefix="research-install-") as tmp:
        archive = Path(tmp) / filename
        request = urllib.request.Request(url, headers={"User-Agent": "workstation-setup"})
        with urllib.request.urlopen(request, timeout=120) as response, archive.open("wb") as output:
            shutil.copyfileobj(response, output)
        if hashlib.file_digest(archive.open("rb"), "sha256").hexdigest() != tool["sha256"]:
            raise SystemExit(f"Checksum mismatch: {name}")
        binary = Path(tmp) / name
        if tool["archive"] == "zip":
            with zipfile.ZipFile(archive) as package, package.open(name) as source, binary.open("wb") as output:
                shutil.copyfileobj(source, output)
        else:
            with tarfile.open(archive) as package:
                member = next(m for m in package.getmembers() if m.isfile() and Path(m.name).name == name)
                with package.extractfile(member) as source, binary.open("wb") as output:
                    shutil.copyfileobj(source, output)
        destination = bindir / name
        if destination.exists() or destination.is_symlink():
            backup.mkdir(parents=True, exist_ok=True)
            shutil.copy2(destination, backup / name)
        # Copy to the destination filesystem before atomic replacement.
        with tempfile.NamedTemporaryFile(dir=bindir, prefix="."+name+"-", delete=False) as target:
            staged = Path(target.name)
            with binary.open("rb") as source:
                shutil.copyfileobj(source, target)
        staged.chmod(0o755)
        os.replace(staged, destination)
print("Research binaries installed; no scans were run.")
