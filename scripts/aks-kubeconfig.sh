#!/usr/bin/env bash
set -euo pipefail

: "${SUB:?Set SUB to your subscription ID or name}"
: "${RG:?Set RG to your AKS resource group}"
: "${CLUSTER:?Set CLUSTER to your AKS cluster name}"

# Ensure kubectl/kubelogin
az aks install-cli

# Login (Managed Identity on jump host OR interactive)
az login --identity || az login
az account set --subscription "$SUB"

# Merge kubeconfig and switch to Azure CLI token auth
az aks get-credentials --resource-group "$RG" --name "$CLUSTER" --overwrite-existing
kubelogin convert-kubeconfig -l azurecli

# Smoke tests
kubectl version --client --short
kubectl get nodes
