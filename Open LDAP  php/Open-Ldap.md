# 🚀 OpenLDAP Full Setup with Web UI (phpLDAPadmin) on Ubuntu

## 📌 Overview

This guide installs and configures:

* OpenLDAP (slapd)
* phpLDAPadmin (web UI)
* Base structure (OU)
* Users & groups

---

# 🖥️ 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
```

---

# 📦 2. Install OpenLDAP

```bash
sudo apt install slapd ldap-utils -y
```

---

# ⚙️ 3. Configure OpenLDAP

```bash
sudo dpkg-reconfigure slapd
```

### Use these values:

```
Omit OpenLDAP config? → No
DNS domain name → example.com
Organization → Example Org
Admin password → admin123
Database → MDB
Remove DB when purged → No
Move old DB → Yes
```

👉 Your Base DN becomes:

```
dc=example,dc=com
```

---

# 🔍 4. Test LDAP

```bash
ldapsearch -x -LLL -H ldap:/// -b dc=example,dc=com
```

---

# 🌐 5. Install Web UI (phpLDAPadmin)

```bash
sudo apt install phpldapadmin -y
```

---

# ⚙️ 6. Configure phpLDAPadmin

```bash
sudo nano /etc/phpldapadmin/config.php
```

### Modify:

```php
$servers->setValue('server','host','127.0.0.1');
$servers->setValue('server','base',array('dc=example,dc=com'));
$servers->setValue('login','bind_id','cn=admin,dc=example,dc=com');
```

---

# 🌍 7. Enable Web Access

```bash
sudo nano /etc/apache2/conf-enabled/phpldapadmin.conf
```

### Change:

```
Require local
```

### To:

```
Require all granted
```

---

# 🔄 Restart Apache

```bash
sudo systemctl restart apache2
```

---

# 🌐 Access Web UI

```
http://<your-server-ip>/phpldapadmin
```

### Login:

```
Username: cn=admin,dc=example,dc=com
Password: admin123
```

---

# 📁 8. Create Base Structure

```bash
nano base.ldif
```

```ldif
dn: ou=users,dc=example,dc=com
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=example,dc=com
objectClass: organizationalUnit
ou: groups
```

### Apply:

```bash
ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f base.ldif
```

---

# 👥 9. Create LDAP Group

```bash
nano group.ldif
```

```ldif
dn: cn=devs,ou=groups,dc=example,dc=com
objectClass: posixGroup
cn: devs
gidNumber: 5000
```

### Apply:

```bash
ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f group.ldif
```

---

# 👤 10. Create LDAP User

## 🔐 Generate password hash

```bash
slappasswd
```

👉 Copy generated hash

---

```bash
nano user.ldif
```

```ldif
dn: uid=john,ou=users,dc=example,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: John Doe
sn: Doe
uid: john
uidNumber: 10000
gidNumber: 5000
homeDirectory: /home/john
loginShell: /bin/bash
userPassword: {SSHA}REPLACE_WITH_HASH
```

---

### Add user:

```bash
ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f user.ldif
```

---

# 🔍 11. Verify User

```bash
ldapsearch -x -LLL -b "ou=users,dc=example,dc=com"
`---

# 🔐 12. Enable Firewall (Optional)

```bash
sudo ufw allow 80
sudo ufw allow 389
sudo ufw enable
```

---

# 🧪 13. Test Login via LDAP

```bash
ldapwhoami -x -D "uid=john,ou=users,dc=example,dc=com" -W
```
---

# ✅ Done!

