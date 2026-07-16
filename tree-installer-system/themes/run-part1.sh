#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "Changing The papirus-icon-theme Color to violet."

sudo wget https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders \
  -O /usr/bin/papirus-folders

sudo chmod +x /usr/bin/papirus-folders

sudo apt install --install-recommends -y papirus-icon-theme

papirus-folders -C violet --theme Papirus-Dark

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
