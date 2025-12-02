
# All users to be granted access

#!/bin/bash
# Azure Key Vault Secret Permissions Sync Script
# Migrates old access policy-style secret permissions (Get, List)
# into Key Vault RBAC assignments (read-only for everyone).

# ------------------------------
# Configuration
# ------------------------------
SUBSCRIPTION_ID="123-123-123-123-321"
RESOURCE_GROUP="rg_yourrg_01"
KEYVAULT_NAME="kv-yourkv-prd-01"

# Scope should be the *Key Vault* resource, not just the RG
SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/${KEYVAULT_NAME}"

# Single role mapping for secret permissions (read-only for all)
SECRET_READ_ROLE="Key Vault Secrets User"

# ------------------------------
# Principals with secret read permissions
# (Everyone gets the same read-only role now)
# ------------------------------
readonly SECRET_READ_PRINCIPALS=(

    "email1@uppercutanalytics.com.co"
    "email2@uppercutanalytics.com.co"
    "email2@uppercutanalytics.com.co"
)

# ------------------------------
# Output colors
# ------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Azure Key Vault Secret RBAC Sync"
echo "========================================="
echo "Key Vault:     $KEYVAULT_NAME"
echo "Resource Group:$RESOURCE_GROUP"
echo "Subscription:  $SUBSCRIPTION_ID"
echo "Scope:         $SCOPE"
echo "-----------------------------------------"
echo "Secret role (all principals): $SECRET_READ_ROLE"
echo "Total principals             : ${#SECRET_READ_PRINCIPALS[@]}"
echo "========================================="
echo ""

# ------------------------------
# Helper: check if a principal exists in AAD
# ------------------------------
check_principal_exists() {
    local principal="$1"

    # Try user
    if az ad user show --id "$principal" &>/dev/null; then
        return 0
    fi

    # Try group (by name or objectId)
    if az ad group show --group "$principal" &>/dev/null; then
        return 0
    fi

    # Try service principal (for GUIDs etc.)
    if az ad sp show --id "$principal" &>/dev/null; then
        return 0
    fi

    return 1
}

# ------------------------------
# Helper: ensure role assignment
# Exit codes:
#   0 = role created
#   1 = failure
#   2 = already assigned (skip)
# ------------------------------
ensure_role_assignment() {
    local principal="$1"
    local role="$2"
    local scope="$3"

    echo -n "Processing: $principal (role: $role) ... "

    if ! check_principal_exists "$principal"; then
        echo -e "${RED}FAILED - principal not found in Azure AD${NC}"
        return 1
    fi

    # Check existing assignment for this principal/role/scope
    local existing
    existing=$(az role assignment list \
        --assignee "$principal" \
        --role "$role" \
        --scope "$scope" \
        --query "[].id" \
        --output tsv 2>/dev/null)

    if [[ -n "$existing" ]]; then
        echo -e "${YELLOW}SKIPPED - role already assigned${NC}"
        return 2
    fi

    # Create assignment
    if az role assignment create \
        --assignee "$principal" \
        --role "$role" \
        --scope "$scope" \
        --output none 2>/dev/null; then
        echo -e "${GREEN}SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}FAILED - error creating assignment${NC}"
        return 1
    fi
}

# ------------------------------
# Main
# ------------------------------
success_count=0
skip_count=0
fail_count=0

echo "Assigning secret READ-ONLY role: $SECRET_READ_ROLE"
echo "-----------------------------------------"
for principal in "${SECRET_READ_PRINCIPALS[@]}"; do
    ensure_role_assignment "$principal" "$SECRET_READ_ROLE" "$SCOPE"
    rc=$?
    case "$rc" in
        0) ((success_count++));;
        2) ((skip_count++));;
        *) ((fail_count++));;
    esac
done

echo ""
echo "========================================="
echo "Summary"
echo "========================================="
echo -e "${GREEN}Successful assignments: $success_count${NC}"
echo -e "${YELLOW}Skipped (already had):  $skip_count${NC}"
echo -e "${RED}Failed:                 $fail_count${NC}"
echo "========================================="

# Role assignments for this Key Vault scope
echo ""
echo "Current role assignments on Key Vault:"
az role assignment list \
    --scope "$SCOPE" \
    --query "[].{Principal:principalName, Role:roleDefinitionName, Scope:scope}" \
    --output table
