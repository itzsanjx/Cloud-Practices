This **fully practical** copy–paste and build everything cleanly on  `dc=fiber` setup.

---

# 📄 1. FULL LDIF FILES (Copy–Paste Ready)

## 🧱 A. Create Base Structure

Save as: `base.ldif`

```
dn: ou=people,dc=fiber
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=fiber
objectClass: organizationalUnit
ou: groups

dn: ou=admins,ou=people,dc=fiber
objectClass: organizationalUnit
ou: admins

dn: ou=faculty,ou=people,dc=fiber
objectClass: organizationalUnit
ou: faculty

dn: ou=students,ou=people,dc=fiber
objectClass: organizationalUnit
ou: students
```

---

## 👥 B. Create Groups

Save as: `groups.ldif`

```
dn: cn=admins,ou=groups,dc=fiber
objectClass: posixGroup
cn: admins
gidNumber: 10000

dn: cn=faculty,ou=groups,dc=fiber
objectClass: posixGroup
cn: faculty
gidNumber: 11000

dn: cn=students,ou=groups,dc=fiber
objectClass: posixGroup
cn: students
gidNumber: 12000
```

---

## 👤 C. Create Users

Save as: `users.ldif`

```
dn: uid=admin1,ou=admins,ou=people,dc=fiber
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Admin One
sn: Admin
uid: admin1
uidNumber: 10000
gidNumber: 10000
homeDirectory: /home/admin1
loginShell: /bin/bash
userPassword: admin123

dn: uid=faculty1,ou=faculty,ou=people,dc=fiber
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Faculty One
sn: Faculty
uid: faculty1
uidNumber: 11000
gidNumber: 11000
homeDirectory: /home/faculty1
loginShell: /bin/bash
userPassword: faculty123

dn: uid=student1,ou=students,ou=people,dc=fiber
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Student One
sn: Student
uid: student1
uidNumber: 12000
gidNumber: 12000
homeDirectory: /home/student1
loginShell: /bin/bash
userPassword: student123
```

---

## 🔗 D. Add Users to Groups

Save as: `members.ldif`

```
dn: cn=admins,ou=groups,dc=fiber
changetype: modify
add: memberUid
memberUid: admin1

dn: cn=faculty,ou=groups,dc=fiber
changetype: modify
add: memberUid
memberUid: faculty1

dn: cn=students,ou=groups,dc=fiber
changetype: modify
add: memberUid
memberUid: student1
```

---

# ▶️ 2. Run These Commands

```
ldapadd -x -D "cn=admin,dc=fiber" -W -f base.ldif
ldapadd -x -D "cn=admin,dc=fiber" -W -f groups.ldif
ldapadd -x -D "cn=admin,dc=fiber" -W -f users.ldif
ldapmodify -x -D "cn=admin,dc=fiber" -W -f members.ldif
```

---

# 🖱️ 3. EXACT phpLDAPadmin STEPS

---

## 🔹 Step 1: Login

* Open phpLDAPadmin
* Login using:

  ```
  cn=admin,dc=fiber
  ```

---

## 🔹 Step 2: Create OUs

### 👉 Click:

* `dc=fiber`
* Click **"Create new entry here"**

### Choose:

* **Generic: Organizational Unit**

### Enter:

* `ou = people`

Click **Create Object**

---

### Repeat for:

* `ou=groups`
* Inside `people`, create:

  * `admins`
  * `faculty`
  * `students`

---

## 🔹 Step 3: Create Groups

Go to:

```
ou=groups
```

Click:

* **Create new entry here**

Choose:

* **Generic: Posix Group**

---

### Fill:

#### Admin Group

```
cn: admins
gidNumber: 10000
```

Repeat for:

* faculty → 11000
* students → 12000

---

## 🔹 Step 4: Create Users

Go to:

```
ou=admins → Create new entry
```

Choose:

* **Generic: User Account**

---

### Fill:

#### Admin User

```
uid: admin1
cn: Admin One
sn: Admin
uidNumber: 10000
gidNumber: 10000
homeDirectory: /home/admin1
loginShell: /bin/bash
password: admin123
```

---

### Repeat:

📁 `ou=faculty`

* faculty1

📁 `ou=students`

* student1

---

## 🔹 Step 5: Add User to Group

Go to:

```
cn=admins → Edit
```

Find:

```
memberUid
```

Add:

```
admin1
```

Repeat for other groups.

---

# 🔐 4. IMPORTANT (Passwords)

Plain text passwords may NOT work depending on config.

Better:

```
slappasswd
```

Then replace:

```
userPassword: {SSHA}hashedvalue
```

---

# ✅ DONE RESULT

