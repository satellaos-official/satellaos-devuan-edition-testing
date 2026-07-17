#!/bin/bash

source "$HOME/.satellaos-source/installer"

sudo cp -r $script_source/update-etc-skel-configuration/backup/.config/ /etc/skel/

sudo cp $script_source/update-etc-skel-configuration/backup/.bashrc /etc/skel/.bashrc

