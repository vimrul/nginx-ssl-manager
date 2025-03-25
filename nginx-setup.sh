#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &>/dev/null; then
    echo "Nginx is not installed. Installing..."
    apt update && apt install -y nginx || { echo "Nginx installation failed!"; exit 1; }
fi

# Prompt for domain name
read -rp "Enter the domain name (e.g., example.com): " domain

# Choose which domain(s) to configure
echo "Which domain configuration do you want?"
echo "1) domain.com only"
echo "2) www.domain.com only"
echo "3) Both domain.com and www.domain.com"
read -rp "Enter your choice (1/2/3): " domain_choice

# Generate server_name based on choice
if [[ $domain_choice -eq 1 ]]; then
    server_name="$domain"
elif [[ $domain_choice -eq 2 ]]; then
    server_name="www.$domain"
elif [[ $domain_choice -eq 3 ]]; then
    server_name="$domain www.$domain"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Prompt for the type of configuration
echo "Configuration Type:"
echo "1) Document Root"
echo "2) Reverse Proxy"
read -rp "Choose an option (1/2): " config_type

# Set up variables based on choice
if [[ $config_type -eq 1 ]]; then
    echo "Document Root Configuration:"
    echo "1) Create a new document root"
    echo "2) Use an existing document root"
    read -rp "Choose an option (1/2): " docroot_option

    if [[ $docroot_option -eq 1 ]]; then
        docroot="/var/www/$domain"
        mkdir -p "$docroot"
        echo "New document root created at $docroot"
    elif [[ $docroot_option -eq 2 ]]; then
        read -rp "Enter the existing document root path (full path): " docroot
        if [[ ! -d "$docroot" ]]; then
            echo "The provided path does not exist. Exiting."
            exit 1
        fi
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi

    config_block="root $docroot;
    index index.html index.htm index.nginx-debian.html;"
elif [[ $config_type -eq 2 ]]; then
    read -rp "Enter the reverse proxy port (e.g., 3000): " port
    config_block="proxy_pass http://localhost:$port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Create Nginx configuration file
conf_file="/etc/nginx/sites-available/$domain"
echo "Creating Nginx configuration file at $conf_file..."

cat > "$conf_file" <<EOF
server {
    listen 80;
    server_name $server_name;

    location / {
        $config_block
    }

    error_log /var/log/nginx/$domain.error.log;
    access_log /var/log/nginx/$domain.access.log;
}
EOF

# Enable the site
ln -s "$conf_file" /etc/nginx/sites-enabled/ 2>/dev/null

# Test Nginx configuration and reload
nginx -t && systemctl reload nginx
if [[ $? -ne 0 ]]; then
    echo "Nginx configuration failed. Please check the syntax."
    exit 1
fi

# Check if Certbot is installed
if ! command -v certbot &>/dev/null; then
    echo "Certbot is not installed. Installing Certbot and dependencies..."
    apt update && apt install -y certbot python3-certbot-nginx || { echo "Certbot installation failed!"; exit 1; }
fi

# Ask to install SSL
read -rp "Would you like to install SSL using Let's Encrypt (y/n)? " ssl_choice
if [[ $ssl_choice == "y" || $ssl_choice == "Y" ]]; then
    if [[ $domain_choice -eq 1 ]]; then
        certbot --nginx -d "$domain" --agree-tos --redirect --no-eff-email || {
            echo "SSL installation failed."
            exit 1
        }
    elif [[ $domain_choice -eq 2 ]]; then
        certbot --nginx -d "www.$domain" --agree-tos --redirect --no-eff-email || {
            echo "SSL installation failed."
            exit 1
        }
    elif [[ $domain_choice -eq 3 ]]; then
        certbot --nginx -d "$domain" -d "www.$domain" --agree-tos --redirect --no-eff-email || {
            echo "SSL installation failed."
            exit 1
        }
    fi
    echo "SSL installed successfully!"
else
    echo "Skipping SSL installation."
fi

echo "Nginx configuration for $domain completed successfully!"