# 🐧 The Linux Fan's Quick Guide to Azure on WSL  
### Bash, Bicep, and Beautiful Simplicity  
Pragmatic, fast, and proudly Unix-y — with all the commands you need

If you love the Unix philosophy — simple tools that compose, scripts you can read, and control that feels local — this guide is for you.  
We'll use **Linux (via Windows Subsystem for Linux)**, **Bash**, and **Azure Bicep** to deliver private-first deployments without mile-long scripts.  
This is a short, opinionated field manual: respectful to Windows, proudly Linux.

---

## 🌍 Why Linux (WSL) for Azure engineers — the fan rationale
- **Composability:** one-liners and pipes that do exactly what you tell them.  
- **Readability:** Bash scripts are just text — reviewable, diff-able, sharable.  
- **Reproducibility:** parameterized Bicep + Bash runners = deterministic deploys.  
- **Speed:** no ceremony — open a shell, run `what-if`, ship.  

**Pragmatism:** WSL lets you keep Windows productivity while working with Linux clarity.

---

## 0️⃣ Install WSL + load your environment  
**Goal:** get Ubuntu running on WSL, then load your Windows repo’s env file so every new Bash session has your Azure variables.

### 🪟 Install and choose your distro (PowerShell as Admin)
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
