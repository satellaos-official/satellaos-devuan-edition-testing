#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Updating The os-release File"

sudo cp $script_source/update-os-release/os-release /etc/os-release