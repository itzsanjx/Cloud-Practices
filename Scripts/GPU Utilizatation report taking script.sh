#!/bin/bash
# ============================================================
#  GPU Job Utilization Report Generator
#  Sources (auto-detected):
#    1. SLURM sacct         — job scheduler accounting
#    2. PBS/Torque qstat    — job scheduler accounting
#    3. SGE qacct           — grid engine accounting
#    4. nvidia-smi accounting — per-process GPU time
#    5. /proc + nvidia-smi  — live process owner mapping
#    6. bash_history        — GPU command history per user
#    7. audit logs          — execve of GPU binaries
#  Output: bar chart PNG at /root/gpu_report_<host>_<range>.png
#  Usage:  sudo bash gpu_utilization_report.sh [--debug]
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

OUTPUT_DIR="/root"
HOSTNAME_SHORT=$(hostname -s)
WORK_DIR=$(mktemp -d /tmp/gpu_util_XXXX)
SESSIONS_FILE="${WORK_DIR}/sessions.csv"   # user,start_ts,end_ts,source,gpu_mins
DATA_FILE="${WORK_DIR}/data.csv"
PY_DIR="${WORK_DIR}/py"
mkdir -p "$PY_DIR"

START_TS=0; END_TS=0; START_DATE=""; END_DATE=""
DEBUG_MODE=0
[[ "${1:-}" == "--debug" ]] && DEBUG_MODE=1

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

# ── Dependencies ─────────────────────────────────────────────
check_dependencies() {
    echo -e "${CYAN}[*] Checking dependencies...${NC}"
    local missing=()
    command -v python3 &>/dev/null || missing+=("python3")
    python3 -c "import matplotlib,numpy" 2>/dev/null \
        || missing+=("matplotlib+numpy → pip3 install matplotlib numpy")
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing: ${missing[*]}${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] OK${NC}"
}

# ── Date input ───────────────────────────────────────────────
get_date_range() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     GPU Job Utilization Report Generator         ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    while true; do
        echo -en "${YELLOW}Enter START date (YYYY-MM-DD): ${NC}"
        read -r START_DATE
        [[ "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
            && date -d "$START_DATE" &>/dev/null 2>&1 && break
        echo -e "${RED}[!] Invalid. Use YYYY-MM-DD${NC}"
    done
    while true; do
        echo -en "${YELLOW}Enter END   date (YYYY-MM-DD): ${NC}"
        read -r END_DATE
        if [[ "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
            && date -d "$END_DATE" &>/dev/null 2>&1; then
            [[ "$END_DATE" < "$START_DATE" ]] \
                && { echo -e "${RED}[!] End must be >= start${NC}"; continue; }
            break
        fi
        echo -e "${RED}[!] Invalid. Use YYYY-MM-DD${NC}"
    done
    START_TS=$(date -d "${START_DATE} 00:00:00" +%s)
    END_TS=$(date   -d "${END_DATE}   23:59:59" +%s)
    echo -e "\n${GREEN}[✓] Range: ${START_DATE} → ${END_DATE}${NC}\n"
}

# ================================================================
# Write all Python scripts to files
# ================================================================
write_python_scripts() {

# ── SOURCE 1: SLURM sacct ────────────────────────────────────
cat > "${PY_DIR}/src_slurm.py" << 'PYEOF'
#!/usr/bin/env python3
"""Pull GPU job data from SLURM sacct."""
import subprocess, sys, csv, os
from datetime import datetime

sessions_file = sys.argv[1]
start_date    = sys.argv[2]   # YYYY-MM-DD
end_date      = sys.argv[3]

if not any(os.path.exists(p) for p in ['/usr/bin/sacct','/usr/local/bin/sacct']):
    print("  [skip] SLURM sacct not found")
    sys.exit(0)

print("  [SLURM] Querying sacct...")
try:
    result = subprocess.run([
        'sacct',
        '--starttime', start_date,
        '--endtime',   end_date,
        '--format', 'User,JobID,Start,End,ElapsedRaw,AllocTRES,State',
        '--parsable2', '--noheader', '--allusers'
    ], capture_output=True, text=True, timeout=30)
except Exception as e:
    print(f"  [SLURM] sacct error: {e}")
    sys.exit(0)

count = 0
with open(sessions_file, 'a') as out:
    for line in result.stdout.splitlines():
        parts = line.strip().split('|')
        if len(parts) < 6: continue
        user, jobid, start, end, elapsed_raw, alloc_tres = parts[:6]
        user = user.strip()
        if not user or user in ('root','','Unknown'): continue

        # Only count jobs that used GPU
        if 'gres/gpu' not in alloc_tres and 'gpu' not in alloc_tres.lower():
            continue

        try:
            start_ts = int(datetime.strptime(start[:19], '%Y-%m-%dT%H:%M:%S').timestamp())
            end_ts   = int(datetime.strptime(end[:19],   '%Y-%m-%dT%H:%M:%S').timestamp()) \
                       if end.strip() not in ('Unknown','None','') else int(__import__('time').time())
            elapsed  = int(elapsed_raw) if elapsed_raw.isdigit() else 0
            # Extract GPU count from TRES
            import re
            gpu_match = re.search(r'gres/gpu=(\d+)', alloc_tres)
            n_gpus = int(gpu_match.group(1)) if gpu_match else 1
            gpu_mins = (elapsed * n_gpus) // 60
            out.write(f"{user},{start_ts},{end_ts},{gpu_mins},slurm\n")
            count += 1
        except Exception:
            continue

print(f"  [SLURM] {count} GPU jobs found")
PYEOF

# ── SOURCE 2: PBS/Torque ─────────────────────────────────────
cat > "${PY_DIR}/src_pbs.py" << 'PYEOF'
#!/usr/bin/env python3
"""Pull GPU job data from PBS/Torque accounting logs."""
import sys, os, glob, re
from datetime import datetime

sessions_file = sys.argv[1]
start_ts      = int(sys.argv[2])
end_ts        = int(sys.argv[3])

pbs_log_dirs = ['/var/spool/pbs/server_priv/accounting',
                '/var/spool/torque/server_priv/accounting',
                '/var/lib/pbs/server_priv/accounting']

log_dir = next((d for d in pbs_log_dirs if os.path.isdir(d)), None)
if not log_dir:
    print("  [skip] PBS/Torque accounting logs not found")
    sys.exit(0)

print(f"  [PBS] Reading {log_dir}...")
count = 0
re_gpu = re.compile(r'ngpus=(\d+)|gpu')

with open(sessions_file, 'a') as out:
    for logfile in sorted(glob.glob(f"{log_dir}/*")):
        try:
            with open(logfile) as f:
                for line in f:
                    # Format: MM/DD/YYYY HH:MM:SS;E;jobid;user=X ...
                    parts = line.strip().split(';')
                    if len(parts) < 4 or parts[1] != 'E': continue
                    attrs = dict(kv.split('=',1) for kv in parts[3].split(' ')
                                 if '=' in kv)
                    user = attrs.get('user','')
                    if not user: continue
                    resources = attrs.get('resources_used','') + attrs.get('Resource_List.nodes','')
                    if not re_gpu.search(resources): continue
                    try:
                        ts = int(datetime.strptime(parts[0], '%m/%d/%Y %H:%M:%S').timestamp())
                        walltime = attrs.get('resources_used.walltime','0:0:0').split(':')
                        secs = int(walltime[0])*3600 + int(walltime[1])*60 + int(walltime[2])
                        gpu_match = re_gpu.search(resources)
                        n_gpus = int(gpu_match.group(1)) if gpu_match and gpu_match.group(1) else 1
                        gpu_mins = (secs * n_gpus) // 60
                        start = ts - secs
                        if max(start, start_ts) < min(ts, end_ts):
                            out.write(f"{user},{max(start,start_ts)},{min(ts,end_ts)},{gpu_mins},pbs\n")
                            count += 1
                    except: continue
        except: continue

print(f"  [PBS] {count} GPU jobs found")
PYEOF

# ── SOURCE 3: SGE/GridEngine ─────────────────────────────────
cat > "${PY_DIR}/src_sge.py" << 'PYEOF'
#!/usr/bin/env python3
"""Pull GPU job data from SGE/GridEngine qacct."""
import subprocess, sys, os, re, time
from datetime import datetime

sessions_file = sys.argv[1]
start_date    = sys.argv[2]
end_date      = sys.argv[3]

if not any(os.path.exists(p) for p in ['/usr/bin/qacct','/opt/sge/bin/qacct']):
    print("  [skip] SGE qacct not found")
    sys.exit(0)

print("  [SGE] Querying qacct...")
try:
    result = subprocess.run(
        ['qacct', '-j', '*', '-b', start_date.replace('-',''), '-e', end_date.replace('-','')],
        capture_output=True, text=True, timeout=60
    )
except Exception as e:
    print(f"  [SGE] qacct error: {e}"); sys.exit(0)

count   = 0
job     = {}
with open(sessions_file, 'a') as out:
    for line in result.stdout.splitlines():
        line = line.strip()
        if line.startswith('===='):
            job = {}; continue
        if ' ' not in line: continue
        key, _, val = line.partition(' ')
        job[key.strip()] = val.strip()

        if key.strip() == 'end_time' and job:
            user = job.get('owner','')
            if not user: continue
            # Check GPU resource
            res = job.get('granted_pe','') + job.get('hard resource_list','')
            if 'gpu' not in res.lower(): continue
            try:
                start_ts_j = int(datetime.strptime(
                    job.get('start_time',''), '%a %b %d %H:%M:%S %Y').timestamp())
                end_ts_j   = int(datetime.strptime(
                    job.get('end_time',''),   '%a %b %d %H:%M:%S %Y').timestamp())
                secs = end_ts_j - start_ts_j
                gpu_mins = secs // 60
                out.write(f"{user},{start_ts_j},{end_ts_j},{gpu_mins},sge\n")
                count += 1
            except: pass

print(f"  [SGE] {count} GPU jobs found")
PYEOF

# ── SOURCE 4: nvidia-smi accounting ──────────────────────────
cat > "${PY_DIR}/src_nvidia_acct.py" << 'PYEOF'
#!/usr/bin/env python3
"""Pull data from nvidia-smi GPU accounting mode.
   Also maps PIDs → users via /proc if accounting is live."""
import subprocess, sys, os, pwd, time, re
from datetime import datetime

sessions_file = sys.argv[1]
start_ts      = int(sys.argv[2])
end_ts        = int(sys.argv[3])

def run(cmd):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return r.stdout.strip()
    except: return ''

# Check nvidia-smi available
if not run(['which','nvidia-smi']):
    print("  [skip] nvidia-smi not found")
    sys.exit(0)

# Enable accounting if not already on
acct_status = run(['nvidia-smi', '--query', '--display=ACCOUNTING'])
if 'Disabled' in acct_status:
    print("  [nvidia] Accounting disabled — enabling now (future jobs will be tracked)")
    run(['nvidia-smi', '-am', '1'])   # enable accounting mode

# Query accounted processes
print("  [nvidia] Querying accounted GPU processes...")
out_lines = run([
    'nvidia-smi','--query-accounted-apps',
    'gpu_uuid,pid,time,used_memory',
    '--format=csv,noheader,nounits'
]).splitlines()

# Also get current compute processes
current_lines = run([
    'nvidia-smi','--query-compute-apps',
    'pid,used_gpu_memory,gpu_uuid',
    '--format=csv,noheader,nounits'
]).splitlines()

def pid_to_user(pid):
    try:
        with open(f'/proc/{pid}/status') as f:
            for line in f:
                if line.startswith('Uid:'):
                    uid = int(line.split()[1])
                    return pwd.getpwuid(uid).pw_name
    except: pass
    # Try loginuid
    try:
        with open(f'/proc/{pid}/loginuid') as f:
            uid = int(f.read().strip())
            if uid < 65534:
                return pwd.getpwuid(uid).pw_name
    except: pass
    return None

count = 0
now_ts = int(time.time())

with open(sessions_file, 'a') as out:
    # Accounted (historical)
    for line in out_lines:
        parts = [p.strip() for p in line.split(',')]
        if len(parts) < 3: continue
        gpu_uuid, pid, gpu_time_ms = parts[0], parts[1], parts[2]
        try:
            gpu_secs = int(gpu_time_ms) // 1000
            user = pid_to_user(pid)
            if not user: continue
            gpu_mins = gpu_secs // 60
            # We don't know exact start — use now as end
            est_start = now_ts - gpu_secs
            eff_s = max(est_start, start_ts)
            eff_e = min(now_ts,    end_ts)
            if eff_e > eff_s:
                out.write(f"{user},{eff_s},{eff_e},{gpu_mins},nvidia_acct\n")
                count += 1
        except: continue

    # Current running processes
    for line in current_lines:
        parts = [p.strip() for p in line.split(',')]
        if len(parts) < 1: continue
        pid = parts[0]
        user = pid_to_user(pid)
        if not user: continue
        # Get process start time from /proc
        try:
            with open(f'/proc/{pid}/stat') as f:
                stat = f.read().split()
            clk = os.sysconf('SC_CLK_TCK')
            uptime = float(open('/proc/uptime').read().split()[0])
            starttime_ticks = int(stat[21])
            proc_start = int(now_ts - uptime + starttime_ticks / clk)
            eff_s = max(proc_start, start_ts)
            eff_e = min(now_ts,     end_ts)
            if eff_e > eff_s:
                gpu_mins = (eff_e - eff_s) // 60
                out.write(f"{user},{eff_s},{eff_e},{gpu_mins},nvidia_live\n")
                count += 1
        except: continue

print(f"  [nvidia] {count} GPU process records found")
PYEOF

# ── SOURCE 5: bash_history GPU commands ──────────────────────
cat > "${PY_DIR}/src_history.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Scan bash/zsh history files for GPU job commands.
Counts command invocations per user as a proxy for job runs.
Each GPU command invocation = 1 job unit (shown as count, not time).
"""
import sys, os, re, glob, pwd, stat
from datetime import datetime

sessions_file = sys.argv[1]
start_ts      = int(sys.argv[2])
end_ts        = int(sys.argv[3])

# GPU-related command patterns
GPU_PATTERNS = re.compile(
    r'\b(python3?|python\S*|torch|torchrun|deepspeed|accelerate|'
    r'nvcc|nsys|ncu|nvidia-smi|gpustat|nvitop|'
    r'tensorflow|keras|jax|paddle|mxnet|'
    r'jupyter|ipython|'
    r'train\.py|main\.py|run\.py|finetune\.py|pretrain\.py|'
    r'sbatch|qsub|bsub)\b',
    re.IGNORECASE
)

# Timestamp line in zsh history: ": 1234567890:0;command"
RE_ZSH_TS = re.compile(r'^:\s*(\d{10,})\s*:\d+;(.+)')

def get_human_users():
    users = []
    with open('/etc/passwd') as f:
        for line in f:
            p = line.strip().split(':')
            if len(p) >= 7:
                try:
                    uid = int(p[2])
                    if 1000 <= uid < 60000:
                        users.append((p[0], p[5]))  # (username, homedir)
                except: pass
    return users

count_users = 0
total_cmds  = 0

with open(sessions_file, 'a') as out:
    for username, homedir in get_human_users():
        history_files = []
        for hf in ['.bash_history', '.zsh_history', '.python_history',
                   '.local/share/fish/fish_history']:
            path = os.path.join(homedir, hf)
            if os.path.isfile(path):
                history_files.append(path)

        user_cmds = 0
        for hpath in history_files:
            try:
                # Get file modification time as rough timestamp anchor
                mtime = os.path.getmtime(hpath)
                with open(hpath, 'rb') as f:
                    raw = f.read()

                try:
                    text = raw.decode('utf-8', errors='replace')
                except:
                    text = raw.decode('latin-1', errors='replace')

                lines = text.splitlines()
                last_ts = None

                for line in lines:
                    line = line.strip()
                    if not line: continue

                    # zsh history with timestamp
                    m = RE_ZSH_TS.match(line)
                    if m:
                        last_ts = int(m.group(1))
                        cmd = m.group(2)
                    else:
                        cmd = line
                        last_ts = None

                    if not GPU_PATTERNS.search(cmd):
                        continue

                    # Use timestamp if available, else skip time-filtering
                    if last_ts is not None:
                        if not (start_ts <= last_ts <= end_ts):
                            continue
                        eff_s = last_ts
                        eff_e = last_ts + 3600  # assume 1hr job if no duration
                    else:
                        # No timestamp — include all (can't filter by date)
                        eff_s = start_ts
                        eff_e = end_ts

                    out.write(f"{username},{eff_s},{eff_e},60,history\n")
                    user_cmds += 1

            except Exception as e:
                continue

        if user_cmds > 0:
            count_users += 1
            total_cmds  += user_cmds

print(f"  [history] {total_cmds} GPU commands found across {count_users} users")
PYEOF

# ── AGGREGATOR ───────────────────────────────────────────────
cat > "${PY_DIR}/aggregate.py" << 'PYEOF'
#!/usr/bin/env python3
"""Aggregate sessions → per-user GPU minutes."""
import sys
from collections import defaultdict

sessions_file = sys.argv[1]
data_file     = sys.argv[2]

# All local human users
users = []
with open('/etc/passwd') as f:
    for line in f:
        p = line.strip().split(':')
        if len(p) >= 3:
            try:
                if 1000 <= int(p[2]) < 60000:
                    users.append(p[0])
            except: pass
users = sorted(set(users))

totals   = defaultdict(int)
sources  = defaultdict(set)
row_count = 0

with open(sessions_file) as f:
    for line in f:
        line = line.strip()
        if not line: continue
        parts = line.split(',')
        if len(parts) < 5: continue
        user, ls, le, gpu_mins, source = parts[0], parts[1], parts[2], parts[3], parts[4]
        try:
            totals[user]  += int(gpu_mins)
            sources[user].add(source)
            row_count += 1
        except: continue

print(f"  Total records: {row_count}")
print()

with open(data_file, 'w') as f:
    f.write("username,minutes,sources\n")
    for u in users:
        mins = totals.get(u, 0)
        src  = '+'.join(sorted(sources.get(u, set()))) or '-'
        f.write(f"{u},{mins},{src}\n")
        bar  = '█' * min(40, mins // 30)
        print(f"    {u:<22} {mins:>7} GPU-min  ({mins/60:5.1f} hrs)  [{src}]  {bar}")

if not any(totals.values()):
    print()
    print("  *** All users = 0 GPU minutes ***")
    print("  Possible reasons:")
    print("    - No job scheduler (SLURM/PBS/SGE) installed")
    print("    - nvidia-smi accounting not enabled (run: nvidia-smi -am 1)")
    print("    - bash_history has no timestamped GPU commands")
    print("  Run:  bash gpu_utilization_report.sh --debug")
PYEOF

# ── CHART ────────────────────────────────────────────────────
cat > "${PY_DIR}/chart.py" << 'PYEOF'
#!/usr/bin/env python3
"""Generate GPU utilization bar chart PNG."""
import sys, csv
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

data_file, out_png, start_date, end_date, hostname = sys.argv[1:6]

users, hours, srcs = [], [], []
with open(data_file) as f:
    for row in csv.DictReader(f):
        users.append(row['username'])
        hours.append(float(row['minutes']) / 60.0)
        srcs.append(row.get('sources', ''))

if not users:
    print("ERROR: No users"); sys.exit(1)

n         = len(users)
fig_width = max(14, n * 0.45)
fig, ax   = plt.subplots(figsize=(fig_width, 7.5))
fig.patch.set_facecolor('white')
ax.set_facecolor('white')

x = np.arange(n)
bars = ax.bar(x, hours, color='#4a90d9', width=0.55, zorder=3)

max_h = max(hours) if any(h > 0 for h in hours) else 10
step  = max(1, round(max_h / 6, -1)) if max_h > 10 else 5
ax.yaxis.set_major_locator(ticker.MultipleLocator(step))
ax.grid(axis='y', color='#e0e0e0', linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

ax.set_xticks(x)
ax.set_xticklabels(users, rotation=90, ha='center',
                   fontsize=7.5, fontfamily='DejaVu Sans')
ax.set_ylim(0, max(max_h * 1.22, 1))
ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.2f'))
ax.tick_params(axis='y', labelsize=9)

for sp in ('top','right'): ax.spines[sp].set_visible(False)
for sp in ('left','bottom'): ax.spines[sp].set_color('#cccccc')

ax.set_title(
    f"GPU Job Utilization Report — {hostname}\n"
    f"{start_date}  to  {end_date}  (GPU hours)",
    fontsize=11, fontweight='bold', pad=14, color='#333333'
)
ax.set_ylabel("GPU Hours", fontsize=9, color='#555555')

plt.tight_layout()
plt.savefig(out_png, dpi=150, bbox_inches='tight',
            facecolor='white', format='png')
plt.close()
print(f"Chart saved → {out_png}")
PYEOF

# ── DEBUG ────────────────────────────────────────────────────
cat > "${PY_DIR}/debug.py" << 'PYEOF'
#!/usr/bin/env python3
"""Detect all GPU job data sources on this server."""
import subprocess, os, glob, sys

def run(cmd, timeout=5):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return r.stdout.strip(), r.returncode
    except Exception as e:
        return str(e), -1

print("══════════════════════════════════════════════════")
print("  GPU Job Utilization — Source Detection")
print("══════════════════════════════════════════════════\n")

# GPU hardware
print("── GPU Hardware ────────────────────────────────")
out, rc = run(['nvidia-smi', '--query-gpu=name,uuid,memory.total',
               '--format=csv,noheader'])
if rc == 0:
    for line in out.splitlines():
        print(f"  GPU: {line}")
    # Check accounting mode
    out2, _ = run(['nvidia-smi', '--query-gpu=accounting.mode',
                   '--format=csv,noheader'])
    print(f"  Accounting mode: {out2}")
else:
    print("  nvidia-smi: NOT available")

# Job schedulers
print("\n── Job Schedulers ──────────────────────────────")
for name, cmd in [
    ('SLURM',      ['sacct','--version']),
    ('PBS/Torque', ['qstat','--version']),
    ('SGE',        ['qacct','-help']),
    ('LSF',        ['bjobs','-version']),
]:
    out, rc = run(cmd)
    status = "YES — " + out.splitlines()[0][:60] if rc == 0 else "NO"
    print(f"  {name:<14}: {status}")

# SLURM sample
print("\n── SLURM GPU Jobs (last 5) ─────────────────────")
out, rc = run(['sacct','--format','User,JobID,AllocTRES,ElapsedRaw,State',
               '--parsable2','--noheader','--allusers','-X'], timeout=10)
gpu_jobs = [l for l in out.splitlines() if 'gpu' in l.lower()]
for l in gpu_jobs[:5]: print(f"  {l}")
if not gpu_jobs: print("  (none or sacct unavailable)")

# PBS logs
print("\n── PBS/Torque Accounting Logs ──────────────────")
for d in ['/var/spool/pbs/server_priv/accounting',
          '/var/spool/torque/server_priv/accounting']:
    if os.path.isdir(d):
        files = sorted(glob.glob(f"{d}/*"))
        print(f"  Found: {d}  ({len(files)} log files)")
        for f in files[-3:]: print(f"    {f}")
    else:
        print(f"  {d}: not found")

# nvidia accounting
print("\n── nvidia-smi Accounted Processes ─────────────")
out, rc = run(['nvidia-smi','--query-accounted-apps',
               'pid,time,gpu_uuid','--format=csv,noheader'])
lines = out.splitlines()
for l in lines[:5]: print(f"  {l}")
if not lines: print("  (empty — accounting may be off or no past processes)")

# bash history
print("\n── bash_history GPU Commands ───────────────────")
import re
GPU_RE = re.compile(
    r'\b(python3?|torchrun|deepspeed|nvcc|nsys|ncu|sbatch|qsub|train\.py)\b',
    re.I)
with open('/etc/passwd') as f:
    for line in f:
        p = line.strip().split(':')
        if len(p) < 7: continue
        try:
            if not (1000 <= int(p[2]) < 60000): continue
        except: continue
        hist = os.path.join(p[5], '.bash_history')
        if not os.path.isfile(hist): continue
        try:
            with open(hist, errors='replace') as h:
                cmds = [l for l in h if GPU_RE.search(l)]
            print(f"  {p[0]:<20}: {len(cmds):>5} GPU-related history lines")
        except: pass

# Human users
print("\n── Human Users (UID 1000-59999) ────────────────")
with open('/etc/passwd') as f:
    for line in f:
        p = line.strip().split(':')
        if len(p) >= 3:
            try:
                if 1000 <= int(p[2]) < 60000:
                    print(f"  {p[0]} (uid={p[2]})")
            except: pass

print("\n══════════════════════════════════════════════════")
print("  Run without --debug to generate the report")
print("══════════════════════════════════════════════════")
PYEOF

}   # end write_python_scripts

# ── Debug mode ───────────────────────────────────────────────
run_debug() {
    write_python_scripts
    python3 "${PY_DIR}/debug.py"
    exit 0
}

# ── Main report ──────────────────────────────────────────────
generate_report() {
    write_python_scripts
    > "$SESSIONS_FILE"   # empty file, no header

    echo -e "${CYAN}[*] Collecting GPU job data from all sources...${NC}"
    echo ""

    # Run all sources — each appends to SESSIONS_FILE
    python3 "${PY_DIR}/src_slurm.py"        "$SESSIONS_FILE" "$START_DATE" "$END_DATE"
    python3 "${PY_DIR}/src_pbs.py"          "$SESSIONS_FILE" "$START_TS"   "$END_TS"
    python3 "${PY_DIR}/src_sge.py"          "$SESSIONS_FILE" "$START_DATE" "$END_DATE"
    python3 "${PY_DIR}/src_nvidia_acct.py"  "$SESSIONS_FILE" "$START_TS"   "$END_TS"
    python3 "${PY_DIR}/src_history.py"      "$SESSIONS_FILE" "$START_TS"   "$END_TS"

    echo ""
    local total_records
    total_records=$(wc -l < "$SESSIONS_FILE" 2>/dev/null || echo 0)
    echo -e "${GREEN}  Total GPU job records collected: ${total_records}${NC}"

    if [[ "$total_records" -eq 0 ]]; then
        echo -e "${RED}[!] No GPU job data found.${NC}"
        echo -e "${YELLOW}    Run:  bash gpu_utilization_report.sh --debug${NC}"
        echo -e "${YELLOW}    Then enable nvidia accounting:  nvidia-smi -am 1${NC}"
        exit 1
    fi

    echo ""
    echo -e "${CYAN}[*] Aggregating per-user GPU totals...${NC}"
    python3 "${PY_DIR}/aggregate.py" "$SESSIONS_FILE" "$DATA_FILE"

    echo ""
    echo -e "${CYAN}[*] Generating chart...${NC}"
    local out_png="${OUTPUT_DIR}/gpu_report_${HOSTNAME_SHORT}_${START_DATE}_to_${END_DATE}.png"
    python3 "${PY_DIR}/chart.py" \
        "$DATA_FILE" "$out_png" \
        "$START_DATE" "$END_DATE" "$HOSTNAME_SHORT"

    echo ""
    echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║  ✓  GPU Report saved:                                      ║${NC}"
    echo -e "${GREEN}${BOLD}║     ${out_png}${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ── Entry point ──────────────────────────────────────────────
check_dependencies
[[ $DEBUG_MODE -eq 1 ]] && run_debug
get_date_range
generate_report