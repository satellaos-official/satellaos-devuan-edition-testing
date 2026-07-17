#!/bin/bash

sudo apt install -y engrampa \
	galculator \
	mousepad \
	onboard \
	ristretto \
	libwebp7 \
    tumbler \
    tumbler-plugins-extra \
    webp-pixbuf-loader

sudo apt install -y --no-install-recommends lightdm-gtk-greeter-settings \
	xfce4-screenshooter

sudo apt purge -y xfce-polkit