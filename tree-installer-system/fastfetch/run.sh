#!/bin/bash

source "$HOME/.satellaos-source/installer"

read -p "Do you want to install fastfetch? (Y/N): " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    sudo apt install --no-install-recommends -y fastfetch

    read -p "Do you want to apply SatellaOS's custom fastfetch configuration? (Y/N): " config_choice
    if [[ "$config_choice" =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.config/fastfetch"
        cp "$script_source/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
        sudo mkdir -p /etc/skel/.config/fastfetch
        sudo cp "$script_source/fastfetch/config.jsonc" /etc/skel/.config/fastfetch/config.jsonc
    else
        echo "Skipping custom configuration."
    fi
else
    echo "Skipping fastfetch installation."
fi