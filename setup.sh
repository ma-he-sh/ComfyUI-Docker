#!/bin/bash

# Define the base directories
DIRECTORIES=(
    "secure"
    "models"
    "output"
    "settings"
    "ollama"
)

# Detect current User ID and Group ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "--- 1. Creating directory structure ---"
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "✅ Created: $dir"
    else
        echo "ℹ️ Exists: $dir"
    fi
done

echo -e "\n--- 2. Creating Configuration Files ---"
# Create Nginx config
NGINX_CONF="secure/nginx.conf"
if [ ! -f "$NGINX_CONF" ]; then
    cat <<EOF > "$NGINX_CONF"
events {}
http {
    upstream comfyui {
        server comfyk:8188;
    }
    server {
        listen 80;
        location / {
            auth_basic "Restricted Area";
            auth_basic_user_file /etc/nginx/.htpasswd;
            proxy_pass http://comfyui;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
EOF
    echo "✅ Created $NGINX_CONF"
fi

# Create empty password file
if [ ! -f "secure/.htpasswd" ]; then
    touch secure/.htpasswd
    echo "✅ Created secure/.htpasswd"
fi

echo -e "\n--- 3. Setting Permissions ---"
# Setting ownership to the current user (you)
# and ensuring the Docker container has read/write access.
echo "Setting ownership of folders to $USER_ID:$GROUP_ID..."
chown -R $USER_ID:$GROUP_ID "${DIRECTORIES[@]}"

# Standard permissions: 755 for directories, 644 for files
chmod -R 755 "${DIRECTORIES[@]}"

echo "✅ Permissions updated successfully."
echo -e "\nSetup complete! You can now run: docker-compose up -d"
