#!/usr/bin/env bash
set -euo pipefail
: "${TENANT:?Set TENANT in .env}"

if ! az account show >/dev/null 2>&1; then
  echo ">>> Not logged in. Launching device login for tenant $TENANT…"
  az login --tenant "$TENANT" --use-device-code
fi

# Keep previews quiet
az config set extension.dynamic_install_allow_preview=true
