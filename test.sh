#!/bin/bash
# test_detect.sh - Hardcoded test data for testing monitor configurations

# Hardcoded monitor data (name|width|height|refresh)
MONITOR_DATA=(
    "DP-2|2560|1440|144"
)

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

# Hardcoded values for testing
export HAS_BATTERY="false"
export GPU="nvidia"
export PROFILE="desktop-multi"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Hardware Detection (TEST DATA) ==="
    echo "Profile: $PROFILE"
    echo "Battery: $HAS_BATTERY"
    echo "GPU: $GPU"
    echo "Monitors ($MONITOR_COUNT): ${MONITORS[*]}"
    echo "Primary: ${MONITORS[0]}"
    echo ""
    echo "Monitor details (sorted by score):"
    for entry in "${MONITOR_DATA[@]}"; do
        IFS='|' read -r name w h r <<<"$entry"
        score=$(awk "BEGIN { printf \"%.0f\", $w * $h * $r }")
        echo "  $name: ${w}x${h}@${r} (score: $score)"
    done
fi
