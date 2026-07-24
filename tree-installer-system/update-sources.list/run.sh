#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Enabling The Non-Free Repos"

sudo cp $script_source/update-sources.list/sources.list /etc/apt/sources.list

sudo apt update