#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Source detection
source "$DOTFILES_DIR/detect.sh"

declare -A MONITOR_INFO

# Reset array from detect.sh
MONITORS=()

for entry in "${MONITOR_DATA[@]}"; do
    IFS='|' read -r name w h r <<<"$entry"
    MONITORS+=("$name")
    MONITOR_INFO["$name"]="width=$w;height=$h;refresh=$r"
done

generate_monitor_config() {
    local config=""
    local x_offset=0
    local ordered_monitors=("$PRIMARY_MONITOR")

    for name in "${MONITORS[@]}"; do
        [[ "$name" == "$PRIMARY_MONITOR" ]] && continue
        ordered_monitors+=("$name")
    done

    local width height refresh
    for name in "${ordered_monitors[@]}"; do
        eval "${MONITOR_INFO[$name]}"

        config+="monitor = $name,${width}x${height}@${refresh},${x_offset}x0,1\n"
        x_offset=$((x_offset + width))
    done

    echo -e "$config"
}

generate_monitor_config
