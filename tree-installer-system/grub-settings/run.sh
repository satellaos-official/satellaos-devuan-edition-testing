#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Updating The GRUB BootLoader Settings"

sudo cp $script_source/grub-settings/grub /etc/default/grub

sudo update-grub

sudo update-initramfs -u
