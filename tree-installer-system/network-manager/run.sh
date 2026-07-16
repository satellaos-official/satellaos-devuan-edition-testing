#!/bin/bash

echo "installing network manager"

sudo apt install --no-install-recommends -y network-manager network-manager-applet wpasupplicant

echo "Enabling Network Manager"

sudo rc-update add network-manager default