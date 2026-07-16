#!/bin/bash

echo "Installing Flatpak..."

sudo apt install --install-recommends -y flatpak flatpak-xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo