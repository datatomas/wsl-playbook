# The Linux Fan's Quick Guide to Azure on WSL  
### Bash, Bicep, and Beautiful Simplicity  
Pragmatic, fast, and proudly Unix-y — with all the commands you need

If you love the Unix philosophy — simple tools that compose, scripts you can read, and control that feels local — this guide is for you.  
We'll use **Linux (via Windows Subsystem for Linux)**, **Bash**, and **Azure Bicep** to deliver private-first deployments without mile-long scripts.  
This is a short, opinionated field manual: respectful to Windows, proudly Linux.

---

## Why Linux (WSL) for Azure engineers — the fan rationale
- **Composability:** one-liners and pipes that do exactly what you tell them.  
- **Readability:** Bash scripts are just text — reviewable, diff-able, sharable.  
- **Reproducibility:** parameterized Bicep + Bash runners = deterministic deploys.  
- **Speed:** no ceremony — open a shell, run `what-if`, ship.  

**Pragmatism:** WSL lets you keep Windows productivity while working with Linux clarity.

---

## 0️⃣ Install WSL + load your environment  
**Goal:** get Ubuntu running on WSL, then load your Windows repo’s env file so every new Bash session has your Azure variables.

### Install and choose your distro (PowerShell as Admin)
```powershell
# List available distros
wsl --list --online

# Install Ubuntu (good default)
wsl --install -d Ubuntu

# Make Ubuntu default and use WSL 2
wsl --set-default Ubuntu
wsl --set-default-version 2

# Check
wsl --status


Copy your environment from Windows into WSL

Your file:
C:\Users\SuarezTo\OneDrive - Unisys\Documents\GitHub\unisys_infra_repo\wsl_environment.env

In WSL, that path is:
/mnt/c/Users/SuarezTo/OneDrive - Unisys/Documents/GitHub/unisys_infra_repo/wsl_environment.env

# Copy the Windows env file into WSL
cp "/mnt/c/Users/SuarezTo/OneDrive - Unisys/Documents/GitHub/unisys_infra_repo/wsl_environment.env" ~/.env

# Fix line endings and syntax if needed
sudo apt update && sudo apt install -y dos2unix
dos2unix ~/.env

# Auto-source it in every new shell
grep -qxF '[[ -f ~/.env ]] && source ~/.env' ~/.bashrc || echo '[[ -f ~/.env ]] && source ~/.env' >> ~/.bashrc

# Load it now
source ~/.env


Important:
Make sure your .env has no spaces around =.
Example:

SUB="XXXX"
CLUSTER="XCluster"
RG="XResourceGroup"


Verify it:

echo "$SUB"
echo "$CLUSTER"
echo "$RG"


If you see the values printed correctly, you’re good to go.

1️⃣ Open WSL and navigate your repo
# From PowerShell
wsl -d Ubuntu

# Navigate to your repo
cd "/mnt/c/Users/suarezto/OneDrive - Unisys/Documents/GitHub/unisys_infra_repo/iac"

# Ensure runner is executable
chmod +x afd-origin-endpoint-runner.bash

# Run it
./afd-origin-endpoint-runner.bash

2️⃣ Install Azure CLI and Bicep (once)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Enable preview and auto extension install
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.dynamic_install_allow_preview=true

# Install or upgrade Bicep
az bicep install || az bicep upgrade

# Reuse Windows credential prompt (optional)
az config set core.use_cmd_login=True

3️⃣ Tenants, subscriptions, and device-code login
az account tenant list -o table
az account subscription show --subscription-id $SUB \
  --query "{Name:displayName, Id:subscriptionId, Tenant:tenantId}" -o table

# Login to your tenant (clean, no browser popups)
az login --tenant $TENANT --use-device-code

4️⃣ Hygiene — when caches or sessions misbehave
az cloud set -n AzureCloud
az account clear
az logout --verbose
az account list -o table  # should return []

5️⃣ Optional — copy or sync Windows auth with WSL

Short-term convenience trick; for long-term, prefer federated identities.

mkdir -p ~/.azure
cp "/mnt/c/Users/SuarezTo/.azure/"* ~/.azure/ 2>/dev/null || true
ls -l ~/.azure

# OR link directly
rm -rf ~/.azure
ln -s "/mnt/c/Users/SuarezTo/.azure" ~/.azure

6️⃣ Tiny auto-login guard for scripts
if ! az account show >/dev/null 2>&1; then
  echo ">>> Not logged in. Launching device login..."
  az login --tenant "$TENANT" --use-device-code
fi

az config set extension.dynamic_install_allow_preview=true

7️⃣ Deep-clean auth and re-login
rm -rf ~/.azure && mkdir ~/.azure
az config set core.parallel_load=False
az login --tenant "$TENANT" --use-device-code
az account set --subscription "$SUB"
az account show --query "{Name:name, Id:id}" -o table

8️⃣ Day-2 favorite — SSH into an App Service from WSL
az login --use-device-code
az account set --subscription "$SUB"

az webapp show -g "$WEBAPP_RG" -n "$WEBAPP_NAME" \
  --query "{Name:name, State:state, SSH:enabledHostNames}" -o table

az webapp ssh -g "$WEBAPP_RG" -n "$WEBAPP_NAME"

9️⃣ Keep the CLI current
az version
az upgrade -y

az extension add -n cognitiveservices --upgrade || az extension update -n cognitiveservices
az account clear && az login --use-device-code

🔟 Bonus — Kubernetes (AKS) quick setup on WSL
# Install/refresh kubectl (+kubelogin)
az aks install-cli

# Login: Managed Identity (jump host) or interactive
az login --identity || az login
az account set --subscription "$SUB"

# Pull kubeconfig and use Azure CLI tokens
az aks get-credentials -g "$RG" -n "$CLUSTER" --overwrite-existing
kubelogin convert-kubeconfig -l azurecli

# Test
kubectl version --client --short
kubectl get nodes

# Example: check pods in a namespace
kubectl get pods -n ns-xmregfro

Troubleshooting
Symptom	Cause	Fix
: command not found when sourcing .env	CRLF line endings or spaces around =	Run dos2unix ~/.env and remove spaces
az: command not found	CLI not installed or PATH not refreshed	Re-run install step and restart WSL
Login loops	Cached mixed credentials	Run section 4 (hygiene) or section 7 (deep-clean)
💻 Connect with me

Thanks for reading!
I share insights on Azure, multi-cloud architecture, and Python automation for data & AI systems.

💼 Upwork: Tomas Suarez

🌐 Freelancer: datatomas

💻 GitHub: datatomas

🧠 Substack: datatomas

🔗 LinkedIn: Tomas Suarez

🏁 Final note — minimalism with manners

Linux rewards focus: short commands, readable scripts, and simple composition.
WSL lets you bring that power to any Windows laptop.
Use this workflow for fast, private-first deployments; graduate to DevOps pipelines for approvals and scale.

Proudly Linux. Friendly to Windows. Extremely effective for Azure.


---

Would you like me to also generate the corresponding folder tree (with `.env.example` and script placeholders) so you can `git add .` and push immediately?

