#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Source detection
source "$DOTFILES_DIR/detect.sh"
# source "$DOTFILES_DIR/test.sh"

declare -A MONITOR_INFO

# Build MONITOR_INFO from sorted MONITOR_DATA
# MONITORS array is already sorted best to worst from detect.sh
for entry in "${MONITOR_DATA[@]}"; do
    IFS='|' read -r name w h r <<<"$entry"
    MONITOR_INFO["$name"]="width=$w;height=$h;refresh=$r"
done

generate_monitor_config() {
    local config=""
    local x_offset=0
    local width height refresh

    # MONITORS is already sorted, just iterate through it
    for name in "${MONITORS[@]}"; do
        eval "${MONITOR_INFO[$name]}"
        config+="monitor = $name,${width}x${height}@${refresh},${x_offset}x0,1\n"
        x_offset=$((x_offset + width))
    done
    printf "%b" "$config"
}

generate_workspace_config() {
    local config=""

    if [[ $MONITOR_COUNT -eq 1 ]]; then
        for i in {1..10}; do
            config+="workspace = $i"$'\n'
        done

    elif [[ $MONITOR_COUNT -gt 1 ]]; then
        echo "Workspace configuration"
        echo "1) Groob"
        echo "2) Sol"
        read -rp $'Pick an option 1-2\n' choice

        # Groob
        if [[ $choice -eq 1 ]]; then
            for i in {1..5}; do
                config+="workspace = $i, monitor:${MONITORS[0]}, default:true"$'\n'
            done

            for i in {6..10}; do
                config+="workspace = $i, monitor:${MONITORS[1]}, default:true"$'\n'
            done
        fi

        # Sol
        if [[ $choice -eq 2 ]]; then
            if [[ $MONITOR_COUNT -eq 2 ]]; then
                for i in {1..3}; do
                    config+="workspace = $i, monitor:${MONITORS[0]}, default:true"$'\n'
                done

                for i in {4..6}; do
                    config+="workspace = $i, monitor:${MONITORS[1]}, default:true"$'\n'
                done

                for i in {7..9}; do
                    config+="workspace = $i"$'\n'
                done

            elif [[ $MONITOR_COUNT -gt 2 ]]; then
                for in {1..2}; do
                    config+="workspace = $i, monitor:${MONITORS[0]}, default:true"$'\n'
                done

                for i in {3..4}; do
                    config+="workspace = $i, monitor:${MONITORS[1]}, default:true"$'\n'
                done

                for i in {5..6}; do
                    config+="workspace = $i, monitor:${MONITORS[2]}, default:true"$'\n'
                done

                for i in {7..9}; do
                    config+="workspace = $i"$'\n'
                done
            fi
        else
            echo -e "Please pick from a valid option"
        fi
    fi

    printf "%s" "$config"

}

generate_workspace_config

# MONITOR_CONFIG=$(generate_monitor_config)
# export MONITOR_CONFIG

# envsubst <"./monitors.conf.template" >"./monitors.conf"
