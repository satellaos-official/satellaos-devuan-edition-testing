#!/bin/bash
set -e
set -u

Base="$HOME/satellaos-install-tool-cr/tree-installer-system/skel-configuration-settings/backup/"
mkdir -p $Base

echo "Backing up /etc/skel directory..."

# ============================================================
# /etc/skel
# ============================================================

cp -r /etc/skel/. "$Base"/

echo "Backup of /etc/skel directory is complete."