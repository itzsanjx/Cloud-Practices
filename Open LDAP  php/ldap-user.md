## Setup FIles and flow Chart for Understanding Roles And Permissions
```
# Overview of this
* **Admin** → full permissions
* **Faculty** → can manage (delete) student accounts
* **Student** → read-only + access cluster (run programs only)
```

---

# 🧱 1. Plan Your LDAP Structure

Since your base DN is:

```
dc=fiber
```

Create this hierarchy:

```
dc=fiber
 ├── ou=people
 │    ├── admin users
 │    ├── faculty users
 │    └── student users
 │
 └── ou=groups
      ├── admins
      ├── faculty
      └── students
```

---

# 📁 2. Create Organizational Units (OUs)

In **phpLDAPadmin**:

### Create:

* `ou=people`
* `ou=groups`

Then inside `ou=people`, create:

* `ou=admins`
* `ou=faculty`
* `ou=students`

---

# 👥 3. Create Users

Use objectClass:

```
inetOrgPerson
posixAccount
shadowAccount
```

---

### 👤 Admin User Example

```
uid=admin1
cn=Admin One
sn=Admin
uidNumber=10000
gidNumber=10000
homeDirectory=/home/admin1
loginShell=/bin/bash
```

---

### 👨‍🏫 Faculty User Example

```
uid=faculty1
cn=Faculty One
sn=Faculty
uidNumber=11000
gidNumber=11000
homeDirectory=/home/faculty1
```

---

### 🎓 Student User Example

```
uid=student1
cn=Student One
sn=Student
uidNumber=12000
gidNumber=12000
homeDirectory=/home/student1
```

---

# 👥 4. Create Groups (VERY IMPORTANT)

Go to `ou=groups`

Create groups using:

```
objectClass: posixGroup
```

---

### 🛡️ Admin Group

```
cn=admins
gidNumber=10000
memberUid=admin1
```

---

### 🧑‍🏫 Faculty Group

```
cn=faculty
gidNumber=11000
memberUid=faculty1
```

---

### 🎓 Student Group

```
cn=students
gidNumber=12000
memberUid=student1
```

---

# 🔐 5. Assign Permissions (ACLs)

Now the **core part: access control**

Edit your LDAP config (`slapd.conf` or `cn=config` depending on setup)

---

## 🛡️ Admin → Full Access

```
access to *
    by group.exact="cn=admins,ou=groups,dc=fiber" write
    by * read
```

---

## 👨‍🏫 Faculty → Manage Students Only

```
access to dn.subtree="ou=students,ou=people,dc=fiber"
    by group.exact="cn=faculty,ou=groups,dc=fiber" write
    by * read
```

---

## 🎓 Students → Read Only

```
access to *
    by group.exact="cn=students,ou=groups,dc=fiber" read
```

---

# 🖥️ 6. Cluster Access (IMPORTANT PART)

For your requirement:

> “student can run programs but not delete anything”

You **DO NOT enforce this in LDAP directly** — instead:

### Use LDAP for:

* Authentication (login)

### Use Linux for:

* Permissions

---

### Example on cluster machine:

```
/cluster/run/
```

Set:

```
chown root:students /cluster/run
chmod 750 /cluster/run
```

✔ Students → execute
❌ Cannot delete system files

---

# 🔄 7. Auto User Creation While Program Running

This part:

> "if machine is running program create user on the go"

LDAP itself doesn’t auto-create users.

You need:

### Option 1 (Recommended):

* Script using `ldapadd`

Example:

```bash
ldapadd -x -D "cn=admin,dc=fiber" -W -f newuser.ldif
```

---

### Option 2:

Use:

* PAM + LDAP (`libnss-ldap`, `pam_ldap`)
* Auto home dir creation (`pam_mkhomedir`)

---

# ⚠️ Important Notes

* `dc=com` is NOT required → your `dc=fiber` is fine ✔
* Always restart LDAP after ACL changes:

```bash
systemctl restart slapd
```

---

# ✅ Final Architecture

| Role    | LDAP Group | Permissions              |
| ------- | ---------- | ------------------------ |
| Admin   | admins     | Full access              |
| Faculty | faculty    | Manage students          |
| Student | students   | Read-only + run programs |

---

