
# Ubuntu SSH Setup Using Private Key

## Step 1 — Open Terminal

Open the Ubuntu terminal using:

```bash
Ctrl + Alt + T
```

---

## Step 2 — Create `.ssh` Directory

Create the SSH folder inside your home directory.

```bash
mkdir -p ~/.ssh
```

---

## Step 3 — Move Private Key to `.ssh`

Move your downloaded private key file into the `.ssh` folder.

Example:

```bash
mv ~/Downloads/mykey.pem ~/.ssh/
```

---

## Step 4 — Set Correct Permissions

SSH requires secure permissions for private keys.

```bash
chmod 400 ~/.ssh/mykey.pem
```

Verify permissions:

```bash
ls -l ~/.ssh/
```

Expected output:

```text
-r-------- mykey.pem
```

---

## Step 5 — Connect to Remote Machine

Use the SSH command to connect.

```bash
ssh -i ~/.ssh/mykey.pem ubuntu@YOUR_SERVER_IP
```

Example:

```bash
ssh -i ~/.ssh/mykey.pem ubuntu@34.xx.xx.xx
```

---

# Quick Copy Setup

```bash
mkdir -p ~/.ssh

mv ~/Downloads/mykey.pem ~/.ssh/

chmod 400 ~/.ssh/mykey.pem

ssh -i ~/.ssh/mykey.pem ubuntu@YOUR_SERVER_IP
```
---
# End of setup
