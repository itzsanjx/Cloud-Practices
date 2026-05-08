#!/bin/bash

# ─────────────────────────────────────────────
# User Creation Script
# - Takes username and public key as input
# - SSH key login only, no password
# ─────────────────────────────────────────────

# Get username
read -p "Enter username: " USERNAME

# Validate username
if [[ -z "$USERNAME" ]]; then
    echo "Error: Username cannot be empty"
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME already exists"
    exit 1
fi

# Get public key
echo "Paste the user's public key (press Enter then Ctrl+D when done):"
PUBKEY=$(cat)

# Validate public key
if [[ -z "$PUBKEY" ]]; then
    echo "Error: Public key cannot be empty"
    exit 1
fi

if [[ ! "$PUBKEY" == ssh-* ]]; then
    echo "Error: Invalid public key format. Must start with ssh-rsa or ssh-ed25519"
    exit 1
fi

# ─────────────────────────────────────────────
# Create user
# ─────────────────────────────────────────────
useradd -m -s /bin/bash "$USERNAME"
passwd -l "$USERNAME"

# Setup SSH
mkdir -p /home/"$USERNAME"/.ssh
echo "$PUBKEY" > /home/"$USERNAME"/.ssh/authorized_keys
chmod 700 /home/"$USERNAME"/.ssh
chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Lock home dir
chmod 700 /home/"$USERNAME"

# Assign Storage Directory
mkdir -p /storage/"$USERNAME"
chown "$USERNAME":"$USERNAME" /storage/"$USERNAME"
chmod 700 /storage/"$USERNAME"

# User Credentials
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "==========================================="
echo " User created successfully!"
echo " Username  : $USERNAME"
echo " Home      : /home/$USERNAME"
echo " Password  : LOCKED (SSH key only)"
echo " Public key: $(echo $PUBKEY | cut -c1-40)..."
echo " Storage    : /storage/$USERNAME"
echo "==========================================="


echo ""
echo "==========================================="
echo "            SSH = Connections              "
echo "-------------------------------------------"
echo " Connect using:"
echo "   ssh $USERNAME@$SERVER_IP"
echo "         (or)"
echo "   ssh -i /path/to/private_key $USERNAME@$SERVER_IP"
echo "==========================================="
