#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
NC='\033[0m'
RESET='\e[0m'

checkmark="${WHITE}[${GREEN}\xE2\x9C\x93${WHITE}] ${RESET}"
cross="${WHITE}[${RED}\xE2\x9C\x97${WHITE}]${RESET}"
ask="${WHITE}[${YELLOW}?${WHITE}]"
 
if [[ $EUID -ne 0 ]]; then
   echo -e "${cross} This script must be run as root."
   exit 1
fi
check_distribution() {
    if [[ -f /etc/os-release && $(grep -c "Ubuntu 18\|Ubuntu 20\|Ubuntu 22" /etc/os-release) -gt 0 ]]; then
        echo "" > /dev/null 2>&1
    elif [[ -f /etc/os-release && $(grep -c "CentOS Linux 7\|CentOS Linux 8" /etc/os-release) -gt 0 ]]; then
        echo "" > /dev/null 2>&1
    elif [[ -f /etc/os-release && $(grep -c "Debian GNU/Linux 10\|Debian GNU/Linux 11" /etc/os-release) -gt 0 ]]; then
        echo "" > /dev/null 2>&1
    else
        echo -e "${cross} This is an unsupported Linux distribution/version."
        exit 1
    fi
}
 
install_dependencies() {
    echo -e "${checkmark} Installing dependencies."
    apt update > /dev/null 2>&1 && apt upgrade > /dev/null 2>&1
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg > /dev/null 2>&1
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
    if [ "$(lsb_release -si)" != "Ubuntu" ] || [ "$(lsb_release -sr)" != "22.04" ]; then
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash > /dev/null 2>&1
    fi
    apt update > /dev/null 2>&1
    if [ "$(lsb_release -si)" != "Ubuntu" ] || [ "$(lsb_release -sr)" = "18.04" ]; then
    apt-add-repository universe > /dev/null 2>&1
    fi
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server > /dev/null 2>&1
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
}
download_paymenter() {
    echo -e "${checkmark} Downloading paymenter"
    if [ -d "/var/www/paymenter" ]; then
      rm -rf /var/www/paymenter/
    fi
    mkdir -p /var/www/paymenter
    curl -Lo /var/www/paymenter/paymenter.tar.gz https://github.com/paymenter/paymenter/releases/latest/download/paymenter.tar.gz > /dev/null 2>&1
    tar -xzvf /var/www/paymenter/paymenter.tar.gz -C /var/www/paymenter/ > /dev/null 2>&1
    chmod -R 755 /var/www/paymenter/storage/* /var/www/paymenter/bootstrap/cache/
 
}
environment() {
    echo -e "${checkmark} Setup environment" 
    while true; do echo -e -n "${ask} Enter Paymenter Domain or IP (Include https://): " && read app_url && [[ $app_url =~ ^(http:\/\/localhost|http:\/\/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|https?:\/\/(localhost|[0-9]{3}\.[0-9]{3}\.[0-9]{3}|[a-zA-Z0-9.-]+[.][a-zA-Z]+))$ ]] && { echo ""; break; } || echo "Invalid app_url format. It should be a valid HTTP or HTTPS URL."; done
    while true; do echo -e -n "${ask} Enter admin user email: " && read email && [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]] && break; echo "Invalid email address format. Please enter a valid email address."; done
    echo -e "${ask} Enter admin user password: (hidden input)" && read -s password
    echo -e -n "${ask} Enter admin username: " && read username
    echo -e "$email\n$password\n$username\nadmin" | php /var/www/paymenter/artisan p:user:create
    env_file="/var/www/paymenter/.env"
    export email=email
    export server_name=app_url
    sed -i "s/APP_URL=http://localhost/$app_url/"
    sed -i "s@APP_URL=http://localhost@APP_URL=asdasd@g" /var/www/paymenter/.env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD" /var/www/paymenter/.env
}
setup_database() {
    password=$(openssl rand -base64 12)
    export DB_PASSWORD="$password"
    mariadb --execute="DROP USER IF EXISTS 'paymenter'@'127.0.0.1'; DROP DATABASE IF EXISTS paymenter;"
    mariadb --execute="CREATE USER 'paymenter'@'127.0.0.1' IDENTIFIED BY '$password'; CREATE DATABASE paymenter; GRANT ALL PRIVILEGES ON paymenter.* TO 'paymenter'@'127.0.0.1' WITH GRANT OPTION;"
}
install_paymenter() {
    cp /var/www/paymenter/.env.example /var/www/paymenter/.env > /dev/null 2>&1
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install -d /var/www/paymenter/ --no-dev --optimize-autoloader > /dev/null 2>&1
    php /var/www/paymenter/artisan key:generate --force > /dev/null 2>&1
    php /var/www/paymenter/artisan migrate --force --seed > /dev/null 2>&1
}
setup_webserver() {
cat > /etc/nginx/sites-available/paymenter.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name paymenter.org;
    root /var/www/paymenter/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOF
}
setup_queue() {
    (crontab -l ; echo "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab -
    rm -f /etc/systemd/system/paymenter.service
    echo "[Unit]
Description=Paymenter Queue Worker
 
[Service]
 
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/paymenter/artisan queue:work
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s
 
[Install]
WantedBy=multi-user.target
    " | tee /etc/systemd/system/paymenter.service > /dev/null
    systemctl enable --now paymenter.service
 
}
 
 
check_distribution
install_dependencies
download_paymenter
setup_database
install_paymenter
environment
#setup_webserver
#setup_queue