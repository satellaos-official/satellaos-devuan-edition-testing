#!/bin/bash

source "$HOME/.satellaos-source/installer"

cp -r $script_source/update-etc-skel-configuration/backup/.config/ $HOME/

cp $script_source/update-etc-skel-configuration/backup/.bashrc $HOME.bashrc

