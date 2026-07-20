#!/bin/bash

# =============================================================================
# Source Script
# =============================================================================

bash "$HOME/satellaos-devuan-edition-testing/tree-installer-system/source/run.sh"
source "$HOME/.satellaos-source/installer"

# =============================================================================
# Log System
# =============================================================================

LOG_DIR="$HOME/.log-$project_name/logs"
MASTER_LOG="$LOG_DIR/install.log"
FAILED_STEPS=()

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MASTER_LOG"
}

run_step() {
    local step_num="$1"
    local step_name="$2"
    local cmd="$3"
    local optional="${4:-false}"
    local step_log="$LOG_DIR/${step_num}-${step_name}.log"

    log "--------------------------------------------------------------"
    log "START  >> Step $step_num: $step_name"

    if (set -o pipefail; eval "$cmd" 2>&1 | tee "$step_log"); then
        log "OK     >> Step $step_num: $step_name"
    else
        local exit_code=$?
        log "FAILED >> Step $step_num: $step_name (exit code: $exit_code)"
        log "         Log: $step_log"

        if [ "$optional" = "true" ]; then
            log "INFO   >> Step $step_num is optional, continuing..."
        else
            FAILED_STEPS+=("$step_num-$step_name")
            log "ERROR  >> Non-optional step failed. Aborting."
            log "--------------------------------------------------------------"
            print_summary
            exit 1
        fi
    fi
}

print_summary() {
    log "=============================================================="
    log "INSTALL SUMMARY"
    log "=============================================================="
    if [ ${#FAILED_STEPS[@]} -eq 0 ]; then
        log "STATUS: All steps completed successfully."
    else
        log "STATUS: Installation failed."
        log "Failed steps:"
        for step in "${FAILED_STEPS[@]}"; do
            log "  - $step"
        done
    fi
    log "Master log : $MASTER_LOG"
    log "Step logs  : $LOG_DIR/"
    log "=============================================================="
}

# =============================================================================
# Main
# =============================================================================

log "=============================================================="
log "Installing The SatellaOS System"
log "=============================================================="

# =============================================================================
# Steps
# optional=true  → failure is logged but install continues
# optional=false → failure aborts the install (default)
# =============================================================================

run_step "01" "seatd-installer"           "bash    $script_source/seatd-installer/run.sh"
run_step "02" "update-adduser"            "bash    $script_source/update-adduser/run.sh"
run_step "03" "network-manager"           "bash    $script_source/network-manager/run.sh"
run_step "04" "clean-network-interfaces"  "bash    $script_source/clean-network-interfaces/run.sh"
run_step "05" "update-sources-list"       "bash    $script_source/update-sources.list/run.sh"
run_step "06" "core"                      "bash    $script_source/core/run.sh"
run_step "07" "extra-packages"            "bash    $script_source/extra-packages/run.sh"
run_step "08" "flatpak-installer"         "bash    $script_source/flatpak-installer/run.sh"
run_step "09" "update-os-release"         "bash    $script_source/update-os-release/run.sh"
run_step "10" "silent-kernel"             "bash    $script_source/silent-kernel/run.sh"
run_step "11" "grub-settings"             "bash    $script_source/grub-settings/run.sh"
run_step "12" "grub-theme"                "bash    $script_source/grub-theme/run.sh"
run_step "13" "lightdm-settings"          "bash    $script_source/lightdm-settings/run.sh"
run_step "14" "update-user-configuration" "bash    $script_source/update-user-configuration/run.sh"
run_step "15" "update-root-configuration" "bash    $script_source/update-root-configuration/run.sh"
run_step "16" "pictures"                  "bash    $script_source/pictures/run.sh"
run_step "17" "papirus"                   "bash    $script_source/themes/run-part1.sh"
run_step "18" "fluent"                    "bash    $script_source/themes/run-part2.sh"
run_step "19" "theme-dependencies"        "bash    $script_source/themes/run-part3.sh"
run_step "20" "uca-creator"               "bash    $script_source/uca-creator/run.sh"
run_step "21" "driver-installer"          "bash    $script_source/driver-installer/run.sh"
run_step "22" "font-installer"            "bash    $script_source/font-installer/run.sh"
run_step "23" "program-installer"         "bash    $script_source/program-installer/run.sh"
run_step "24" "fastfetch"                 "bash    $script_source/fastfetch/run.sh"

print_summary