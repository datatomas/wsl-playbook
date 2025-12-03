
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

# Scope should be the *Key Vault* resource
SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/${KEYVAULT_NAME}"

# Azure built-in RBAC roles for Key Vault
KEY_READ_ROLE="Key Vault Crypto User"                    # Get, List keys
SECRET_READ_ROLE="Key Vault Secrets User"                # Get, List secrets
SECRET_ADMIN_ROLE="Key Vault Secrets Officer"            # Full secret management
CERT_READ_ROLE="Key Vault Certificate User"              # Get, List certificates

# ------------------------------
# Principals organized by permission type
# ------------------------------
# Principals with KEY permissions (Get, List)
readonly KEY_PERMISSIONS=(
  # No principals have key permissions in this vault
)

# Principals with SECRET permissions (Get, List) - READ ONLY
readonly SECRET_READ_PERMISSIONS=(
  # APPLICATIONS
  "234sdf1-123a-123a-asd-123""
  "123asd-asd-4c67-bb33-123asd"
  "123asd-123aa-123a-asd1-123a"
  
)

# Principals with SECRET ADMIN permissions (All)
readonly SECRET_ADMIN_PERMISSIONS=(
  "123-4545-a11a"              # GROUP - All
)

# Principals with CERTIFICATE permissions (Get, List) - READ ONLY
readonly CERT_READ_PERMISSIONS=(
  # APPLICATIONS
  "123-123-132-143-152""
  "233-334-421-124-124e"
  "41ad-6ff3-123-ad12-123a"
)
# ------------------------------
# Output colors
# ------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "Azure Key Vault RBAC Assignment Script"
echo "========================================="
echo "Key Vault:     $KEYVAULT_NAME"
echo "Resource Group:$RESOURCE_GROUP"
echo "Subscription:  $SUBSCRIPTION_ID"
echo "Scope:         $SCOPE"
echo "-----------------------------------------"
echo "Key read role:        $KEY_READ_ROLE"
echo "Secret read role:     $SECRET_READ_ROLE"
echo "Secret admin role:    $SECRET_ADMIN_ROLE"
echo "Certificate read role:$CERT_READ_ROLE"
echo "-----------------------------------------"
echo "Key permissions:      ${#KEY_PERMISSIONS[@]} principals"
echo "Secret read:          ${#SECRET_READ_PERMISSIONS[@]} principals"
echo "Secret admin:         ${#SECRET_ADMIN_PERMISSIONS[@]} principals"
echo "Certificate read:     ${#CERT_READ_PERMISSIONS[@]} principals"
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

    # Try service principal (for GUIDs, app names, etc.)
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

# Assign KEY permissions
if [[ ${#KEY_PERMISSIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}=== Assigning KEY read role: $KEY_READ_ROLE ===${NC}"
    echo "-----------------------------------------"
    for principal in "${KEY_PERMISSIONS[@]}"; do
        ensure_role_assignment "$principal" "$KEY_READ_ROLE" "$SCOPE"
        rc=$?
        case "$rc" in
            0) ((success_count++));;
            2) ((skip_count++));;
            *) ((fail_count++));;
        esac
    done
    echo ""
fi

# Assign SECRET READ permissions
if [[ ${#SECRET_READ_PERMISSIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}=== Assigning SECRET read role: $SECRET_READ_ROLE ===${NC}"
    echo "-----------------------------------------"
    for principal in "${SECRET_READ_PERMISSIONS[@]}"; do
        ensure_role_assignment "$principal" "$SECRET_READ_ROLE" "$SCOPE"
        rc=$?
        case "$rc" in
            0) ((success_count++));;
            2) ((skip_count++));;
            *) ((fail_count++));;
        esac
    done
    echo ""
fi

# Assign SECRET ADMIN permissions
if [[ ${#SECRET_ADMIN_PERMISSIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}=== Assigning SECRET admin role: $SECRET_ADMIN_ROLE ===${NC}"
    echo "-----------------------------------------"
    for principal in "${SECRET_ADMIN_PERMISSIONS[@]}"; do
        ensure_role_assignment "$principal" "$SECRET_ADMIN_ROLE" "$SCOPE"
        rc=$?
        case "$rc" in
            0) ((success_count++));;
            2) ((skip_count++));;
            *) ((fail_count++));;
        esac
    done
    echo ""
fi

# Assign CERTIFICATE permissions
if [[ ${#CERT_READ_PERMISSIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}=== Assigning CERTIFICATE read role: $CERT_READ_ROLE ===${NC}"
    echo "-----------------------------------------"
    for principal in "${CERT_READ_PERMISSIONS[@]}"; do
        ensure_role_assignment "$principal" "$CERT_READ_ROLE" "$SCOPE"
        rc=$?
        case "$rc" in
            0) ((success_count++));;
            2) ((skip_count++));;
            *) ((fail_count++));;
        esac
    done
    echo ""
fi

echo ""
echo "========================================="
echo "Summary"
echo "========================================="
echo -e "${GREEN}Successful assignments: $success_count${NC}"
echo -e "${YELLOW}Skipped (already had):  $skip_count${NC}"
echo -e "${RED}Failed:                 $fail_count${NC}"
echo "========================================="

# Show current role assignments for this Key Vault scope
echo ""
echo "Current role assignments on Key Vault:"
az role assignment list \
    --scope "$SCOPE" \
    --query "[].{Principal:principalName, Role:roleDefinitionName, Scope:scope}" \
    --output table
