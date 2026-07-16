#!/bin/bash

echo "Restoring /etc/skel directory..."

sudo cp -r $Base/skel-configuration-settings/backup/. /etc/skel/