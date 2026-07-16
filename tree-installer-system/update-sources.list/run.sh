#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Enabling The Non-Free Repos"

sudo cp $script_source/update-sources.list/sources.list /etc/sources.list