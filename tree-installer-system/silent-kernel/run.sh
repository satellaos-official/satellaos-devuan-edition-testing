#!/usr/bin/env bash

source "$HOME/.satellaos-source/installer"

echo "Kernel messages are being silent."

set -euo pipefail

sudo cp $script_source/silent-kernel/99-silent-kernel.conf /etc/sysctl.d/99-silent-kernel.conf

sudo sysctl --system
