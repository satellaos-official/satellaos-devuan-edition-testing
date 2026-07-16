#!/bin/bash

echo "Restoring XFCE configuration and autostart settings..."

mkdir -p "$HOME/.config/"

cp -r $BASE/user-configuration-settings/backup/* "$HOME/.config/"

cp "$BASE/user-configuration-settings/backup/.bashrc" "$HOME/.bashrc"

echo "Restore of XFCE configuration and autostart settings is complete."