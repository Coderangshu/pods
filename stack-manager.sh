#!/bin/bash

STACKS_DIR="$(dirname "$0")"
STACKS=("media-stack" "minio" "open-webui" "mandatory-services")
COMPOSE_FILES=(
    "$STACKS_DIR/media-stack.yml"
    "$STACKS_DIR/minio.yml"
    "$STACKS_DIR/open-webui.yml"
    "$STACKS_DIR/mandatory-services.yml"
)
PROFILES_MAP=(
    "media-stack:vpn,no-vpn,recommendarr"
    "minio:"
    "open-webui:"
    "mandatory-services:"
)
ENV_TEMPLATES="$STACKS_DIR/env-templates"

VALID_ACTIONS=("up" "down" "start" "stop" "restart" "logs" "ps")

ACTION=$1
STACK=$2
PROFILE=$3

# Function: Print usage
usage() {
    echo "Usage: $0 <action> [stack-name] [profile]"
    echo "Actions: ${VALID_ACTIONS[*]}"
    echo "Stacks: ${STACKS[*]}"
    echo "Example: $0 up media-stack vpn"
}

# Function: Choose from menu
choose_from_menu() {
    local prompt=$1
    shift
    local options=("$@")
    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[$i]}"
    done
    read -p "Choose: " choice
    echo "${options[$((choice-1))]}"
}

# Validate action
if [[ ! " ${VALID_ACTIONS[*]} " =~ " ${ACTION} " ]]; then
    ACTION=$(choose_from_menu "Select an action:" "${VALID_ACTIONS[@]}")
fi

# Validate stack
if [[ -z "$STACK" ]]; then
    STACK=$(choose_from_menu "Select a stack:" "${STACKS[@]}")
fi

# Determine compose file and profiles
for i in "${!STACKS[@]}"; do
    if [[ "${STACKS[$i]}" == "$STACK" ]]; then
        COMPOSE_FILE="${COMPOSE_FILES[$i]}"
        AVAILABLE_PROFILES="${PROFILES_MAP[$i]#*:}"
    fi
done

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Compose file for stack '$STACK' not found."
    exit 1
fi

# If action is 'up' and profiles exist, choose one
if [[ "$ACTION" == "up" && -z "$PROFILE" && -n "$AVAILABLE_PROFILES" ]]; then
    IFS=',' read -ra PROFILES <<< "$AVAILABLE_PROFILES"
    PROFILE=$(choose_from_menu "Select a profile (or skip for none):" "${PROFILES[@]}" "Skip")
    [[ "$PROFILE" == "Skip" ]] && PROFILE=""
fi

# Ensure .env exists
ENV_FILE="$STACKS_DIR/$STACK.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠ No .env found for $STACK."
    read -p "Create from template? (y/n): " create_env
    if [[ "$create_env" == "y" ]]; then
        cp "$ENV_TEMPLATES/$STACK.env" "$ENV_FILE"
        echo "✅ Created $ENV_FILE"
    fi
fi

# Load .env
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Detect runtime
if command -v podman-compose &>/dev/null; then
    export DOCKER_SOCKET="/run/podman/podman.sock"
    CMD="podman-compose -f \"$COMPOSE_FILE\""
    echo "▶ Using Podman Compose"
elif command -v docker &>/dev/null; then
    export DOCKER_SOCKET="/var/run/docker.sock"
    CMD="docker compose -f \"$COMPOSE_FILE\""
    echo "▶ Using Docker Compose"
else
    echo "❌ Error: Neither Docker nor Podman found."
    exit 1
fi

# Run command
case "$ACTION" in
    up)
        if [ -z "$PROFILE" ]; then
            eval "$CMD up -d"
        else
            eval "$CMD --profile \"$PROFILE\" up -d"
        fi
        ;;
    down)
        eval "$CMD down"
        ;;
    start|stop|restart)
        eval "$CMD $ACTION"
        ;;
    logs)
        eval "$CMD logs -f"
        ;;
    ps)
        eval "$CMD ps"
        ;;
esac
