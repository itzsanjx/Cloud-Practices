# WSAI HPC Cluster

A Slurm-based multi-node GPU compute cluster for research and coursework workloads. This document describes the architecture, hardware, software stack, networking, user management, and known issues for anyone administering or onboarding onto the cluster.

---

## 1. Overview

| | |
|---|---|
| **Scheduler** | Slurm 23.11.4 (configless mode) |
| **Auth** | Munge (`AuthType=auth/munge`) |
| **Nodes** | 1 controller + 2–3 GPU/CPU workers |
| **Shared storage** | NFS-mounted `/home` and `/storage` from a Synology NAS |
| **OS** | Ubuntu 24.04.4 LTS (kernel 6.8.x) |
| **Accounting** | slurmdbd + MariaDB |
| **Job isolation** | cgroup v2 (cores, RAM, devices) |

The cluster runs a single default Slurm partition (`public`) shared by all nodes, with per-node GPU/CPU resources exposed via `Gres`/`Feature` tags so users can target specific hardware (e.g. K80, 1080 Ti) with `--gres` and `--constraint`.

---

## 2. Architecture Diagram

```
                         ┌─────────────────────┐
                         │   WSAI-CLUSTER       │
                         │   (Controller)        │
                         │   10.24.6.55/24        │
                         │   slurmctld, slurmdbd  │
                         │   MariaDB, munge       │
                         └──────────┬────────────┘
                                    │
                 ┌──────────────────┼──────────────────┬───────────────────┐
                 │                  │                   │                   │
        ┌────────▼───────┐ ┌────────▼───────┐ ┌────────▼────────┐ ┌────────▼────────┐
        │  WSAI-01        │ │  WSAI-02        │ │  WSAI-03 (old)   │ │  WSAI-03 (new)   │
        │  10.24.6.54     │ │  10.24.6.57     │ │  10.24.6.58       │ │  10.17.66.189     │
        │  2x Tesla K80   │ │  2x Tesla K80   │ │  CPU-only          │ │  3x GTX 1080 Ti   │
        │                 │ │                 │ │  (being removed)   │ │  diff. subnet     │
        └─────────────────┘ └─────────────────┘ └────────────────────┘ └────────────────────┘
                 │                  │
                 └──────────┬───────┘
                             │
                   ┌─────────▼─────────┐
                   │  Synology NAS      │
                   │  10.24.6.62         │
                   │  NFS: /home,/storage │
                   └────────────────────┘
```

> **Note:** The original WSAI-03 (10.24.6.58, CPU-only) is being decommissioned. A separate machine, also named WSAI-03 but on a different subnet (10.17.66.189, 3x GTX 1080 Ti), has since been added as the GPU worker of that name. These are two distinct physical machines — do not confuse them.

---

## 3. Node Inventory

### 3.1 Controller — `WSAI-CLUSTER`

- **IP:** `10.24.6.55/24`, gateway `10.24.6.254`, interface `ens1f1`
- **Hardware:** Supermicro SYS-2028GR-TR, single Xeon E5-2640 v3 (16 threads), 62 GB RAM, no GPU, 930 GB root (`/dev/sda2`)
- **OS:** Ubuntu 24.04.4, kernel `6.8.0-134-generic`
- **Role:** slurmctld, slurmdbd (port 6819), MariaDB, munge key authority, NFS client

### 3.2 Worker — `WSAI-01`

- **IP:** `10.24.6.54/24`, interface `ens1f0`
- **Hardware:** Same base spec as controller; **2x Tesla K80** (driver `470.256.02-server`, CUDA 11.4)
- **OS:** Ubuntu 24.04.4, kernel `6.8.0-124`
- **slurmd:** `-N WSAI-01 --conf-server WSAI-CLUSTER`

### 3.3 Worker — `WSAI-02`

- **IP:** `10.24.6.57/24`, interface `ens1f0`
- **Hardware:** Identical to WSAI-01; **2x Tesla K80**
- **OS:** Ubuntu 24.04.4, kernel `6.8.0-124`
- **Note:** Also runs microk8s/Calico (legacy, not part of core Slurm workload — candidate for cleanup)

### 3.4 Worker — `WSAI-03` (GPU, current)

- **IP:** `10.17.66.189` — **different subnet** (10.17.66.0/24) from the rest of the cluster (10.24.6.0/24)
- **Hardware:** 3x GTX 1080 Ti (one GPU has a persistent hardware-level fault, not currently usable)
- **OS:** Ubuntu 24.04 (reinstalled to match cluster's Slurm 23.11.4 wire protocol)
- **slurm.conf line:**
  ```
  NodeName=WSAI-03 NodeAddr=10.17.66.189 Sockets=2 CoresPerSocket=10 ThreadsPerCore=2 \
  CPUs=40 RealMemory=157000 Gres=gpu:1080ti:3 Feature=1080ti
  ```
- **Firewall:** Requires explicit UFW allow rules on the controller for `10.17.66.189` (ports 6817, 6818, 60001:60100) since it's outside the main subnet.

### 3.5 Worker — `WSAI-03` (old, CPU-only — being decommissioned)

- **IP:** `10.24.6.58`
- **Hardware:** Supermicro SYS-2028GR-TR, dual Xeon E5-2640 v3, 32 CPUs, 62000 MB RAM, no GPU
- **Status:** ⚠️ Scheduled for removal — see [§8 Known Issues](#8-known-issues--in-progress-work).

### 3.6 Incoming Worker — DGX-1 (`rbcdsaidgx`)

- Formerly Ansible-managed as a standalone box under `rbcdsai.org` / `cluster.local`
- Slurm/Munge configs wiped; NVIDIA/CUDA drivers preserved
- **Next steps:** munge key sync → slurmd config → `NodeName` registration in `slurm.conf`

---

## 4. Networking

- **Cluster subnet:** `10.24.6.0/24` (primary). One GPU worker (`WSAI-03` new) lives on `10.17.66.0/24` and needs explicit routing/firewall exceptions.
- **NAS:** `10.24.6.62` — serves NFS exports for `/home` and `/storage`.
- **UFW (controller):**
  - `22/tcp` — SSH
  - `6817/tcp` (slurmctld) — open to `10.24.6.0/24` **and** anywhere (duplicate rule, cleanup candidate)
  - `6818/tcp` (slurmd)
  - `60001:60100/tcp` — Slurm `srun`/interactive job port range
  - `19999` — monitoring (Netdata)
  - Calico (`cali+`) interfaces allowed
  - Explicit rules added for `10.17.66.189` (off-subnet GPU worker)

---

## 5. Storage

| Mount | Source | Notes |
|---|---|---|
| `/home` | `10.24.6.62:/volume1/homes/WSAI_Cluster/wsai_home` | 10 TB, NFS `hard,timeo=60,retrans=5` |
| `/storage` | `10.24.6.62:/volume1/homes/WSAI_Cluster/wsai_storage` | 42 TB, same NFS options |

Home directories are **nested by role**, not flat: `/home/<role>/<username>` (e.g. `/home/students/alice`).

Quota (flat across all users): **100 GB soft / 115 GB hard**.

---

## 6. Slurm Configuration

- **Version:** 23.11.4, **configless mode** (`enable_configless`) — workers fetch `slurm.conf`/`gres.conf` from `slurmctld` at connect time; config only needs to be authored once on the controller.
- **Auth:** `AuthType=auth/munge`
- **Scheduling:** `SelectType=select/cons_tres`, `CR_Core_Memory`
- **Partition:** single partition `public` (Default=YES, all nodes, `MaxTime=2-00:00:00`, `OverSubscribe=NO`)
- **GPU defaults:** `DefMemPerGPU=11264`
- **Interactive jobs:** `SrunPortRange=60001-60100`
- **cgroup v2:** enforced — `ConstrainDevices`, `ConstrainRAMSpace`, `ConstrainCores=yes`
- **GRES detection:** `AutoDetect=nvml` does **not** work on Ubuntu (missing `gpu_nvml.so` in `slurm-wlm-plugins`). Use explicit `NodeName`-scoped `File=/dev/nvidiaN` entries in `gres.conf` instead, then `scontrol reconfigure` to flush slurmctld's in-memory copy.
- **Accounting:** `slurmdbd` on `WSAI-CLUSTER:6819` + MariaDB backend.

---

## 7. User & Role Management

Roles: **professors**, **students**, **interns**, **phdscholars**.

| Role | GID | Sudo | Expiry | QOS | Home path |
|---|---|---|---|---|---|
| Professors | 4010 | **NOPASSWD sudo only** for whitelisted `wsai-project-{create,add,remove,list}` commands (`Cmnd_Alias WSAI_PROJ`) — no general sudo, no apt, no shell escalation | None | `gpu8` | `/home/professors/<user>` |
| Students | 4011 | **No sudo** | 3 years | `gpu6` | `/home/students/<user>` |
| Interns | 4012 | **No sudo** | 6 months | `gpu4` | `/home/interns/<user>` |
| PhD Scholars | — | — | — | — | — |

> **Correction (July 2026):** No role has general sudo access. Any earlier documentation suggesting students had `apt install/update` access or professors had broad sudo is outdated and being retrofitted on the live server.

Provisioning is enforced two ways (both required): **Linux groups** + **Slurm account associations**.

Provisioning scripts (`user-c.sh`, `user-d.sh`, `hpc_user_manager.sh`) handle:
- Nested home directory creation
- SSH key setup
- `passwd`/`shadow`/`group` sync to all worker nodes
- `logs/` directory creation on workers
- Auto-generated per-user `README.md`
- Sudoers install via `visudo -cf` validation before activation

---

## 8. Known Issues / In-Progress Work

| # | Node | Issue | Fix / Status |
|---|---|---|---|
| 1 | Controller | Stray `slurmd.service` failing — `_find_node_record: lookup failure for node WSAI-03` | Investigate why controller is running slurmd or misreporting hostname as WSAI-03 |
| 2 | WSAI-02 | Stray `slurmctld.service` enabled and failing (`mkdir /var/spool/slurm/slurmctld: Permission denied`) | Disable — slurmctld should only run on controller |
| 3 | WSAI-03 (old, 10.24.6.58) | Marked for removal | Remove `NodeName=WSAI-03` from `slurm.conf`, drop from `public` partition `Nodes=` list, remove `/etc/hosts` entry, clean UFW + NFS scoping |
| 4 | All workers | Sudoers drift — workers previously granted broader access than controller policy | Standardize per §7 role table |
| 5 | All nodes | SSH config conflicts — `X11Forwarding` yes/no across main config + drop-ins; `PermitRootLogin yes` on workers vs `prohibit-password` on controller | Align to controller policy |
| 6 | Controller | Duplicate UFW rule — `6817/tcp` open to both `10.24.6.0/24` and `anywhere` | Remove the "anywhere" rule |
| 7 | WSAI-02 | Stray/malformed `/etc/hosts` entries | Clean up |
| 8 | DGX-1 (`rbcdsaidgx`) | Being onboarded | munge key sync → slurmd config → `NodeName` registration |

---

## 9. Monitoring & Reporting

- **Monthly utilization report:** `wsai_utilization.sh` — collects per-user session hours (`last`/wtmp) and CPU/GPU hours (`sacct`), renders a Chart.js HTML dashboard to `/var/www/html/utilization/` (with `latest.html` symlink). Supports `--multi` (SSH-based multi-server) and `--setup-cron`. Cron fires 23:30 on the last day of each month.
- **Netdata:** exposed on port `19999`.

---

## 10. Quick Reference Commands

```bash
# Cluster/node status
sinfo
squeue
scontrol show node <name>

# Reload config after gres.conf / slurm.conf changes (configless mode)
scontrol reconfigure

# GPU isolation sanity check
srun --gres=gpu:1 nvidia-smi

# Munge sanity check (run on worker, verify against controller)
munge -n | unmunge

# Ansible (from 10.17.66.241, WSAI cluster controller for automation)
ansible-playbook -i /etc/ansible/wsai-cluster/inventory site.yml --check   # dry run
ansible-playbook -i /etc/ansible/wsai-cluster/inventory site.yml --limit gpu_workers --serial 1
```

---

## 11. Related Infrastructure (Not Part of Core Cluster)

- **`rbcdsaidgx`** — standalone DGX-1, currently being merged into WSAI (see §3.6)
- **`e2e-73-93`** — standalone e2e Cloud A100 80GB node, single-node Slurm (`AuthType=auth/none`, no munge), not federated with WSAI

---

*Maintained by the WSAI cluster admin team. Update this file whenever node inventory, network config, or role policy changes — it is the single source of truth for onboarding new admins and users.*