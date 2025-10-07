#!/usr/bin/env bash
set -euo pipefail
: "${TENANT:?Set TENANT in .env}"
: "${SUB:?Set SUB in .env}"

# Reset token/session cache
rm -rf ~/.azure
mkdir -p ~/.azure

# Reduce risk with parallel plugin loads
az config set core.parallel_load=False

# Rare legacy: ADAL (mostly deprecated; only flip if troubleshooting ancient flows)
# az config set core.use_adal=True

# Re-login cleanly
az login --tenant "$TENANT" --use-device-code
az account set --subscription "$SUB"

# Ensure no Windows cache symlinked if you want a totally clean test
# rm -rf ~/.azure
# az login --tenant "$TENANT" --use-device-code

# Reconfirm
az account show --query "{Name:name, Id:id}" -o table

# (Optional) Re-link Windows cache after testing
# ln -s "/mnt/c/Users/SuarezTo/.azure" ~/.azure

# Restart background cache, verify
sudo pkill -f "az rest" || true
az version
