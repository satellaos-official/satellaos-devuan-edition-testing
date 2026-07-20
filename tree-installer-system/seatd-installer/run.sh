#!/bin/bash
set -e

echo ">> Adding user to tty and video groups..."
sudo usermod -aG tty,video "$USER"

echo ">> Installing seatd..."
sudo apt install --install-recommends -y seatd

echo ">> Enabling seatd service..."
sudo rc-update add seatd default
sudo rc-service seatd start

echo ">> seatd service status:"
rc-service seatd status

echo ">> Detecting actual seatd group name..."
SEAT_GROUP=$(grep -i seat /etc/group | cut -d: -f1 | head -n1)

if [ -n "$SEAT_GROUP" ]; then
    echo ">> Adding user to group: $SEAT_GROUP..."
    sudo usermod -aG "$SEAT_GROUP" "$USER"
else
    echo "!! Warning: no seatd-related group found, please check manually: /etc/group"
fi

echo ""
echo "=========================================="
echo "Done. IMPORTANT: You need to REBOOT the"
echo "system for the group changes to take effect."
echo "After rebooting, try startxfce4 again."
echo "=========================================="