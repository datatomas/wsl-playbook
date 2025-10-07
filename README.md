# wsl-playbook quickstart 
git clone <your repo> wsl-azure-playbook
cd wsl-azure-playbook
cp .env.example .env && nano .env
source .env

bash scripts/02-install-azure-cli-bicep.sh
bash scripts/03-tenant-sub-login.sh
bash scripts/10-aks-quick-setup.sh
