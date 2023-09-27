#!/bin/bash

BLUE='\033[34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
NC='\033[0m'
RESET='\e[0m'

checkmark="${WHITE}[${GREEN}\xE2\x9C\x93${WHITE}]"
cross="${WHITE}[${RED}\xE2\x9C\x97${WHITE}]"
ask="${WHITE}[${YELLOW}?${WHITE}]"
uninstall(){
  echo -e "${ask} Are you sure you want to uninstall Paymenter? (y/N): "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "${checkmark} Uninstalling Paymenter..."
    mariadb --execute="DROP USER IF EXISTS 'paymenter'@'127.0.0.1'; DROP DATABASE IF EXISTS 'paymenter';"
    rm -rf /var/www/paymenter/
    rm -f /etc/nginx/sites-available/paymenter.conf
    rm -f /etc/nginx/sites-enabled/paymenter.conf
    (crontab -l | grep -v "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab -
    systemctl stop paymenter.service
    rm -f /etc/systemd/system/paymenter.service
    
    echo -e "${checkmark} Paymenter has been successfully uninstalled."
  else
    echo -e "${cross} Uninstallation canceled."
  fi
}
if [[ $EUID -ne 0 ]]; then
   echo -e "${cross} This script must be run as root."
   exit 1
fi
uninstall
