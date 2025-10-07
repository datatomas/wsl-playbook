# --- Config (edit if your env file path or distro differs) ---
$Distro  = "Ubuntu"
$EnvPath = "C:\Users\SuarezTo\OneDrive - Unisys\Documents\GitHub\unisys_infra_repo\wsl_environment.env"

Write-Host ">>> Checking WSL availability and listing distros..."
wsl --list --online

# Install Ubuntu (idempotent; will skip if already installed)
Write-Host ">>> Installing $Distro (this may reboot or prompt)..."
wsl --install -d $Distro

# Make Ubuntu the default
wsl --set-default $Distro
wsl --set-default-version 2
wsl --status

# Ensure the Windows-side env file exists
if (!(Test-Path $EnvPath)) {
  Write-Error "Env file not found at: $EnvPath"
  exit 1
}

Write-Host ">>> Copying env into WSL home as ~/.env and auto-sourcing from .bashrc..."
# Note: Bash sees Windows path via /mnt/c/...
$EnvPathForWSL = "/mnt/c/Users/SuarezTo/OneDrive - Unisys/Documents/GitHub/unisys_infra_repo/wsl_environment.env"

wsl -d $Distro -- bash -lc "set -euo pipefail; \
  cp '$EnvPathForWSL' ~/.env; \
  touch ~/.bashrc; \
  grep -qxF '[[ -f ~/.env ]] && source ~/.env' ~/.bashrc || echo '[[ -f ~/.env ]] && source ~/.env' >> ~/.bashrc; \
  echo '>> ~/.env installed and will be auto-loaded in new shells.'"

Write-Host ">>> Done. Open WSL with:  wsl -d $Distro"
