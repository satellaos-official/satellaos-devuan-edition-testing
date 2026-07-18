#!/bin/bash

source "$HOME/.satellaos-source/installer"

sudo cp -r $script_source/update-root-configuration/backup/.config/ /root

sudo cp $script_source/update-root-configuration/backup/.bashrc /root/.bashrc