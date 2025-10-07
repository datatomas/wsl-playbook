#!/usr/bin/env bash
set -euo pipefail

az cloud set -n AzureCloud
az account clear
az logout --verbose || true
az account list -o table   # should be []
