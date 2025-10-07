#!/usr/bin/env bash
set -euo pipefail
: "${TENANT:?Set TENANT in .env}"
: "${SUB:?Set SUB in .env}"

az account tenant list -o table
az account subscription show --subscription-id "$SUB" \
  --query "{Name:displayName, Id:subscriptionId, Tenant:tenantId}" -o table

az login --tenant "$TENANT" --use-device-code
az account set --subscription "$SUB"
az account show --query "{Name:name, Id:id, Tenant:tenantId}" -o table
