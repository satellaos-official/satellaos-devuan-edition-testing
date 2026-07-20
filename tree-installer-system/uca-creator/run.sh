#!/bin/bash

# ============================================================
#  Thunar Custom Actions (uca.xml) Generator
#  For Debian / XFCE (Whiptail TUI Edition - Direct Mode)
# ============================================================

set -e
set -u

# ============================================================
# Action Selection Menu via Whiptail
# ============================================================

CHOICES=$(whiptail --title "SatellaOS UCA Creator" \
    --checklist "Select the actions you want to add:\n(SPACE: Select | ENTER: Confirm | TAB: Switch)" \
    23 76 13 \
    "1" "Open Terminal Here"                    OFF \
    "2" "Open as Root"                         OFF \
    "3" "Create a Link"                        OFF \
    "4" "Verify (ISO files)"                   OFF \
    "5" "Share with LocalSend"                 OFF \
    "6" "Run Python Script [Submenu]"          OFF \
    "7" "Run Python Script (No Log) [Submenu]" OFF \
    "8" "Run Python Script (No Term) [Submenu]" OFF \
    "9" "Run Bash Script [Submenu]"            OFF \
    "10" "Run Bash Script (No Log) [Submenu]"  OFF \
    "11" "Run Bash Script (No Terminal) [Submenu]"  OFF \
    "12" "Install .deb Package [Submenu]"      OFF \
    "13" "Install .deb Package (No Log) [Sub"  OFF \
    3>&1 1>&2 2>&3) || { exit 0; }

# Clean and sort the selections
SELECTIONS=$(echo "$CHOICES" | tr -d '"' | tr ' ' '\n' | sort -n)

if [[ -z "$SELECTIONS" ]]; then
    exit 0
fi

# ============================================================
# XML Action Definitions
# ============================================================

action_1='	<action>
		<icon>utilities-terminal</icon>
		<name>Open Terminal Here</name>
		<submenu></submenu>
		<unique-id>1769597937281634-1</unique-id>
		<command>exo-open --working-directory %f --launch TerminalEmulator</command>
		<description>Open terminal in the selected folder</description>
		<range></range>
		<patterns>*</patterns>
		<startup-notify/>
		<directories/>
	</action>'

action_2='	<action>
		<icon>folder-violet</icon>
		<name>Open as Root</name>
		<submenu></submenu>
		<unique-id>1770219086580287-1</unique-id>
		<command>pkexec thunar %F</command>
		<description>Open the folder with administration privileges</description>
		<range></range>
		<patterns>*</patterns>
		<directories/>
	</action>'

action_3='	<action>
		<icon>emblem-symbolic-link</icon>
		<name>Create a Link</name>
		<submenu></submenu>
		<unique-id>1770219212901542-2</unique-id>
		<command>ln -s %f &apos;Link to %n&apos;</command>
		<description>Create a symbolic link for each selected item</description>
		<range></range>
		<patterns>*</patterns>
		<directories/>
		<other-files/>
	</action>'

action_4='	<action>
		<icon>view-certificate</icon>
		<name>Verify (ISO files)</name>
		<submenu></submenu>
		<unique-id>1770219273064615-3</unique-id>
		<command>mint-iso-verify %f</command>
		<description>Verify the authenticity and integrity of the image</description>
		<range></range>
		<patterns>*.iso;*.ISO</patterns>
		<audio-files/>
		<image-files/>
		<other-files/>
		<video-files/>
	</action>'

action_5='	<action>
		<icon>localsend_app</icon>
		<name>Share with LocalSend</name>
		<submenu></submenu>
		<unique-id>1772531131988710-1</unique-id>
		<command>localsend_app %F || flatpak run org.localsend.localsend_app %F</command>
		<description>Send selected files to local devices via LocalSend</description>
		<range>*</range>
		<patterns>*</patterns>
		<directories/>
		<audio-files/>
		<image-files/>
		<other-files/>
		<text-files/>
		<video-files/>
	</action>'

action_6='	<action>
		<icon>python</icon>
		<name>Run Python Script</name>
		<submenu>Python</submenu>
		<unique-id>1776434918635266-6</unique-id>
		<command>xfce4-terminal --hold --command=DQUOT;python3 %fDQUOT;</command>
		<description>Run Python script in terminal (keeps terminal open)</description>
		<range>*</range>
		<patterns>*.py</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_7='	<action>
		<icon>python</icon>
		<name>Run Python Script (No Log)</name>
		<submenu>Python</submenu>
		<unique-id>1776433126123484-1</unique-id>
		<command>xfce4-terminal -e DQUOT;bash -c '\''python3 %f; exit'\''DQUOT;</command>
		<description>Run Python script in terminal (closes when done)</description>
		<range>*</range>
		<patterns>*.py</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_8='	<action>
		<icon>python</icon>
		<name>Run Python Script (No Terminal)</name>
		<submenu>Python</submenu>
		<unique-id>1776434918635266-8</unique-id>
		<command>python3 %f</command>
		<description>Run Python script directly without opening a terminal</description>
		<range>*</range>
		<patterns>*.py</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_9='	<action>
		<icon>utilities-terminal</icon>
		<name>Run Bash Script</name>
		<submenu>Bash</submenu>
		<unique-id>1776434619126830-5</unique-id>
		<command>xfce4-terminal --hold --command=DQUOT;bash %fDQUOT;</command>
		<description>Run Bash script in terminal (keeps terminal open)</description>
		<range>*</range>
		<patterns>*.sh</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_10='	<action>
		<icon>utilities-terminal</icon>
		<name>Run Bash Script (No Log)</name>
		<submenu>Bash</submenu>
		<unique-id>1776433216082635-2</unique-id>
		<command>xfce4-terminal -e DQUOT;bash -c '\''bash %f; exit'\''DQUOT;</command>
		<description>Run Bash script in terminal (closes when done)</description>
		<range>*</range>
		<patterns>*.sh</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_11='	<action>
		<icon>utilities-terminal</icon>
		<name>Run Bash Script (No Terminal)</name>
		<submenu>Bash</submenu>
		<unique-id>1776433216082635-2</unique-id>
		<command>bash DQUOT;bash %fDQUOT;</command>
		<description>Run Bash script in terminal (closes when done)</description>
		<range>*</range>
		<patterns>*.sh</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_12='	<action>
		<icon>distributor-logo-debian</icon>
		<name>Install .deb Package</name>
		<submenu>Debian</submenu>
		<unique-id>1776433572647529-3</unique-id>
		<command>xfce4-terminal --hold --command=DQUOT;sudo apt install --no-install-recommends -y %fDQUOT;</command>
		<description>Install Debian package (keeps terminal open)</description>
		<range>*</range>
		<patterns>*.deb</patterns>
		<other-files/>
		<text-files/>
	</action>'

action_13='	<action>
		<icon>distributor-logo-debian</icon>
		<name>Install .deb Package (No Log)</name>
		<submenu>Debian</submenu>
		<unique-id>1776434074190285-4</unique-id>
		<command>xfce4-terminal -e DQUOT;bash -c '\''sudo apt install --no-install-recommends -y %f; exit'\''DQUOT;</command>
		<description>Install Debian package (closes when done)</description>
		<range>*</range>
		<patterns>*.deb</patterns>
		<other-files/>
		<text-files/>
	</action>'

# ============================================================
# Generate XML
# ============================================================

OUTPUT_DIR="$HOME/.config/Thunar"
OUTPUT_FILE="$OUTPUT_DIR/uca.xml"

SKEL_DIR="/etc/skel/.config/Thunar"
SKEL_FILE="$SKEL_DIR/uca.xml"

mkdir -p "$OUTPUT_DIR"

{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<actions>'

    for num in $SELECTIONS; do
        eval "echo \"\$action_$num\""
    done

    echo '</actions>'
} | sed 's/DQUOT;/\&quot;/g' > "$OUTPUT_FILE"

# Try to write to /etc/skel/ (System default for new users)
sudo mkdir -p "$SKEL_DIR" 2>/dev/null && sudo cp "$OUTPUT_FILE" "$SKEL_FILE" 2>/dev/null || true

exit 0