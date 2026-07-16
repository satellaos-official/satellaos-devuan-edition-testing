#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Updating The LightDM Settings"

sudo cp $script_source/lightdm-settings/lightdm/* /etc/lightdm/