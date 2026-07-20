#!/bin/bash

#------- Source Script -------
bash $HOME/satellaos-devuan-edition-testing/tree-installer-system/source/run.sh
source "$HOME/.satellaos-source/installer"
#-----------------------------

#--------Shared Script--------
bash $script_source/seatd-installer/run.sh
bash $script_source/update-adduser/run.sh
bash $script_source/network-manager/run.sh
bash $script_source/clean-network-interfaces/run.sh
bash $script_source/update-sources.list/run.sh
bash $script_source/core/run.sh
bash $script_source/extra-packages/run.sh
bash $script_source/flatpak-installer/run.sh
bash $script_source/update-os-release/run.sh
bash $script_source/silent-kernel/run.sh
bash $script_source/grub-settings/run.sh
bash $script_source/grub-theme/run.sh
bash $script_source/lightdm-settings/run.sh
bash $script_source/update-user-configuration/run.sh
bash $script_source/update-root-configuration/run.sh
bash $script_source/pictures/run.sh
bash $script_source/themes/run-part1.sh
bash $script_source/themes/run-part2.sh
bash $script_source/themes/run-part3.sh
bash $script_source/uca-creator/run.sh
bash $script_source/driver-installer/run.sh
bash $script_source/font-installer/run.sh
bash $script_source/fastfetch/run.sh
#-----------------------------

#------- LightDM Prompt -------
read -p "Do you want to start LightDM? (Y/N): " answer
case "$answer" in
    [Yy]* )
        sudo rc-service lightdm start
        ;;
    [Nn]* )
        echo "Skipping LightDM."
        ;;
    * )
        echo "Invalid input, skipping LightDM."
        ;;
esac
#-------------------------------------------