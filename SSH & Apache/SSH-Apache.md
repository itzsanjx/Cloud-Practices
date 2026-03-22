# 🚀 SSH + Apache2 Setup on Ubuntu

## 📌 Overview

This guide installs:

* OpenSSH Server (remote access)
* Apache2 (web server)

---

# 🖥️ 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
```

---

# 🔐 2. Install OpenSSH Server

```bash
sudo apt install openssh-server -y
```

---

# 🚀 3. Start SSH

```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

---

# 🌐 4. Install Apache2

```bash
sudo apt install apache2 -y
```

---

# 🚀 5. Start Apache2

```bash
sudo systemctl start apache2
sudo systemctl enable apache2
```

---

# 🔥 6. Allow Firewall Rules

```bash
sudo ufw allow ssh
sudo ufw allow 'Apache Full'
sudo ufw enable
```

---

# 🌍 7. Test Apache

Open browser:

```
http://<your-server-ip>
```

👉 You should see Apache default page.

---

# 🔑 8. Test SSH Connection

From another system:

```bash
ssh username@server-ip
```

---

# 🔍 9. Check Status

```bash
sudo systemctl status ssh
sudo systemctl status apache2
```

---

# 🔐 10. Secure SSH (Optional)

```bash
sudo nano /etc/ssh/sshd_config
```

Recommended changes:

```
PermitRootLogin no
PasswordAuthentication no
```

Restart:

```bash
sudo systemctl restart ssh
```

---

# 📁 11. Apache Web Root

Default directory:

```
/var/www/html
```

Edit:

```bash
sudo nano /var/www/html/index.html
```

---

# 📡 12. Get Server IP

```bash
hostname -I
```
---

# ✅ Done!

