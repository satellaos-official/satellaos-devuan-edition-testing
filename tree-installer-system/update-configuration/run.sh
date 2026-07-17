#!/bin/bash

source "$HOME/.satellaos-source/installer"

sudo cp -r $script_source/update-configuration/backup/.config/ /etc/skel/

sudo cp $script_source/update-configuration/backup/.bashrc /etc/skel/.bashrc

cp -r $script_source/update-configuration/backup/.config/ $HOME/

cp $script_source/update-configuration/backup/.bashrc $HOME/.bashrc