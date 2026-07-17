#!/bin/bash

THEME_DIR="/boot/grub/themes"
THEME_NAME="satellaos-grub-theme-polaris"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$UID" -eq 0 ]; then
  [[ -f /boot/grub/splash.png ]] && sudo mv /boot/grub/splash.png /boot/grub/splash-backup.png

  [[ -d "${THEME_DIR}/${THEME_NAME}" ]] && rm -rf "${THEME_DIR}/${THEME_NAME}"
  mkdir -p "${THEME_DIR}/${THEME_NAME}"
  cp -a "${SCRIPT_DIR}/${THEME_NAME}/." "${THEME_DIR}/${THEME_NAME}/"
  cp -an /etc/default/grub /etc/default/grub.bak
  grep -q "GRUB_THEME=" /etc/default/grub && sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
  update-grub
else
  sudo "$0"
fi