#!/bin/bash
# Debian Font Installer (Whiptail TUI Edition)
# Requires: whiptail, sudo

set -e
set -u

# Install whiptail if it is not already installed
if ! command -v whiptail &>/dev/null; then
    sudo apt update && sudo apt install -y whiptail
fi

# ============================================================
# Whiptail Interface Selection Menu
# ============================================================
CHOICES=$(whiptail --title "SatellaOS Font Installer" \
    --checklist "Select the font groups you want to install:\n(SPACE: Select | ENTER: Confirm | TAB: Switch)" \
    19 76 9 \
    "1" "Basic Latin / UI fonts"          OFF \
    "2" "Noto (Universal coverage)"       OFF \
    "3" "Arabic / Persian / RTL"          OFF \
    "4" "Indic languages (India)"         OFF \
    "5" "Southeast Asian"                 OFF \
    "6" "Japanese"                        OFF \
    "7" "Korean"                          OFF \
    "8" "Chinese"                         OFF \
    "9" "Symbols / Emoji / Math"          OFF \
    3>&1 1>&2 2>&3) || { exit 0; }

# Sanitize and sort the selections
SELECTIONS=$(echo "$CHOICES" | tr -d '"' | tr ' ' '\n' | sort -n)

if [[ -z "$SELECTIONS" ]]; then
    exit 0
fi

# ============================================================
# Font Package Definitions (Arrays)
# ============================================================

# 1) Basic Latin / UI
latin_fonts=(
  fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-dejavu-mono
  fonts-liberation fonts-liberation-sans-narrow
  fonts-lato fonts-freefont-ttf fonts-unifont fonts-urw-base35
  fonts-quicksand fonts-vlgothic fonts-yrsa-rasa
)

# 2) Noto (Universal coverage)
noto_fonts=(
  fonts-noto fonts-noto-core fonts-noto-extra
  fonts-noto-ui-core fonts-noto-ui-extra
  fonts-noto-mono fonts-noto-unhinted
  fonts-noto-cjk fonts-noto-cjk-extra
  fonts-noto-color-emoji
)

# 3) Arabic / Persian / RTL
rtl_fonts=(
  fonts-arabeyes fonts-farsiweb fonts-hosny-amiri fonts-hosny-thabit
  fonts-sil-scheherazade fonts-sil-andika fonts-ukij-uyghur
  fonts-unikurdweb fonts-vazirmatn-variable fonts-sahel-variable
)

# 4) Indic languages (India)
indic_fonts=(
  fonts-deva fonts-deva-extra fonts-gargi fonts-sahadeva fonts-sil-annapurna
  fonts-samyak-deva fonts-lohit-deva fonts-kalapi fonts-nakula 
  fonts-gujr fonts-gujr-extra fonts-lohit-gujr fonts-samyak-gujr
  fonts-guru fonts-guru-extra fonts-lohit-guru fonts-lohit-knda
  fonts-taml fonts-lohit-taml fonts-lohit-taml-classical fonts-samyak-taml
  fonts-telu fonts-telu-extra fonts-lohit-telu fonts-teluguvijayam
  fonts-mlym fonts-lohit-mlym fonts-samyak-mlym fonts-smc
  fonts-smc-anjalioldlipi fonts-smc-chilanka fonts-smc-dyuthi
  fonts-smc-gayathri fonts-smc-karumbi fonts-smc-keraleeyam
  fonts-smc-manjari fonts-smc-meera fonts-smc-rachana
  fonts-smc-raghumalayalamsans fonts-smc-suruma fonts-smc-uroob
  fonts-beng fonts-beng-extra fonts-lohit-beng-bengali fonts-lohit-beng-assamese
)

# 5) Southeast Asian
sea_fonts=(
  fonts-thai-tlwg fonts-arundina fonts-tlwg-garuda fonts-tlwg-garuda-ttf
  fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf
  fonts-tlwg-loma fonts-tlwg-loma-ttf fonts-tlwg-mono fonts-tlwg-mono-ttf
  fonts-tlwg-norasi fonts-tlwg-norasi-ttf fonts-tlwg-purisa fonts-tlwg-purisa-ttf
  fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf
  fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf
  fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf
  fonts-khmeros fonts-dzongkha
)

# 6) Japanese
japanese_fonts=(
  fonts-ipafont fonts-ipafont-gothic fonts-ipafont-mincho fonts-takao
)

# 7) Korean
korean_fonts=(
  fonts-nanum fonts-unfonts-core
)

# 8) Chinese
chinese_fonts=(
  fonts-wqy-zenhei fonts-arphic-ukai fonts-arphic-uming
)

# 9) Symbols / Emoji / Math
symbol_fonts=(
  fonts-font-awesome fonts-symbola fonts-opensymbol
  fonts-mathjax fonts-droid-fallback fonts-sarai
  fonts-culmus fonts-bpg-georgian fonts-sil-abyssinica
)

# ============================================================
# Mapping Selections to the Package List
# ============================================================
selected_packages=()

for choice in $SELECTIONS; do
  case "$choice" in
    1) selected_packages+=("${latin_fonts[@]}") ;;
    2) selected_packages+=("${noto_fonts[@]}") ;;
    3) selected_packages+=("${rtl_fonts[@]}") ;;
    4) selected_packages+=("${indic_fonts[@]}") ;;
    5) selected_packages+=("${sea_fonts[@]}") ;;
    6) selected_packages+=("${japanese_fonts[@]}") ;;
    7) selected_packages+=("${korean_fonts[@]}") ;;
    8) selected_packages+=("${chinese_fonts[@]}") ;;
    9) selected_packages+=("${symbol_fonts[@]}") ;;
  esac
done

if [ ${#selected_packages[@]} -eq 0 ]; then
    echo "No fonts selected. Exiting."
    exit 0
fi

# ============================================================
# Installation Phase
# ============================================================
echo "Updating package lists..."
sudo apt update

echo "Installing selected font packages..."
sudo apt install -y "${selected_packages[@]}"

echo "Font installation completed successfully! ✓"