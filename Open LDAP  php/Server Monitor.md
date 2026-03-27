Netdata is accessed through the **browser** on port `19999`. Here's everything:

---

## Step 1 — Check if netdata is running

```bash
sudo systemctl status netdata
```

If not running, start it:
```bash
sudo systemctl start netdata
sudo systemctl enable netdata
```

---

## Step 2 — Open in browser

Type this in your browser:
```
http://<server-ip>:19999
```

For eg:
```
http://10.17.66.241:19999
```

---

## Step 3 — Open firewall port (if blocked)

```bash
# Check firewall status
sudo ufw status

# Allow netdata port
sudo ufw allow 19999/tcp

# Reload firewall
sudo ufw reload

# Verify
sudo ufw status
```
---
**IT Will Capture the live Usage Of the system**
---

## What we see in the dashboard

| Section | What it shows |
|---|---|
| **System overview | CPU, RAM, disk, network live graphs** |
| Processes | Every running process with CPU and memory |
| Apache | Web requests, connections, bandwidth |
| Disk I/O | Read/write speed per disk |
| Network | Traffic per interface |
| **Users | Who is logged in** |
| Syslog | System log events |

---

## Netdata config file location

```bash
# Main config
sudo nano /etc/netdata/netdata.conf

# Change port if needed (default 19999)
[web]
    default port = 19999

# Restart after any config change
sudo systemctl restart netdata
```

---

## Summary

| Step | Command / URL |
|---|---|
| Start service | `sudo systemctl start netdata` |
| Check status | `sudo systemctl status netdata` |
| Open dashboard | `http://server-ip:19999` |
| Allow firewall | `sudo ufw allow 19999/tcp` |
| Check port open | `sudo ss -tlnp | grep 19999` |

Just open `http://server-ip:19999` in any browser on your network and the live dashboard loads immediately — no login required by default.