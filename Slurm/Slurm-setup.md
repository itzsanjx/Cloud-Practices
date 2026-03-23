
---

# 🚀 Full Guide: GitHub → Slurm Setup → Connection

## 🧩 Step 1: Prepare Your Slurm Configuration Locally

Create a folder for your Slurm setup:

```bash
mkdir slurm-cluster-config
cd slurm-cluster-config
```

Add key config files:

* `slurm.conf`
* `cgroup.conf`
* `gres.conf` (if GPUs used)
* `topology.conf` (optional)

Example basic `slurm.conf`:

```conf
ClusterName=mycluster
ControlMachine=slurm-controller
SlurmUser=slurm
NodeName=node[1-2] CPUs=2 State=UNKNOWN
PartitionName=debug Nodes=node[1-2] Default=YES MaxTime=INFINITE State=UP
```

---

## 📦 Step 2: Push Config to GitHub

Initialize git:

```bash
git init
git add .
git commit -m "Initial Slurm config"
```

Create repo on GitHub and push:

```bash
git remote add origin https://github.com/yourusername/slurm-config.git
git branch -M main
git push -u origin main
```

---

## 🖥️ Step 3: Setup Slurm on Server (Controller Node)

Install Slurm:

```bash
sudo apt update
sudo apt install slurm-wlm
```

Or for CentOS:

```bash
sudo yum install slurm slurm-slurmctld slurm-slurmd
```

---

## 📥 Step 4: Pull Config from GitHub to Server

On controller node:

```bash
git clone https://github.com/yourusername/slurm-config.git
cd slurm-config
```

Copy config:

```bash
sudo cp *.conf /etc/slurm/
```

---

## ⚙️ Step 5: Configure Munge (Authentication)

Install munge:

```bash
sudo apt install munge
```

Create key:

```bash
sudo create-munge-key
```

Start service:

```bash
sudo systemctl enable munge
sudo systemctl start munge
```

👉 Copy `/etc/munge/munge.key` to all compute nodes securely.

---

## 🧠 Step 6: Setup Slurm Controller

Start controller:

```bash
sudo systemctl enable slurmctld
sudo systemctl start slurmctld
```

Check:

```bash
scontrol ping
```

---

## 🖧 Step 7: Setup Compute Nodes

On each node:

```bash
sudo apt install slurm-wlm
git clone https://github.com/yourusername/slurm-config.git
sudo cp *.conf /etc/slurm/
```

Start node daemon:

```bash
sudo systemctl enable slurmd
sudo systemctl start slurmd
```

---

## 🔗 Step 8: Test Cluster Connection

From controller:

```bash
sinfo
```

Submit test job:

```bash
sbatch --wrap="hostname"
```

Check output:

```bash
cat slurm-*.out
```

---

## 🌐 Step 9: Optional – Auto Sync from GitHub

To keep configs updated automatically:

```bash
git pull origin main
sudo systemctl restart slurmctld slurmd
```

Or use cron:

```bash
crontab -e
```

Add:

```bash
*/5 * * * * cd /path/to/slurm-config && git pull
```

---

# 🧩 Architecture Overview

```
GitHub Repo
     ↓
Controller Node (slurmctld)
     ↓
Compute Nodes (slurmd)
```

---


