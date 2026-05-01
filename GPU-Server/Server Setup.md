# Slurm GPU Cluster Setup Guide
> A100 80GB PCIe — Single Node — Time-Slicing — 3 Parallel Jobs

---

## 📋 Server Details
```
# ⚠️ CHANGE THESE FOR NEW SERVER
HOSTNAME=e2e-73-93          # Change to your server hostname
CLUSTER_NAME=a100cluster    # Change to your cluster name
CPU_COUNT=16                # Change to your CPU count
REAL_MEMORY=107747          # Change to your RAM in MB (free -m | grep Mem)
```

---

## Step 1 — Install Dependencies

```bash
apt-get update -y
apt-get install -y \
    slurm-wm \
    slurmctld \
    slurmd \
    munge \
    libmunge-dev \
    libmunge2 \
    nvidia-utils-535 \
    stress-ng \
    python3-torch
```

---

## Step 2 — Configure Munge Authentication

```bash
# Generate munge key
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# Start munge
systemctl enable munge
systemctl start munge

# Verify munge
munge -n | unmunge
```

---

## Step 3 — Create Required Directories

```bash
mkdir -p /var/spool/slurm/ctld
mkdir -p /var/spool/slurm/d
mkdir -p /var/log/slurm
mkdir -p /var/run/slurm
mkdir -p /etc/slurm

# Fix ownership
chown -R slurm:slurm /var/spool/slurm
chown -R slurm:slurm /var/log/slurm
chown -R slurm:slurm /var/run/slurm
```

---

## Step 4 — Verify GPU

```bash
# Verify nvidia driver
nvidia-smi

# ⚠️ Make sure MIG is DISABLED
nvidia-smi -i 0 -mig 0

# Verify device exists
ls /dev/nvidia0
```

---

## Step 5 — Create Virtual GPU Symlinks (Time-Slicing)

```bash
# Creates 3 virtual GPU devices for 3 parallel jobs
# ⚠️ Change count as needed (e.g. nvidia-ts[0-4] for 5 jobs)
ln -sf /dev/nvidia0 /dev/nvidia-ts0
ln -sf /dev/nvidia0 /dev/nvidia-ts1
ln -sf /dev/nvidia0 /dev/nvidia-ts2

# Verify
ls -la /dev/nvidia-ts*
```

---

## Step 6 — Create gres.conf

```bash
cat > /etc/slurm/gres.conf << 'EOF'
# ⚠️ CHANGE nvidia-ts[0-2] count to match parallel jobs needed
# 3 parallel jobs = nvidia-ts[0-2]
# 5 parallel jobs = nvidia-ts[0-4]
# 7 parallel jobs = nvidia-ts[0-6]
Name=gpu Type=A100 File=/dev/nvidia-ts[0-2]
EOF
```

---

## Step 7 — Create slurm.conf

```bash
cat > /etc/slurm/slurm.conf << 'EOF'
# ⚠️ CHANGE ClusterName, SlurmctldHost, NodeName, CPUs, RealMemory
ClusterName=a100cluster
SlurmctldHost=e2e-73-93

AuthType=auth/none
CredType=cred/none
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory
GresTypes=gpu

SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmdPidFile=/var/run/slurm/slurmd.pid
SlurmctldDebug=info
SlurmdDebug=info

StateSaveLocation=/var/spool/slurm/ctld
SlurmdSpoolDir=/var/spool/slurm/d

SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0

# ⚠️ CHANGE: NodeName, CPUs, RealMemory, Gres count to match parallel jobs
# Get CPUs:    nproc
# Get Memory:  free -m | grep Mem | awk '{print $2}'
# Gres count must match nvidia-ts symlinks created in Step 5
NodeName=e2e-73-93 CPUs=16 RealMemory=107747 Gres=gpu:A100:3 State=UNKNOWN Sockets=1 CoresPerSocket=16 ThreadsPerCore=1

# ⚠️ CHANGE: Partition names and Nodes to match your setup
PartitionName=gpu-20gb Nodes=e2e-73-93 MaxTime=INFINITE State=UP Default=YES
PartitionName=gpu-40gb Nodes=e2e-73-93 MaxTime=INFINITE State=UP Default=NO
PartitionName=gpu-80gb Nodes=e2e-73-93 MaxTime=INFINITE State=UP Default=NO
EOF
```

---

## Step 8 — Fix Environment File

```bash
# Fix SLURMD_OPTIONS warning
echo 'SLURMD_OPTIONS=""' > /etc/default/slurmd
```

---

## Step 9 — Start Slurm Services

```bash
# Enable and start
systemctl enable slurmctld slurmd
systemctl start slurmctld
sleep 3
systemctl start slurmd
sleep 3

# Verify both running
systemctl is-active slurmctld
systemctl is-active slurmd
```

---

## Step 10 — Bring Node Online

```bash
scontrol update NodeName=e2e-73-93 State=down Reason="setup"  # ⚠️ Change hostname
sleep 2
scontrol update NodeName=e2e-73-93 State=resume               # ⚠️ Change hostname

# Verify node is idle
sinfo
```

Expected output:
```
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
gpu-20gb*    up   infinite      1   idle e2e-73-93
gpu-40gb     up   infinite      1   idle e2e-73-93
gpu-80gb     up   infinite      1   idle e2e-73-93
```

---

## Step 11 — Verify Setup

```bash
# Check node config
scontrol show node e2e-73-93   # ⚠️ Change hostname

# Should show:
# State=IDLE
# Gres=gpu:A100:3
# CPUTot=16
```

---

## Step 12 — Submit Test Job

```bash
cat > test_job.sh << 'EOF'
#!/bin/bash
#SBATCH --partition=gpu-20gb
#SBATCH --gres=gpu:A100:1
#SBATCH --job-name=test_job
#SBATCH --output=output_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:05:00

echo "Job started at: $(date)"
echo "Running on node: $(hostname)"
nvidia-smi
sleep 60
echo "Job finished at: $(date)"
EOF

sbatch test_job.sh
squeue
```

---

## User Job Submission Template

Users should create `job.sh`:

```bash
#!/bin/bash
#SBATCH --partition=gpu-20gb       # Partition: gpu-20gb / gpu-40gb / gpu-80gb
#SBATCH --gres=gpu:A100:1          # Request 1 GPU
#SBATCH --job-name=my_job          # Job name
#SBATCH --output=output_%j.log     # Output log file
#SBATCH --ntasks=1                 # Number of tasks
#SBATCH --cpus-per-task=4          # CPUs per task
#SBATCH --mem=16G                  # Memory required
#SBATCH --time=01:00:00            # Max runtime HH:MM:SS

# Your commands here
python train.py
```

Submit:
```bash
sbatch job.sh
```

---

## Useful Commands

```bash
squeue                              # View all jobs
squeue -u <username>                # View jobs by user
sinfo                               # View node/partition status
scancel <job_id>                    # Cancel a job
scancel -u <username>               # Cancel all jobs of a user
scontrol show job <job_id>          # Job details
scontrol show node e2e-73-93        # Node details
cat output_<job_id>.log             # View job output
```

---

## Troubleshooting

### Node stuck in inval/idle*/unk state
```bash
systemctl restart slurmctld
sleep 3
systemctl restart slurmd
sleep 3
scontrol update NodeName=e2e-73-93 State=down Reason="fix"
sleep 2
scontrol update NodeName=e2e-73-93 State=resume
sinfo
```

### slurmd fails to start
```bash
journalctl -xeu slurmd --no-pager | grep "slurmd:" | tail -20
```

### Job stuck in Pending
```bash
squeue -o "%.18i %.9P %.8u %.8T %.10M %.6D %R"
# If reason is Resources — all 3 slots are full, wait for a job to finish
# If reason is Nodes required — node is down, run troubleshoot above
```

### Security violation uid error
```bash
chown -R slurm:slurm /var/spool/slurm
chown -R slurm:slurm /var/log/slurm
chown -R slurm:slurm /var/run/slurm
systemctl restart slurmctld
sleep 3
systemctl restart slurmd
```

---

## Parallel Jobs Reference

| Symlinks | gres.conf | slurm.conf Gres | Parallel Jobs |
|---|---|---|---|
| nvidia-ts[0-2] | File=/dev/nvidia-ts[0-2] | gpu:A100:3 | **3** |
| nvidia-ts[0-4] | File=/dev/nvidia-ts[0-4] | gpu:A100:5 | **5** |
| nvidia-ts[0-6] | File=/dev/nvidia-ts[0-6] | gpu:A100:7 | **7** |

---

*Cluster: a100cluster | Node: e2e-73-93 | GPU: NVIDIA A100 80GB PCIe | Slurm: 23.11.4*