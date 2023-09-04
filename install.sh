#!/bin/bash

# Define text colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Function to log a success message in green
log_success() {
    echo "${GREEN}Success: $1${RESET}"
}

# Function to log an error message with timestamp in red and exit
log_error_and_exit() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${RED}Error [$timestamp]: $1${RESET}" >> error.log
    exit 1
}

# Function to check if a command succeeded
check_command_status() {
    if [ $? -ne 0 ]; then
        log_error_and_exit "$1"
    fi
}

# Function to update and upgrade the system
update_and_upgrade_system() {
    display_activity "Updating and upgrading system packages"
    
    # Debian/Ubuntu
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get -y upgrade || log_error_and_exit "Failed to update and upgrade system packages."
    # Alpine
    elif [ -f /etc/alpine-release ]; then
        apk update && apk upgrade || log_error_and_exit "Failed to update and upgrade system packages."
    # CentOS
    elif [ -f /etc/centos-release ]; then
        yum -y update || log_error_and_exit "Failed to update system packages."
        yum -y upgrade || log_error_and_exit "Failed to upgrade system packages."
    else
        log_error_and_exit "Unsupported distribution."
    fi
    
    log_success "System packages updated and upgraded."
}

# Function to display an activity message
display_activity() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1..."
}

# Function to install Composer non-interactively
install_composer() {
    display_activity "Installing Composer"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=$HOME/bin --filename=composer --quiet
    php -r "unlink('composer-setup.php');"
}

# Function to parse .env configuration file
parse_env() {
    if [ -f ".env" ]; then
        log_success "Parsed .env:"
        source .env
    else
        log_error_and_exit "The .env file does not exist. Create it with the required parameters."
    fi
}

# Parse .env configuration
parse_env

# Check if required parameters are provided
if [ -z "$root_password" ] || [ -z "$db_user" ] || [ -z "$db_user_password" ]; then
    log_error_and_exit "The .env file is missing required parameters: root_password, db_user, or db_user_password."
fi

# Check if the option to show output is provided and set to true
if [ "$show_output" != "true" ]; then
    # Redirect all command output to /dev/null to hide it
    exec > /dev/null 2>&1
fi

# Optionally, update and upgrade the system
if [ "$update_upgrade" == "true" ]; then
    update_and_upgrade_system
fi

# Install required packages
log_success "Installing required packages..."

# Debian/Ubuntu
if [ -f /etc/debian_version ]; then
    apt-get -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    add-apt-repository -y ppa:ondrej/php
    add-apt-repository ppa:redislabs/redis -y
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
    apt-get update
# Alpine
elif [ -f /etc/alpine-release ]; then
    apk add --no-cache curl ca-certificates
    # Add repository setup for Alpine if necessary
    # Example: echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
    apk update
# CentOS
elif [ -f /etc/centos-release ]; then
    yum -y install epel-release
    yum -y install curl
    # Add repository setup for CentOS if necessary
    # Example: yum-config-manager --add-repo=https://example.com/repo.rpm
    yum -y update
else
    log_error_and_exit "Unsupported distribution."
fi

# Install packages
log_success "Installing packages..."

# Debian/Ubuntu
if [ -f /etc/debian_version ]; then
    apt-get -y install php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
# Alpine
elif [ -f /etc/alpine-release ]; then
    apk add --no-cache php8 php8-cli php8-gd php8-mysqlnd php8-pdo php8-mbstring php8-tokenizer php8-xml php8-fpm curl zip unzip git mariadb nginx redis
# CentOS
elif [ -f /etc/centos-release ]; then
    yum -y install epel-release
    yum -y install php php-cli php-gd php-mysql php-pdo php-mbstring php-tokenizer php-xml php-fpm curl zip unzip git mariadb nginx redis
else
    log_error_and_exit "Unsupported distribution."
fi

# Install Composer locally for the current user
log_success "Installing Composer locally..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=$HOME/bin --filename=composer --quiet
php -r "unlink('composer-setup.php');"

# Create directory and fetch panel files
log_success "Creating directory and fetching panel files..."
mkdir -p /var/www/jexactyl
cd /var/www/jexactyl
curl -Lo panel.tar.gz https://github.com/jexactyl/jexactyl/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Set up MySQL user and database
log_success "Setting up MySQL user and database..."
mysql -u root -p"$root_password" <<MYSQL_SCRIPT
CREATE USER '$db_user'@'127.0.0.1' IDENTIFIED BY '$db_user_password';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON panel.* TO '$db_user'@'127.0.0.1' WITH GRANT OPTION;
exit
MYSQL_SCRIPT

# Copy the environment file
log_success "Copying the environment file..."
cp .env.example .env

# Install PHP dependencies and generate a key
log_success "Installing PHP dependencies..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
php artisan key:generate --force

log_success "Installation completed."
