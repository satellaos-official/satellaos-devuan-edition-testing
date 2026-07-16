#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Installing The SatellaOS Pictures"

sudo mkdir -p /usr/share/satellaos-core/pictures/

sudo cp -r $script_source/pictures/satellaos-polaris/* /usr/share/satellaos-core/pictures/
