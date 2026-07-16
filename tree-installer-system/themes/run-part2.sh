#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Installing The Fluent GTK Theme to System"

sudo apt install -y libsass1 sassc

sudo apt install -y "$script_source/themes/packages/satellaos-fluent-gtk-theme_2025-04-17_amd64.deb"

sudo apt purge -y satellaos-fluent-gtk-theme