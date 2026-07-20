#!/bin/bash

# ============================================================
#  Driver Installer
#  For Debian / XFCE (Whiptail TUI Edition - Direct Mode)
# ============================================================

set -u

# ============================================================
# Action Selection Menu via Whiptail
# ============================================================

CHOICES=$(whiptail --title "SatellaOS Driver Installer" \
    --checklist "Select the drivers you want to install:\n(SPACE: Select | ENTER: Confirm | TAB: Switch)" \
    30 76 20 \
    "1" "AMD Graphics Driver"                  OFF \
    "2" "Intel Graphics Driver"                OFF \
    "3" "NVIDIA Nouveau Graphics Driver"        OFF \
    "4" "VMware Guest Tools"                   OFF \
    "5" "VirtualBox Guest Additions"           OFF \
    "6" "QEMU Guest Agent"                     OFF \
    "7" "QEMU QXL Driver"                      OFF \
    "8" "QEMU Spice"                           OFF \
    "9" "Intel WiFi Driver"                    OFF \
    "10" "Broadcom WiFi Driver"                OFF \
    "11" "Realtek WiFi Driver"                 OFF \
    "12" "Atheros / Qualcomm WiFi Driver"      OFF \
    "13" "MediaTek WiFi Driver"                OFF \
    "14" "Intel Bluetooth Driver"              OFF \
    "15" "Broadcom Bluetooth Driver"           OFF \
    "16" "Realtek Bluetooth Driver"            OFF \
    "17" "MediaTek Bluetooth Driver"           OFF \
    "18" "Atheros / Qualcomm Bluetooth Driver" OFF \
    "19" "Base Audio Stack (ALSA/PulseAudio)"  OFF \
    "20" "Intel HD Audio Driver"               OFF \
    "21" "Realtek Audio Driver"                OFF \
    "22" "AMD Audio Driver"                    OFF \
    "23" "NVIDIA HDMI Audio Driver"            OFF \
    "24" "USB Audio Driver"                    OFF \
    "25" "Creative Sound Blaster Driver"       OFF \
    "26" "ADB Driver (Android)"                OFF \
    3>&1 1>&2 2>&3) || { exit 0; }

# Clean and sort the selections
SELECTIONS=$(echo "$CHOICES" | tr -d '"' | tr ' ' '\n' | sort -n)

if [[ -z "$SELECTIONS" ]]; then
    exit 0
fi

# ============================================================
# Driver Install Actions
# ============================================================

action_1() {
    echo ">>> Installing AMD Graphics Driver..."
    sudo apt install -y firmware-amd-graphics libgl1-mesa-dri mesa-vulkan-drivers xserver-xorg-video-all
}

action_2() {
    echo ">>> Installing Intel Graphics Driver..."
    sudo apt install -y firmware-misc-non-free libgl1-mesa-dri mesa-vulkan-drivers xserver-xorg-video-intel
}

action_3() {
    echo ">>> Installing NVIDIA Nouveau Graphics Driver..."
    sudo apt install -y firmware-misc-non-free libgl1-mesa-dri mesa-vulkan-drivers xserver-xorg-video-nouveau
}

action_4() {
    echo ">>> Installing VMware Guest Tools..."
    sudo apt install -y open-vm-tools open-vm-tools-desktop
}

action_5() {
    echo ">>> Installing VirtualBox Guest Additions..."
    local BASE_URL="https://download.virtualbox.org/virtualbox"
    local MOUNT_DIR="/tmp/vbox-guest-additions"
    local TMP_ISO=""

    _vbox_cleanup() {
        mountpoint -q "$MOUNT_DIR" 2>/dev/null && sudo umount "$MOUNT_DIR" 2>/dev/null || true
        [[ -n "$TMP_ISO" && -f "$TMP_ISO" ]] && rm -f "$TMP_ISO" || true
    }
    trap _vbox_cleanup RETURN

    local LATEST_VERSION
    LATEST_VERSION=$(curl -fsSL "${BASE_URL}/LATEST-STABLE.TXT" 2>/dev/null | tr -d '[:space:]') || true
    if [[ -z "$LATEST_VERSION" ]]; then
        LATEST_VERSION=$(
            curl -fsSL "${BASE_URL}/" \
            | grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/)' \
            | sort -V \
            | tail -1
        )
    fi
    if [[ -z "$LATEST_VERSION" ]]; then
        echo "!!! Could not determine the latest VirtualBox version." >&2
        return 1
    fi

    local ISO_FILENAME="VBoxGuestAdditions_${LATEST_VERSION}.iso"
    TMP_ISO="/tmp/${ISO_FILENAME}"

    curl -fsSL -o "$TMP_ISO" "${BASE_URL}/${LATEST_VERSION}/${ISO_FILENAME}" || return 1

    sudo mkdir -p "$MOUNT_DIR"
    sudo mount -o loop,ro "$TMP_ISO" "$MOUNT_DIR" || return 1

    [[ -f "${MOUNT_DIR}/VBoxLinuxAdditions.run" ]] || return 1
    sudo sh "${MOUNT_DIR}/VBoxLinuxAdditions.run" || return 1
}

action_6() {
    echo ">>> Installing QEMU Guest Agent..."
    sudo apt install -y qemu-guest-agent
}

action_7() {
    echo ">>> Installing QEMU QXL Driver..."
    sudo apt install -y xserver-xorg-video-qxl
}

action_8() {
    echo ">>> Installing QEMU Spice..."
    sudo apt install -y spice-vdagent spice-client-gtk
}

action_9() {
    echo ">>> Installing Intel WiFi Driver..."
    sudo apt install -y firmware-iwlwifi
    sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
}

action_10() {
    echo ">>> Installing Broadcom WiFi Driver..."
    sudo apt install -y firmware-b43-installer broadcom-sta-dkms
    sudo apt install -y linux-headers-"$(uname -r)" broadcom-sta-dkms
}

action_11() {
    echo ">>> Installing Realtek WiFi Driver..."
    sudo apt install -y firmware-realtek
    sudo apt install -y linux-headers-"$(uname -r)" dkms git
}

action_12() {
    echo ">>> Installing Atheros / Qualcomm WiFi Driver..."
    sudo apt install -y firmware-atheros
}

action_13() {
    echo ">>> Installing MediaTek WiFi Driver..."
    sudo apt install -y firmware-mediatek
}

action_14() {
    echo ">>> Installing Intel Bluetooth Driver..."
    sudo apt install -y firmware-iwlwifi bluez bluez-tools bluetooth blueman
}

action_15() {
    echo ">>> Installing Broadcom Bluetooth Driver..."
    sudo apt install -y firmware-brcm80211 bluez bluez-tools bluetooth blueman
}

action_16() {
    echo ">>> Installing Realtek Bluetooth Driver..."
    sudo apt install -y firmware-realtek bluez bluez-tools bluetooth blueman
    sudo apt install -y linux-headers-"$(uname -r)" dkms
}

action_17() {
    echo ">>> Installing MediaTek Bluetooth Driver..."
    sudo apt install -y firmware-mediatek bluez bluez-tools bluetooth blueman
}

action_18() {
    echo ">>> Installing Atheros / Qualcomm Bluetooth Driver..."
    sudo apt install -y firmware-atheros bluez bluez-tools bluetooth blueman
}

action_19() {
    echo ">>> Installing Base Audio Stack (ALSA + PulseAudio)..."
    sudo apt install -y alsa-utils pulseaudio pulseaudio-utils pavucontrol
}

action_20() {
    echo ">>> Installing Intel HD Audio Driver..."
    sudo apt install -y firmware-sof-signed alsa-firmware-loaders
    sudo modprobe -r snd_hda_intel && sudo modprobe snd_hda_intel
}

action_21() {
    echo ">>> Installing Realtek Audio Driver..."
    sudo apt install -y firmware-linux-nonfree alsa-firmware-loaders
    sudo modprobe -r snd_hda_codec_realtek && sudo modprobe snd_hda_codec_realtek
}

action_22() {
    echo ">>> Installing AMD Audio Driver..."
    sudo apt install -y firmware-amd-graphics alsa-firmware-loaders
    sudo modprobe -r snd_hda_intel && sudo modprobe snd_hda_intel
}

action_23() {
    echo ">>> Installing NVIDIA HDMI Audio Driver..."
    sudo apt install -y firmware-misc-non-free
    sudo modprobe -r snd_hda_intel && sudo modprobe snd_hda_intel
}

action_24() {
    echo ">>> Installing USB Audio Driver..."
    sudo apt install -y alsa-utils
    sudo modprobe -r snd_usb_audio && sudo modprobe snd_usb_audio
}

action_25() {
    echo ">>> Installing Creative Sound Blaster Driver..."
    sudo apt install -y firmware-linux-nonfree
    sudo modprobe -r snd_ctxfi 2>/dev/null || true
    sudo modprobe snd_ctxfi 2>/dev/null || true
}

action_26() {
    echo ">>> Installing ADB Driver..."
    sudo apt install --no-install-recommends -y adb mtp-tools jmtpfs
}

# ============================================================
# Run Selected Actions
# ============================================================

FAILED=()

for num in $SELECTIONS; do
    if ! "action_$num"; then
        FAILED+=("$num")
    fi
    echo
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo "!!! Some drivers failed to install."
    echo "!!! Failed action IDs: ${FAILED[*]}"
    exit 1
fi

echo ">>> All selected drivers were installed successfully."

exit 0