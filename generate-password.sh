#!/bin/bash

# --- CONFIGURATION ---
USER_NAME="admin"
PASS_FILE="./secure/.htpasswd"
COMPOSE_FILE="docker-compose.yml"

echo "🚀 ComfyUI Docker Manager"
echo "--------------------------"

# 1. Check if .htpasswd exists, if not, create it
if [ ! -f "$PASS_FILE" ]; then
    echo "🔑 No password file found. Let's create one."
    read -p "Enter username for ComfyUI [default: admin]: " input_user
    USER_NAME=${input_user:-$USER_NAME}
    
    read -s -p "Enter password for ComfyUI: " input_pass
    echo ""

    # Using Docker to generate the hash so you don't need local tools installed
    docker run --rm xmartlabs/htpasswd "$USER_NAME" "$input_pass" > "$PASS_FILE"
    echo "✅ Created $PASS_FILE for user: $USER_NAME"
else
    echo "✅ Password file detected."
fi

