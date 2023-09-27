#!/bin/bash

BLUE='\033[34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
NC='\033[0m'
RESET='\e[0m'

checkmark="${WHITE}[${GREEN}\xE2\x9C\x93${WHITE}] ${RESET}"
cross="${WHITE}[${RED}\xE2\x9C\x97${WHITE}]${RESET}"
ask="${WHITE}[${YELLOW}?${WHITE}]"
uninstall(){
  echo -e "${ask} Are you sure you want to uninstall Paymenter? (y/N): "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstalling Paymenter..."
    mariadb --execute="DROP USER 'paymenter'; DROP DATABASE 'paymenter';"
    rm -rf /var/www/paymenter/
    rm -f /etc/nginx/sites-available/paymenter.conf
    rm -f /etc/nginx/sites-enabled/paymenter.conf
    (crontab -l | grep -v "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab -
    systemctl stop paymenter.service
    rm -f /etc/systemd/system/paymenter.service
    
    echo -e "${checkmark} Paymenter has been successfully uninstalled."
  else
    echo "Uninstallation canceled."
  fi
}
uninstall
