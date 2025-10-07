#!/usr/bin/env bash
set -euo pipefail

# Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Quiet dynamic installs / allow previews when needed
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.dynamic_install_allow_preview=true

# Bicep
az bicep install || az bicep upgrade

# Reuse Windows credential UI (optional)
az config set core.use_cmd_login=True

az version
