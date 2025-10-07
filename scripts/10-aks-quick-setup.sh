#!/usr/bin/env bash
set -euo pipefail
: "${SUB:?Set SUB in .env}"
: "${RG:?Set RG in .env}"
: "${CLUSTER:?Set CLUSTER in .env}"

# Install/refresh kubectl (+kubelogin if needed)
az aks install-cli

# Login: Managed Identity (jump host) or interactive
az login --identity || az login
az account set --subscription "$SUB"

# Pull kubeconfig and use Azure CLI tokens (no device-code prompts in kubectl)
az aks get-credentials -g "$RG" -n "$CLUSTER" --overwrite-existing
kubelogin convert-kubeconfig -l azurecli

# Smoke tests
kubectl version --client --short
kubectl get nodes

# Example: list pods from a specific namespace
# kubectl get pods -n ns-xmregfro
