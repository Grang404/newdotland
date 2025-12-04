#!/bin/bash

detect_battery() {
    [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]
}

detect_monitors() {
    if command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null 2>&1; then
        hyprctl monitors -j | jq -r '
          .[] |
          "\(.name)|\(.width)|\(.height)|\(.refreshRate)"
        '
    else
        for status_file in /sys/class/drm/card*/card*/status; do
            if [[ -f "$status_file" ]] && grep -q "^connected" "$status_file" 2>/dev/null; then
                monitor_name=$(basename "$(dirname "$status_file")" | sed 's/card[0-9]*-//')
                echo "$monitor_name|0|0|0"
            fi
        done
    fi
}

detect_gpu() {
    local gpu_info
    gpu_info=$(lspci | grep -i vga)

    if echo "$gpu_info" | grep -qi nvidia; then
        echo "nvidia"
    elif echo "$gpu_info" | grep -qi amd; then
        echo "amd"
    elif echo "$gpu_info" | grep -qi intel; then
        echo "intel"
    else
        echo "unknown"
    fi
}

detect_profile() {
    if detect_battery; then
        echo "laptop"
    elif [[ $MONITOR_COUNT -gt 1 ]]; then
        echo "desktop-multi"
    else
        echo "desktop-single"
    fi
}

mapfile -t MONITOR_DATA < <(detect_monitors)

# Sort monitors by score (best to worst)
mapfile -t MONITOR_DATA < <(
    for entry in "${MONITOR_DATA[@]}"; do
        IFS='|' read -r name w h r <<<"$entry"
        score=$(awk "BEGIN { printf \"%.0f\", $w * $h * $r }")
        echo "$score|$entry"
    done | sort -t'|' -k1 -rn | cut -d'|' -f2-
)

export MONITOR_DATA

# Build MONITORS array from sorted data
MONITORS=()
for entry in "${MONITOR_DATA[@]}"; do
    IFS='|' read -r name w h r <<<"$entry"
    MONITORS+=("$name")
done

export MONITOR_COUNT=${#MONITORS[@]}
export MONITORS

export HAS_BATTERY
HAS_BATTERY=$(detect_battery && echo "true" || echo "false")

export GPU
GPU=$(detect_gpu)

export PROFILE
PROFILE=$(detect_profile)

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Hardware Detection ==="
    echo "Profile: $PROFILE"
    echo "Battery: $HAS_BATTERY"
    echo "GPU: $GPU"
    echo "Monitors ($MONITOR_COUNT): ${MONITORS[*]}"
    echo "Primary: ${MONITORS[0]}"
fi
