# Jenkins Installation on Ubuntu

This guide explains how to install Jenkins on Ubuntu step by step.

---

# Prerequisites

- Ubuntu Server/Desktop (20.04 / 22.04 / 24.04)
- Sudo access
- Internet connection

---

# Step 1 — Update Ubuntu Packages

Update the package list:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Step 2 — Install Java

Jenkins requires Java.

Install OpenJDK 21:

```bash
sudo apt install -y fontconfig openjdk-21-jre
```

Verify Java installation:

```bash
java -version
```

Example output:

```bash
openjdk version "21"
```

---

# Step 3 — Add Jenkins Repository Key

Create keyring directory:

```bash
sudo mkdir -p /etc/apt/keyrings
```

Download Jenkins GPG key:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

---

# Step 4 — Add Jenkins Repository

Add Jenkins repository to Ubuntu sources:

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

---

# Step 5 — Update Package List Again

```bash
sudo apt update
```

---

# Step 6 — Install Jenkins

Install Jenkins:

```bash
sudo apt install -y jenkins
```

---

# Step 7 — Start Jenkins Service

Enable Jenkins service:

```bash
sudo systemctl enable jenkins
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

Check Jenkins status:

```bash
sudo systemctl status jenkins
```

Expected output:

```bash
active (running)
```

Press:

```bash
q
```

to exit the status screen.

---

# Step 8 — Allow Firewall Port (Optional)

If UFW firewall is enabled:

```bash
sudo ufw allow 8080
sudo ufw reload
```

If you see:

```bash
Firewall not enabled (skipping reload)
```

it means UFW is disabled, which is normal.

---

# Step 9 — Get Jenkins Initial Admin Password

Run:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password displayed in terminal.

Example:

```bash
3f5d7c8e9a1234567890abcdef
```

---

# Step 10 — Open Jenkins in Browser

Open:

```text
http://YOUR_SERVER_IP:8080
```

Example:

```text
http://192.168.1.10:8080
```

Paste the admin password.

---

# Step 11 — Install Suggested Plugins

After login:

- Click **Install suggested plugins**
- Wait for installation to complete

---

# Step 12 — Create Admin User

Fill:

- Username
- Password
- Full Name
- Email Address

Click:

```text
Save and Continue
```

---

# Step 13 — Jenkins Dashboard

Jenkins is now ready.

Dashboard URL:

```text
http://YOUR_SERVER_IP:8080
```

---

# Useful Jenkins Commands

## Check Status

```bash
sudo systemctl status jenkins
```

## Restart Jenkins

```bash
sudo systemctl restart jenkins
```

## Stop Jenkins

```bash
sudo systemctl stop jenkins
```

## Start Jenkins

```bash
sudo systemctl start jenkins
```

---

# Jenkins Log Commands

View recent logs:

```bash
sudo journalctl -u jenkins -n 50 --no-pager
```

Live logs:

```bash
sudo journalctl -u jenkins -f
```

---

# Default Jenkins Paths

| Item | Path |
|------|------|
| Jenkins Home | `/var/lib/jenkins` |
| Config File | `/etc/default/jenkins` |
| Logs | `/var/log/jenkins/jenkins.log` |

---

# Common Issues

## Jenkins Not Starting

Check logs:

```bash
sudo journalctl -u jenkins -xe
```

---

## Port 8080 Already in Use

Check:

```bash
sudo lsof -i :8080
```

Kill process if needed:

```bash
sudo kill -9 PID
```

---

# Uninstall Jenkins

```bash
sudo systemctl stop jenkins
sudo apt remove --purge -y jenkins
sudo rm -rf /var/lib/jenkins
```

---

# Official Documentation

- https://www.jenkins.io/doc/
- https://pkg.jenkins.io/

---

# Author

Jenkins Ubuntu Installation Guide