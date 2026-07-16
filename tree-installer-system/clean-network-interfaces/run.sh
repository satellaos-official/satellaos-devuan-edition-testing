#!/bin/bash

source "$HOME/.satellaos-source/installer"

echo "Cleaning The /etc/network/interfaces File"

sudo cp $script_source/clean-network-interfaces/interfaces /etc/network/interfaces