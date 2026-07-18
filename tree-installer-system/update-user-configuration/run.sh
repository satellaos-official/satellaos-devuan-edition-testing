#!/bin/bash

source "$HOME/.satellaos-source/installer"

sudo cp -r $script_source/update-user-configuration/backup/.config/ /etc/skel/

sudo cp -r $script_source/update-user-configuration/backup/.local/ /etc/skel/

sudo cp $script_source/update-user-configuration/backup/.bashrc /etc/skel/.bashrc

cp -r $script_source/update-user-configuration/backup/.config/ $HOME/

cp -r $script_source/update-user-configuration/backup/.local/ $HOME/

cp $script_source/update-user-configuration/backup/.bashrc $HOME/.bashrc