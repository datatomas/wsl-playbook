#!/usr/bin/env bash
set -euo pipefail

az version
az upgrade -y

# Cognitive Services extension (example)
az extension add -n cognitiveservices --upgrade || az extension update -n cognitiveservices

# Refresh token
az account clear || true
az login --use-device-code
