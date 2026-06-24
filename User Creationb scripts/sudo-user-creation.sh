#!/bin/bash
# ─────────────────────────────────────────────
# User Creation Script
# - Takes username and public key as input
# - SSH key login only, no password
# - sudo allowed except shell escalation
# - /root directory access blocked
# ─────────────────────────────────────────────

# Must run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

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


# ─────────────────────────────────────────────
# Create user
# ─────────────────────────────────────────────
useradd -m -s /bin/bash "$USERNAME"

# '*' = password disabled (not locked); SSH key auth works correctly
usermod -p '*' "$USERNAME"

# Setup SSH
mkdir -p /home/"$USERNAME"/.ssh
echo "$PUBKEY" > /home/"$USERNAME"/.ssh/authorized_keys
chmod 700 /home/"$USERNAME"/.ssh
chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Lock home dir
chmod 700 /home/"$USERNAME"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Sudoers — whitelist only safe commands
# Blocks sudo -i / sudo su / shell escalation
# Allows: apt, systemctl, service, journalctl
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUDOERS_FILE="/etc/sudoers.d/block-sudo-i-${USERNAME}"
cat > "$SUDOERS_FILE" <<EOF
# ── Whitelisted commands (no password required) ──
Cmnd_Alias ${USERNAME^^}_ALLOWED = \\
    /usr/bin/apt update, \\
    /usr/bin/apt upgrade, \\
    /usr/bin/apt install *, \\
    /usr/bin/apt remove *, \\
    /usr/bin/apt autoremove, \\
    /usr/bin/apt-get update, \\
    /usr/bin/apt-get upgrade, \\
    /usr/bin/apt-get install *, \\
    /usr/bin/apt-get remove *, \\
    /usr/bin/apt-get autoremove, \\
    /usr/bin/systemctl start *, \\
    /usr/bin/systemctl stop *, \\
    /usr/bin/systemctl restart *, \\
    /usr/bin/systemctl reload *, \\
    /usr/bin/systemctl status *, \\
    /usr/bin/systemctl enable *, \\
    /usr/bin/systemctl disable *, \\
    /usr/bin/service * start, \\
    /usr/bin/service * stop, \\
    /usr/bin/service * restart, \\
    /usr/bin/service * status, \\
    /usr/bin/journalctl *

# ── Explicitly blocked escalation commands ──
Cmnd_Alias ${USERNAME^^}_BLOCKED = \\
    /bin/bash, \\
    /bin/sh, \\
    /bin/dash, \\
    /bin/zsh, \\
    /usr/bin/zsh, \\
    /bin/su, \\
    /usr/bin/su, \\
    /usr/bin/passwd, \\
    /usr/sbin/visudo, \\
    /usr/bin/vim /etc/*, \\
    /usr/bin/nano /etc/*, \\
    /bin/vi /etc/*

# ── Apply rules ──
$USERNAME ALL=(ALL) NOPASSWD: ${USERNAME^^}_ALLOWED
$USERNAME ALL=(ALL) !${USERNAME^^}_BLOCKED

# ── Block sudo -i (login shell flag) ──
Defaults:$USERNAME !shell_noargs
EOF

chmod 440 "$SUDOERS_FILE"

# Validate sudoers syntax — remove and abort if broken
if ! visudo -c -f "$SUDOERS_FILE" &>/dev/null; then
    echo "ERROR: sudoers syntax validation failed. Removing file and aborting."
    rm -f "$SUDOERS_FILE"
    userdel -r "$USERNAME"
    exit 1
fi
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Bashrc — intercept sudo su / sudo -i
# Prints RED warning + logs attempt + blocks
# Also blocks cd /root navigation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cat >> /home/"$USERNAME"/.bashrc <<'EOF'

# ── sudo escalation intercept ────────────────
function sudo() {
    local args=("$@")
    local joined="${args[*]}"

    if [[ "$joined" =~ ^(-i|-s|--login|--shell)$ ]] || \
       [[ "$joined" =~ ^(su|su\ -|su\ root|-\ root)$ ]] || \
       [[ "$joined" =~ ^(bash|sh|dash|zsh|/bin/bash|/bin/sh|/bin/dash|/bin/zsh)$ ]]; then

        # ANSI color codes
        local RED='\033[0;31m'
        local BOLD='\033[1m'
        local RESET='\033[0m'

        echo ""
        echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}${BOLD}║   ⚠  SECURITY VIOLATION DETECTED                    ║${RESET}"
        echo -e "${RED}${BOLD}║                                                      ║${RESET}"
        echo -e "${RED}${BOLD}║   This action has been noted & reported              ║${RESET}"
        echo -e "${RED}${BOLD}║   to the HPC Admin.                                  ║${RESET}"
        echo -e "${RED}${BOLD}║                                                      ║${RESET}"
        echo -e "${RED}${BOLD}║   Attempting to gain root shell access is            ║${RESET}"
        echo -e "${RED}${BOLD}║   strictly prohibited on this system.                ║${RESET}"
        echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
        echo ""

        # Log the attempt to syslog
        logger -t HPC-SECURITY "ALERT: User $USER attempted sudo escalation: sudo $joined from $(tty) at $(date)"
        return 1
    fi

    # Allow all other sudo commands
    command sudo "$@"
}
# ── end sudo intercept ───────────────────────

# ── /root access guard ──────────────────────
function cd() {
    builtin cd "$@" || return
    if [[ "$PWD" == /root || "$PWD" == /root/* ]]; then
        echo "Access to /root is strictly forbidden."
        builtin cd "$OLDPWD"
    fi
}

PROMPT_COMMAND='if [[ "$PWD" == /root || "$PWD" == /root/* ]]; then
    echo "Access to /root is strictly forbidden. Returning to home.";
    cd ~;
fi'
# ── end guard ───────────────────────────────
EOF
chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.bashrc
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


SERVER_IP=$(hostname -I | awk '{print $1}')
KEY_TYPE=$(echo "$PUBKEY" | awk '{print $1}')
KEY_SIZE=$(echo "$PUBKEY" | awk '{print $2}' | base64 -d 2>/dev/null | wc -c)

echo ""
echo "==========================================="
echo " User created successfully!"
echo "-------------------------------------------"
echo " Username   : $USERNAME"
echo " Home       : /home/$USERNAME"
echo " Password   : DISABLED (SSH key only)"
echo " Key type   : $KEY_TYPE"
echo " Key size   : ${KEY_SIZE} bytes"
echo " Public key : $(echo "$PUBKEY" | cut -c1-40)..."
echo "==========================================="
echo ""
echo "==========================================="
echo " Restrictions applied"
echo "-------------------------------------------"
echo " [+] sudo -i          : BLOCKED + REPORTED"
echo " [+] sudo -s          : BLOCKED + REPORTED"
echo " [+] sudo su          : BLOCKED + REPORTED"
echo " [+] sudo bash/sh     : BLOCKED + REPORTED"
echo " [+] cd /root         : BLOCKED"
echo " [+] sudo apt *       : ALLOWED"
echo " [+] sudo systemctl * : ALLOWED"
echo " [+] sudo service *   : ALLOWED"
echo " [+] sudo journalctl  : ALLOWED"
echo "==========================================="
echo ""
echo "==========================================="
echo "           SSH Connections"
echo "-------------------------------------------"
echo " ssh $USERNAME@$SERVER_IP"
echo "       (or)"
echo " ssh -i /path/to/private_key $USERNAME@$SERVER_IP"
echo "==========================================="