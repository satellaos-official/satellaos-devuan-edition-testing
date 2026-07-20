#!/usr/bin/env bash
#
# SatellaOS Program Installer
# Whiptail-based multi-select installer. Select any number of programs
# with SPACE, confirm with OK, and they are installed one after another.
#
# NOTES / ASSUMPTIONS (source list had no command for these — filled in
# with current standard installation methods, verify occasionally):
#   - VirtualBox (Deb): ships in Debian's "contrib" component. Make sure
#     contrib is enabled in /etc/apt/sources.list, otherwise apt install
#     will fail with "Unable to locate package".
#   - VS Code (Deb): uses Microsoft's official apt repository.
#   - WineHQ Stable (Deb): WineHQ has not published trixie packages at the
#     time of writing, so this uses the bookworm repository instead.
#     Switch to a trixie repo once WineHQ publishes one.

set -o pipefail

if ! command -v whiptail >/dev/null 2>&1; then
    echo "whiptail not found. Install it first: sudo apt install whiptail" >&2
    exit 1
fi

PKG_DIR=$(mktemp -d /tmp/satellaos-install-tool-cr-XXXXXX)
trap 'rm -rf "$PKG_DIR"' EXIT

NEEDS_APT_UPDATE=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ensure_flathub() {
    if ! flatpak remote-list 2>/dev/null | grep -q '^flathub'; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
}

make_desktop_entry() {
    # $1=name $2=exec_path $3=icon_path $4=desktop_filename $5=wmclass
    sudo tee "/usr/share/applications/$4" > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=$1
Comment=$1 Web Browser
Exec=$2 %u
Icon=$3
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=$5
EOL
    update-desktop-database /usr/share/applications 2>/dev/null || true
}

set_default_browser() {
    # $1=desktop_filename
    xdg-mime default "$1" x-scheme-handler/http
    xdg-mime default "$1" x-scheme-handler/https
    xdg-settings set default-web-browser "$1"
}

# ---------------------------------------------------------------------------
# 01. Brave Browser (Deb)
# ---------------------------------------------------------------------------
prep_brave() {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    NEEDS_APT_UPDATE=1
}
install_brave() {
    sudo apt install -y brave-browser
}

# ---------------------------------------------------------------------------
# 02. Chromium (Deb)
# ---------------------------------------------------------------------------
install_chromium() {
    sudo apt install -y chromium
}

# ---------------------------------------------------------------------------
# 03. Firefox ESR (Deb)
# ---------------------------------------------------------------------------
install_firefox_esr() {
    sudo apt install -y firefox-esr
}

# ---------------------------------------------------------------------------
# 04. Firefox (Portable)
# ---------------------------------------------------------------------------
install_firefox_portable() {
    local latest_version file url
    latest_version=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json \
        | grep -Po '"LATEST_FIREFOX_VERSION":\s*"\K[^"]+')
    file="$PKG_DIR/firefox-$latest_version.tar.xz"
    url="https://ftp.mozilla.org/pub/firefox/releases/$latest_version/linux-x86_64/en-US/firefox-$latest_version.tar.xz"

    wget -O "$file" "$url"
    sudo rm -rf /opt/firefox
    tar -xf "$file" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/firefox" /opt/firefox
    sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox

    make_desktop_entry "Firefox" "/opt/firefox/firefox" \
        "/opt/firefox/browser/chrome/icons/default/default128.png" \
        "firefox.desktop" "firefox"
    set_default_browser "firefox.desktop"
}

# ---------------------------------------------------------------------------
# 05. Floorp Browser (Portable)
# ---------------------------------------------------------------------------
install_floorp_portable() {
    local repo="Floorp-Projects/Floorp"
    local asset_name="floorp-linux-x86_64.tar.xz"
    local latest_tag file download_url dir_name

    latest_tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"tag_name": "\K(.*)(?=")')
    if [ -z "$latest_tag" ]; then
        echo "Could not resolve latest Floorp release." >&2
        return 1
    fi

    file="$PKG_DIR/floorp.tar.xz"
    download_url="https://github.com/$repo/releases/download/$latest_tag/$asset_name"
    wget -O "$file" "$download_url"

    sudo rm -rf /opt/floorp
    tar -xf "$file" -C "$PKG_DIR"
    dir_name=$(tar -tf "$file" | head -1 | cut -f1 -d"/")
    sudo mv "$PKG_DIR/$dir_name" /opt/floorp
    sudo ln -sf /opt/floorp/floorp /usr/local/bin/floorp

    make_desktop_entry "Floorp Browser" "/opt/floorp/floorp" \
        "/opt/floorp/browser/chrome/icons/default/default128.png" \
        "floorp.desktop" "floorp"
    set_default_browser "floorp.desktop"
}

# ---------------------------------------------------------------------------
# 06. Floorp Browser (Deb)
# ---------------------------------------------------------------------------
prep_floorp_deb() {
    curl -fsSL https://ppa.floorp.app/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/Floorp.gpg
    sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list "https://ppa.floorp.app/Floorp.list"
    NEEDS_APT_UPDATE=1
}
install_floorp_deb() {
    sudo apt install -y floorp
}

# ---------------------------------------------------------------------------
# 07. Google Chrome (Deb)
# ---------------------------------------------------------------------------
install_chrome() {
    wget -O "$PKG_DIR/google-chrome-stable_current_amd64.deb" \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$PKG_DIR/google-chrome-stable_current_amd64.deb"
}

# ---------------------------------------------------------------------------
# 08. Opera Stable (Deb)
# ---------------------------------------------------------------------------
prep_opera() {
    curl -fsSL https://deb.opera.com/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/opera-browser.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" \
        | sudo tee /etc/apt/sources.list.d/opera-stable.list > /dev/null
    NEEDS_APT_UPDATE=1
}
install_opera() {
    sudo apt install -y opera-stable
}

# ---------------------------------------------------------------------------
# 09. Tor Browser (Deb)
# ---------------------------------------------------------------------------
install_tor() {
    sudo apt install -y torbrowser-launcher
}

# ---------------------------------------------------------------------------
# 10. Vivaldi Stable (Deb)
# ---------------------------------------------------------------------------
prep_vivaldi() {
    curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-browser.gpg] https://repo.vivaldi.com/archive/deb/ stable main" \
        | sudo tee /etc/apt/sources.list.d/vivaldi-archive.list > /dev/null
    NEEDS_APT_UPDATE=1
}
install_vivaldi() {
    sudo apt install -y vivaldi-stable
}

# ---------------------------------------------------------------------------
# 11. Waterfox (Portable)
# ---------------------------------------------------------------------------
install_waterfox() {
    local waterfox_version="6.5.0"
    local file="$PKG_DIR/waterfox-$waterfox_version.tar.bz2"
    local url="https://cdn.waterfox.com/waterfox/releases/$waterfox_version/Linux_x86_64/waterfox-$waterfox_version.tar.bz2"

    wget -O "$file" "$url"
    sudo rm -rf /opt/waterfox
    tar -xjf "$file" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/waterfox" /opt/waterfox
    sudo ln -sf /opt/waterfox/waterfox /usr/local/bin/waterfox

    make_desktop_entry "Waterfox" "/opt/waterfox/waterfox" \
        "/opt/waterfox/browser/chrome/icons/default/default128.png" \
        "waterfox.desktop" "waterfox"
    set_default_browser "waterfox.desktop"
}

# ---------------------------------------------------------------------------
# 12. Zen Browser (Portable)
# ---------------------------------------------------------------------------
install_zen() {
    local file="$PKG_DIR/zen.linux-x86_64.tar.xz"
    wget -O "$file" https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz

    sudo rm -rf /opt/zen-browser
    tar -xf "$file" -C "$PKG_DIR"
    sudo mv "$PKG_DIR/zen" /opt/zen-browser
    sudo ln -sf /opt/zen-browser/zen /usr/local/bin/zen-browser

    make_desktop_entry "Zen Browser" "/opt/zen-browser/zen" \
        "/opt/zen-browser/browser/chrome/icons/default/default128.png" \
        "zen-browser.desktop" "zen"
    set_default_browser "zen-browser.desktop"
}

# ---------------------------------------------------------------------------
# 13. Baobab Disk Usage Analyzer (Deb)
# ---------------------------------------------------------------------------
install_baobab() {
    sudo apt install -y baobab
}

# ---------------------------------------------------------------------------
# 14. Bitwarden (Flatpak)
# ---------------------------------------------------------------------------
install_bitwarden() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.bitwarden.desktop
}

# ---------------------------------------------------------------------------
# 15. Bleachbit (Deb)
# ---------------------------------------------------------------------------
install_bleachbit() {
    sudo apt install -y bleachbit
}

# ---------------------------------------------------------------------------
# 16. Discord (Flatpak)
# ---------------------------------------------------------------------------
install_discord() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.discordapp.Discord
}

# ---------------------------------------------------------------------------
# 17. Flatseal (Flatpak)
# ---------------------------------------------------------------------------
install_flatseal() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal
}

# ---------------------------------------------------------------------------
# 18. Free Download Manager (Deb)
# ---------------------------------------------------------------------------
install_fdm() {
    wget -O "$PKG_DIR/freedownloadmanager.deb" \
        https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
    sudo apt install -y "$PKG_DIR/freedownloadmanager.deb"
}

# ---------------------------------------------------------------------------
# 19. Ghostwriter (Deb)
# ---------------------------------------------------------------------------
install_ghostwriter() {
    sudo apt install -y ghostwriter
}

# ---------------------------------------------------------------------------
# 20. GIMP (Deb)
# ---------------------------------------------------------------------------
install_gimp_deb() {
    sudo apt install -y gimp
}

# ---------------------------------------------------------------------------
# 21. GIMP (Flatpak)
# ---------------------------------------------------------------------------
install_gimp_flatpak() {
    ensure_flathub
    flatpak install -y --noninteractive flathub org.gimp.GIMP
}

# ---------------------------------------------------------------------------
# 22. Gnome Characters (Deb)
# ---------------------------------------------------------------------------
install_gnome_characters() {
    sudo apt install -y gnome-characters
}

# ---------------------------------------------------------------------------
# 23. Gnome Disk Utility (Deb)
# ---------------------------------------------------------------------------
install_gnome_disks() {
    sudo apt install -y gnome-disk-utility
}

# ---------------------------------------------------------------------------
# 24. GParted (Deb)
# ---------------------------------------------------------------------------
install_gparted() {
    sudo apt install -y gparted
}

# ---------------------------------------------------------------------------
# 25. GRUB Customizer (Deb)
# ---------------------------------------------------------------------------
install_grub_customizer() {
    sudo apt install -y grub-customizer
}

# ---------------------------------------------------------------------------
# 26. Gucharmap (Deb)
# ---------------------------------------------------------------------------
install_gucharmap() {
    sudo apt install -y gucharmap
}

# ---------------------------------------------------------------------------
# 27. Heroic Games Launcher (Deb)
# ---------------------------------------------------------------------------
install_heroic_deb() {
    local heroic_url heroic_file
    heroic_url=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest \
        | grep "browser_download_url" | grep "linux-amd64.deb" | cut -d '"' -f 4)
    heroic_file=$(basename "$heroic_url")
    wget -O "$PKG_DIR/$heroic_file" "$heroic_url"
    sudo apt install -y "$PKG_DIR/$heroic_file"
}

# ---------------------------------------------------------------------------
# 28. Heroic Games Launcher (Flatpak)
# ---------------------------------------------------------------------------
install_heroic_flatpak() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl
}

# ---------------------------------------------------------------------------
# 29. Inkscape (Deb)
# ---------------------------------------------------------------------------
install_inkscape() {
    sudo apt install -y inkscape
}

# ---------------------------------------------------------------------------
# 30. KeePassXC (Deb)
# ---------------------------------------------------------------------------
install_keepassxc() {
    sudo apt install -y keepassxc
}

# ---------------------------------------------------------------------------
# 31. Krita (Flatpak)
# ---------------------------------------------------------------------------
install_krita() {
    ensure_flathub
    flatpak install -y --noninteractive flathub org.kde.krita
}

# ---------------------------------------------------------------------------
# 32. LibreOffice (Deb)
# ---------------------------------------------------------------------------
install_libreoffice() {
    sudo apt install -y libreoffice libreoffice-gtk3
}

# ---------------------------------------------------------------------------
# 33. LocalSend (Deb)
# ---------------------------------------------------------------------------
install_localsend() {
    local localsend_url localsend_file
    localsend_url=$(curl -s https://api.github.com/repos/localsend/localsend/releases/latest \
        | grep "browser_download_url" | grep "linux-x86-64.deb" | cut -d '"' -f 4)
    localsend_file=$(basename "$localsend_url")
    wget -O "$PKG_DIR/$localsend_file" "$localsend_url"
    sudo apt install -y "$PKG_DIR/$localsend_file"
}

# ---------------------------------------------------------------------------
# 34. Lutris (Deb)
# ---------------------------------------------------------------------------
prep_lutris_deb() {
    sudo mkdir -p /etc/apt/keyrings
    echo -e "Types: deb\nURIs: https://download.opensuse.org/repositories/home:/strycore:/lutris/Debian_13/\nSuites: ./\nComponents:\nSigned-By: /etc/apt/keyrings/lutris.gpg" \
        | sudo tee /etc/apt/sources.list.d/lutris.sources > /dev/null
    wget -q -O- https://download.opensuse.org/repositories/home:/strycore:/lutris/Debian_13/Release.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/lutris.gpg
    NEEDS_APT_UPDATE=1
}
install_lutris_deb() {
    sudo apt install -y lutris
}

# ---------------------------------------------------------------------------
# 35. Lutris (Flatpak)
# ---------------------------------------------------------------------------
install_lutris_flatpak() {
    ensure_flathub
    flatpak install -y --noninteractive flathub net.lutris.Lutris
}

# ---------------------------------------------------------------------------
# 36. MenuLibre (Deb)
# ---------------------------------------------------------------------------
install_menulibre() {
    sudo apt install -y menulibre
}

# ---------------------------------------------------------------------------
# 37. MintStick (Deb)
# ---------------------------------------------------------------------------
install_mintstick() {
    sudo apt install -y mintstick
}

# ---------------------------------------------------------------------------
# 38. Mission Center (Flatpak)
# ---------------------------------------------------------------------------
install_mission_center() {
    ensure_flathub
    flatpak install -y --noninteractive flathub io.missioncenter.MissionCenter
}

# ---------------------------------------------------------------------------
# 39. OBS Studio (Flatpak)
# ---------------------------------------------------------------------------
install_obs() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.obsproject.Studio
}

# ---------------------------------------------------------------------------
# 40. Pinta (Flatpak)
# ---------------------------------------------------------------------------
install_pinta() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.github.PintaProject.Pinta
}

# ---------------------------------------------------------------------------
# 41. PowerISO (Flatpak)
# ---------------------------------------------------------------------------
install_poweriso() {
    ensure_flathub
    flatpak install -y --noninteractive flathub com.poweriso.PowerISO
}

# ---------------------------------------------------------------------------
# 42. qBittorrent (Deb)
# ---------------------------------------------------------------------------
install_qbittorrent() {
    sudo apt install -y qbittorrent
}

# ---------------------------------------------------------------------------
# 43. QEMU - CLI
# ---------------------------------------------------------------------------
install_qemu_cli() {
    sudo apt install -y qemu-system-x86 qemu-utils qemu-kvm
    sudo virsh net-autostart default
}

# ---------------------------------------------------------------------------
# 44. QEMU - Graphics Interface (virt-manager)
# ---------------------------------------------------------------------------
install_qemu_gui() {
    sudo apt install -y qemu-system-x86 qemu-utils qemu-kvm libvirt-daemon-system \
        libvirt-clients bridge-utils virt-manager
    sudo virsh net-autostart default
}

# ---------------------------------------------------------------------------
# 45. Signal (Deb)
# ---------------------------------------------------------------------------
prep_signal() {
    wget -qO- https://updates.signal.org/desktop/apt/keys.asc \
        | gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" \
        | sudo tee /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    NEEDS_APT_UPDATE=1
}
install_signal() {
    sudo apt install -y signal-desktop
}

# ---------------------------------------------------------------------------
# 46. Steam (Deb)
# ---------------------------------------------------------------------------
install_steam() {
    wget -O "$PKG_DIR/steam_latest.deb" \
        https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
    sudo apt install -y "$PKG_DIR/steam_latest.deb"
}

# ---------------------------------------------------------------------------
# 47. Sublime Text (Deb)
# ---------------------------------------------------------------------------
prep_sublime() {
    sudo mkdir -p /etc/apt/keyrings
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
        | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' \
        | sudo tee /etc/apt/sources.list.d/sublime-text.sources > /dev/null
    NEEDS_APT_UPDATE=1
}
install_sublime() {
    sudo apt install -y sublime-text
}

# ---------------------------------------------------------------------------
# 48. Telegram (Flatpak)
# ---------------------------------------------------------------------------
install_telegram() {
    ensure_flathub
    flatpak install -y --noninteractive flathub org.telegram.desktop
}

# ---------------------------------------------------------------------------
# 49. Thunderbird (Deb)
# ---------------------------------------------------------------------------
install_thunderbird() {
    sudo apt install -y thunderbird
}

# ---------------------------------------------------------------------------
# 50. Timeshift (Deb)
# ---------------------------------------------------------------------------
install_timeshift() {
    sudo apt install -y timeshift
}

# ---------------------------------------------------------------------------
# 51. Unrar free (Deb)
# ---------------------------------------------------------------------------
install_unrar_free() {
    sudo apt install -y unrar-free
}

# ---------------------------------------------------------------------------
# 52. Unrar nonfree (Deb)
# ---------------------------------------------------------------------------
install_unrar_nonfree() {
    sudo apt install -y unrar
}

# ---------------------------------------------------------------------------
# 53. VirtualBox (Deb)
# ---------------------------------------------------------------------------
install_virtualbox() {
    # Requires the "contrib" component enabled in /etc/apt/sources.list on Debian.
    sudo apt install -y virtualbox
}

# ---------------------------------------------------------------------------
# 54. VLC Media Player (Deb)
# ---------------------------------------------------------------------------
install_vlc() {
    sudo apt install -y vlc
}

# ---------------------------------------------------------------------------
# 55. VS Code (Deb)
# ---------------------------------------------------------------------------
prep_vscode() {
    sudo install -m 0755 -d /etc/apt/keyrings
    wget -qO- https://packages.microsoft.com/keys.microsoft.asc \
        | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    NEEDS_APT_UPDATE=1
}
install_vscode() {
    sudo apt install -y code
}

# ---------------------------------------------------------------------------
# 56. WineHQ Stable (Deb)
# ---------------------------------------------------------------------------
prep_winehq() {
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    # Using bookworm repo: WineHQ has not published trixie sources yet.
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
    NEEDS_APT_UPDATE=1
}
install_winehq() {
    sudo apt install -y --install-recommends winehq-stable
}

# ---------------------------------------------------------------------------
# 57. Wireshark (Deb)
# ---------------------------------------------------------------------------
install_wireshark() {
    sudo apt install -y wireshark
}

# ---------------------------------------------------------------------------
# 58. XFCE4 Task Manager (Deb)
# ---------------------------------------------------------------------------
install_xfce4_taskmanager() {
    sudo apt install -y --no-install-recommends xfce4-taskmanager
}

# ---------------------------------------------------------------------------
# Program registry (order shown in the checklist)
# ---------------------------------------------------------------------------
ORDERED_IDS=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 \
             21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 \
             41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58)

declare -A LABEL PREP_FN INSTALL_FN

LABEL[01]="Brave Browser (Deb)";                       INSTALL_FN[01]="install_brave";           PREP_FN[01]="prep_brave"
LABEL[02]="Chromium (Deb)";                            INSTALL_FN[02]="install_chromium"
LABEL[03]="Firefox ESR (Deb)";                         INSTALL_FN[03]="install_firefox_esr"
LABEL[04]="Firefox (Portable)";                        INSTALL_FN[04]="install_firefox_portable"
LABEL[05]="Floorp Browser (Portable)";                 INSTALL_FN[05]="install_floorp_portable"
LABEL[06]="Floorp Browser (Deb)";                      INSTALL_FN[06]="install_floorp_deb";      PREP_FN[06]="prep_floorp_deb"
LABEL[07]="Google Chrome (Deb)";                       INSTALL_FN[07]="install_chrome"
LABEL[08]="Opera Stable (Deb)";                        INSTALL_FN[08]="install_opera";           PREP_FN[08]="prep_opera"
LABEL[09]="Tor Browser (Deb)";                         INSTALL_FN[09]="install_tor"
LABEL[10]="Vivaldi Stable (Deb)";                      INSTALL_FN[10]="install_vivaldi";         PREP_FN[10]="prep_vivaldi"
LABEL[11]="Waterfox (Portable)";                       INSTALL_FN[11]="install_waterfox"
LABEL[12]="Zen Browser (Portable)";                    INSTALL_FN[12]="install_zen"
LABEL[13]="Baobab Disk Usage Analyzer (Deb)";          INSTALL_FN[13]="install_baobab"
LABEL[14]="Bitwarden (Flatpak)";                       INSTALL_FN[14]="install_bitwarden"
LABEL[15]="Bleachbit (Deb)";                           INSTALL_FN[15]="install_bleachbit"
LABEL[16]="Discord (Flatpak)";                         INSTALL_FN[16]="install_discord"
LABEL[17]="Flatseal (Flatpak)";                        INSTALL_FN[17]="install_flatseal"
LABEL[18]="Free Download Manager (Deb)";               INSTALL_FN[18]="install_fdm"
LABEL[19]="Ghostwriter (Deb)";                         INSTALL_FN[19]="install_ghostwriter"
LABEL[20]="GIMP (Deb)";                                INSTALL_FN[20]="install_gimp_deb"
LABEL[21]="GIMP (Flatpak)";                            INSTALL_FN[21]="install_gimp_flatpak"
LABEL[22]="Gnome Characters (Deb)";                    INSTALL_FN[22]="install_gnome_characters"
LABEL[23]="Gnome Disk Utility (Deb)";                  INSTALL_FN[23]="install_gnome_disks"
LABEL[24]="GParted (Deb)";                             INSTALL_FN[24]="install_gparted"
LABEL[25]="GRUB Customizer (Deb)";                     INSTALL_FN[25]="install_grub_customizer"
LABEL[26]="Gucharmap (Deb)";                           INSTALL_FN[26]="install_gucharmap"
LABEL[27]="Heroic Games Launcher (Deb)";               INSTALL_FN[27]="install_heroic_deb"
LABEL[28]="Heroic Games Launcher (Flatpak)";           INSTALL_FN[28]="install_heroic_flatpak"
LABEL[29]="Inkscape (Deb)";                            INSTALL_FN[29]="install_inkscape"
LABEL[30]="KeePassXC (Deb)";                           INSTALL_FN[30]="install_keepassxc"
LABEL[31]="Krita (Flatpak)";                           INSTALL_FN[31]="install_krita"
LABEL[32]="LibreOffice (Deb)";                         INSTALL_FN[32]="install_libreoffice"
LABEL[33]="LocalSend (Deb)";                           INSTALL_FN[33]="install_localsend"
LABEL[34]="Lutris (Deb)";                              INSTALL_FN[34]="install_lutris_deb";      PREP_FN[34]="prep_lutris_deb"
LABEL[35]="Lutris (Flatpak)";                          INSTALL_FN[35]="install_lutris_flatpak"
LABEL[36]="MenuLibre (Deb)";                           INSTALL_FN[36]="install_menulibre"
LABEL[37]="MintStick (Deb)";                           INSTALL_FN[37]="install_mintstick"
LABEL[38]="Mission Center (Flatpak)";                  INSTALL_FN[38]="install_mission_center"
LABEL[39]="OBS Studio (Flatpak)";                      INSTALL_FN[39]="install_obs"
LABEL[40]="Pinta (Flatpak)";                           INSTALL_FN[40]="install_pinta"
LABEL[41]="PowerISO (Flatpak)";                        INSTALL_FN[41]="install_poweriso"
LABEL[42]="qBittorrent (Deb)";                         INSTALL_FN[42]="install_qbittorrent"
LABEL[43]="QEMU - CLI";                                INSTALL_FN[43]="install_qemu_cli"
LABEL[44]="QEMU - Graphics Interface (virt-manager)";  INSTALL_FN[44]="install_qemu_gui"
LABEL[45]="Signal (Deb)";                              INSTALL_FN[45]="install_signal";          PREP_FN[45]="prep_signal"
LABEL[46]="Steam (Deb)";                               INSTALL_FN[46]="install_steam"
LABEL[47]="Sublime Text (Deb)";                        INSTALL_FN[47]="install_sublime";         PREP_FN[47]="prep_sublime"
LABEL[48]="Telegram (Flatpak)";                        INSTALL_FN[48]="install_telegram"
LABEL[49]="Thunderbird (Deb)";                         INSTALL_FN[49]="install_thunderbird"
LABEL[50]="Timeshift (Deb)";                           INSTALL_FN[50]="install_timeshift"
LABEL[51]="Unrar free (Deb)";                          INSTALL_FN[51]="install_unrar_free"
LABEL[52]="Unrar nonfree (Deb)";                       INSTALL_FN[52]="install_unrar_nonfree"
LABEL[53]="VirtualBox (Deb)";                          INSTALL_FN[53]="install_virtualbox"
LABEL[54]="VLC Media Player (Deb)";                    INSTALL_FN[54]="install_vlc"
LABEL[55]="VS Code (Deb)";                             INSTALL_FN[55]="install_vscode";          PREP_FN[55]="prep_vscode"
LABEL[56]="WineHQ Stable (Deb)";                       INSTALL_FN[56]="install_winehq";          PREP_FN[56]="prep_winehq"
LABEL[57]="Wireshark (Deb)";                           INSTALL_FN[57]="install_wireshark"
LABEL[58]="XFCE4 Task Manager (Deb)";                  INSTALL_FN[58]="install_xfce4_taskmanager"

# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

show_checklist() {
    local args=()
    for id in "${ORDERED_IDS[@]}"; do
        args+=("$id" "${LABEL[$id]}" "OFF")
    done

    whiptail --title "SatellaOS Program Installer" \
        --checklist "Select the programs you want to install:\n(SPACE: Select | ENTER: Confirm | TAB: Switch)" \
        24 78 16 "${args[@]}" \
        3>&1 1>&2 2>&3
}

main() {
    local raw_selection status
    raw_selection=$(show_checklist)
    status=$?

    if [ $status -ne 0 ] || [ -z "$raw_selection" ]; then
        echo "Cancelled, no programs were selected."
        exit 0
    fi

    local selected_ids
    read -r -a selected_ids <<< "$(echo "$raw_selection" | tr -d '"')"

    local names=""
    for id in "${selected_ids[@]}"; do
        names+="  - ${LABEL[$id]}\n"
    done

    whiptail --title "Confirm" --yesno "The following programs will be installed:\n\n$(echo -e "$names")\nDo you want to proceed?" 22 78
    if [ $? -ne 0 ]; then
        echo "Cancelled."
        exit 0
    fi

    # Phase 1: repo/key preparation for deb-based tools that need it
    for id in "${selected_ids[@]}"; do
        local prep="${PREP_FN[$id]:-}"
        if [ -n "$prep" ]; then
            echo -e "\n==> Preparing repository for: ${LABEL[$id]}"
            "$prep"
        fi
    done

    if [ "$NEEDS_APT_UPDATE" -eq 1 ]; then
        echo -e "\n==> Running apt update"
        sudo apt update
    fi

    # Phase 2: actual installation, one program after another
    local failed=()
    for id in "${selected_ids[@]}"; do
        echo -e "\n==> Installing: ${LABEL[$id]}"
        if ! "${INSTALL_FN[$id]}"; then
            failed+=("${LABEL[$id]}")
        fi
    done

    echo
    if [ ${#failed[@]} -eq 0 ]; then
        whiptail --msgbox "All selected programs were installed successfully." 8 60
    else
        local fail_list=""
        for name in "${failed[@]}"; do
            fail_list+="  - $name\n"
        done
        whiptail --msgbox "Installation finished, but the following programs failed:\n\n$(echo -e "$fail_list")" 18 70
    fi
}

main