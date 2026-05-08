#!/bin/bash
# ─────────────────────────────────────────────
# User Deletion Script
# - Removes user, home directory, and storage
# - Requires double confirmation + username typed
# ─────────────────────────────────────────────

# Must run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run this script as root (sudo)"
    exit 1
fi

# Get username
read -p "Enter username to delete: " USERNAME

# Validate username not empty
if [[ -z "$USERNAME" ]]; then
    echo "Error: Username cannot be empty"
    exit 1
fi

# Check user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' does not exist"
    exit 1
fi

# Show what will be deleted
echo ""
echo "════════════════════════════════════════"
echo " The following will be PERMANENTLY deleted:"
echo " Username  : $USERNAME"
echo " Home      : /home/$USERNAME"
echo "════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# Confirmation 1
# ─────────────────────────────────────────────
read -p "⚠  Are you sure you want to delete user '$USERNAME'? (yes/no): " CONFIRM1

if [[ "$CONFIRM1" != "yes" ]]; then
    echo "Aborted. No changes were made."
    exit 0
fi

# ─────────────────────────────────────────────
# Confirmation 2
# ─────────────────────────────────────────────
read -p "⚠  This action is IRREVERSIBLE. Proceed with deletion? (yes/no): " CONFIRM2

if [[ "$CONFIRM2" != "yes" ]]; then
    echo "Aborted. No changes were made."
    exit 0
fi

# ─────────────────────────────────────────────
# Final check - type the username to confirm
# ─────────────────────────────────────────────
echo ""
echo "Final verification: Type the username '$USERNAME' to confirm deletion:"
read -p "> " TYPED_NAME

if [[ "$TYPED_NAME" != "$USERNAME" ]]; then
    echo "Error: Username did not match. Aborted. No changes were made."
    exit 1
fi

# ─────────────────────────────────────────────
# Delete user
# ─────────────────────────────────────────────
echo ""
echo "Deleting user '$USERNAME'..."

# Step 1: Kill all active processes forcefully
echo "-> Terminating active sessions and processes..."
pkill -9 -u "$USERNAME" 2>/dev/null
sleep 1

# Step 2: Log out any active login sessions
loginctl terminate-user "$USERNAME" 2>/dev/null
sleep 1

# Step 3: Remove the user account only (home dir handled manually below)
echo "-> Removing user account..."
userdel "$USERNAME" 2>/dev/null
EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
    echo "-> userdel failed (exit $EXIT_CODE), trying force remove..."
    sed -i "/^$USERNAME:/d" /etc/passwd
    sed -i "/^$USERNAME:/d" /etc/shadow
    sed -i "/^$USERNAME:/d" /etc/group
    sed -i "/^$USERNAME:/d" /etc/gshadow
    groupdel "$USERNAME" 2>/dev/null
fi

# Step 4: Remove home directory manually
echo "-> Removing home directory..."
if [[ -d "/home/$USERNAME" ]]; then
    rm -rf "/home/$USERNAME"
fi


# Step 5: Verify deletion
if id "$USERNAME" &>/dev/null; then
    echo ""
    echo "Error: Failed to fully delete user '$USERNAME'. Please check manually."
    exit 1
fi

echo ""
echo "════════════════════════════════════════"
echo " User deleted successfully!"
echo " Username  : $USERNAME"
echo " Home      : /home/$USERNAME  [removed]"
echo "════════════════════════════════════════"