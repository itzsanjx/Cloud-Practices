  GNU nano 7.2                                                         userc.sh
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

^G Help         ^O Write Out    ^W Where Is     ^K Cut          ^T Execute      ^C Location     M-U Undo        M-A Set Mark    M-] To Bracket
^X Exit         ^R Read File    ^\ Replace      ^U Paste        ^J Justify      ^/ Go To Line   M-E Redo        M-6 Copy        ^Q Where Was