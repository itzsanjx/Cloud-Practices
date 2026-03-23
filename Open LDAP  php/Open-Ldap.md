🚀 OpenLDAP Full Setup with Web UI (phpLDAPadmin) on Ubuntu
---

---
Title: OpenLDAP Setup Guide (fiber / fiberorg)
---

# 📘 OpenLDAP Full Setup Guide

This guide provides a **complete step-by-step OpenLDAP setup** with phpLDAPadmin for web access using:

- **DNS Domain:** `fiber`
- **Organization:** `fiberorg`
- **Base DN:** `dc=fiber`

> ⚠️ Single-label domain, suitable for lab/testing. For production, consider `dc=fiber,dc=local` or `dc=fiber,dc=com`.

---

## 📑 Table of Contents

1. [Install OpenLDAP](#install-openldap)  
2. [Verify LDAP](#verify-ldap)  
3. [Create Base OUs](#create-base-ous)  
4. [Create User](#create-user)  
5. [Create Group](#create-group)  
6. [Install phpLDAPadmin](#install-phpldapadmin)  
7. [Configure phpLDAPadmin](#configure-phpldapadmin)  
8. [Enable Web Access](#enable-web-access)  
9. [Access Web UI](#access-web-ui)  
10. [Test Login](#test-login)  
11. [Notes & Recommendations](#notes--recommendations)  
12. [Final Result](#final-result)

---
## 📌 Overview

This guide installs and configures:

* OpenLDAP (slapd)
* phpLDAPadmin (web UI)
* Base structure (OU)
* Users & groups

---

# 🖥️ . Update System

```bash
sudo apt update && sudo apt upgrade -y
```
---

## 1️⃣ Install OpenLDAP

```bash
sudo apt update
sudo apt install slapd ldap-utils -y
sudo dpkg-reconfigure slapd
````

**Configuration values:**

* Omit config → No
* DNS domain → fiber
* Organization → fiberorg
* Admin password → your chosen password
* Database → MDB
* Remove database on purge → No
* Move old database → Yes

---

## 2️⃣ Verify LDAP

```bash
ldapsearch -x -LLL -H ldap:/// -b dc=fiber
```

---

## 3️⃣ Create Base OUs

Create `base.ldif`:

```ldif
dn: ou=people,dc=fiber
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=fiber
objectClass: organizationalUnit
ou: groups
```

Add to LDAP:

```bash
ldapadd -x -D cn=admin,dc=fiber -W -f base.ldif
```

---

## 4️⃣ Create User

Generate password hash:

```bash
slappasswd
```

Create `user.ldif`:

```ldif
dn: uid=john,ou=people,dc=fiber
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: John Doe
sn: Doe
uid: john
uidNumber: 10000
gidNumber: 10000
homeDirectory: /home/john
loginShell: /bin/bash
userPassword: {SSHA}PASTE_HASH
```

Add user:

```bash
ldapadd -x -D cn=admin,dc=fiber -W -f user.ldif
```

---

## 5️⃣ Create Group

Create `group.ldif`:

```ldif
dn: cn=developers,ou=groups,dc=fiber
objectClass: posixGroup
cn: developers
gidNumber: 10000
memberUid: john
```

Add group:

```bash
ldapadd -x -D cn=admin,dc=fiber -W -f group.ldif
```

---

## 6️⃣ Install phpLDAPadmin

```bash
sudo apt install phpldapadmin -y
```

---

## 7️⃣ Configure phpLDAPadmin

Edit `/etc/phpldapadmin/config.php`:

```php
$servers->setValue('server','host','127.0.0.1');
$servers->setValue('server','base',array('dc=fiber'));
$servers->setValue('login','bind_id','cn=admin,dc=fiber');

# Optional: allow user login with username
$servers->setValue('login','bind_dn_template','uid=%s,ou=people,dc=fiber');
```

> This allows users like `john` to log in with just their username.

---

## 8️⃣ Enable Web Access

Edit Apache config:

```bash
sudo nano /etc/apache2/conf-enabled/phpldapadmin.conf
```

Change:

```apache
Require local
```

To:

```apache
Require all granted
```

Restart Apache:

```bash
sudo systemctl restart apache2
```

---

## 9️⃣ Access Web UI

Open browser:

```
http://YOUR_SERVER_IP/phpldapadmin
```

Login:

* DN: `cn=admin,dc=fiber`
* Password: admin password

> Optional: if `bind_dn_template` is enabled, users can login with username (`john`).

---

## 10️⃣ Test Login

```bash
ldapwhoami -x -D cn=admin,dc=fiber -W
```

---

## 11️⃣ Notes & Recommendations

* Single-label domain (`dc=fiber`) is fine for lab/testing
* Production recommended format:

  ```text
  dc=fiber,dc=local
  ```

  or

  ```text
  dc=fiber,dc=com
  ```

---

## 12️⃣ Final Result

* OpenLDAP server running
* Base DN: `dc=fiber`
* Admin: `cn=admin,dc=fiber`
* Web interface: phpLDAPadmin working
* Test user: `john`
* Group: `developers`

---

# ✅ Done!
