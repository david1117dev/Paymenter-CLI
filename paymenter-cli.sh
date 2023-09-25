#!/bin/bash

# Define text formatting escape codes (color placeholders)
BLUE='\033[34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
RESET='\e[0m' # Reset formatting

# Checkmark and cross symbols
checkmark="${WHITE}[${GREEN}\xE2\x9C\x93${WHITE}] ${RESET}"
cross="${WHITE}[${RED}\xE2\x9C\x97${WHITE}]${RESET}"
ask="${WHITE}[${YELLOW}?${WHITE}]"


# Function to display information
main() {
  echo -e "${BLUE}   ____                                   __           "
  echo "  / __ \____ ___  ______ ___  ___  ____  / /____  _____"
  echo " / /_/ / __ \`/ / / / __ \`__ \/ _ \/ __ \/ __/ _ \/ ___/"
  echo " / ____/ /_/ / /_/ / / / / / /  __/ / / / /_/  __/ /    "
  echo -e "/_/    \__,_/\__, /_/ /_/ /_/\___/_/ /_/\__/\___/_/     "
  echo -e "            /____/                                      ${RESET}"
  echo
  echo "Paymenter is an open-source webshop solution for hosting companies. It's developed to provide an easier way to manage your hosting company."
  echo 
  echo "Available commands:"
  echo "  info      - Show information about the current installation"
  echo "  install   - Install Paymenter"
  echo "  uninstall - Completely uninstall Paymenter"
  echo "  fix       - Fix common Paymenter issues"
}

# Function to install Paymenter
install() {
  echo "Installing Paymenter..."
  # Add installation logic here
}

# Function to uninstall Paymenter
uninstall() {
  echo -e "${ask} Are you sure you want to uninstall Paymenter? (y/N): "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstalling Paymenter..."
    
    # Uninstallation logic
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

# Function to fix Paymenter issues
fix() {
  echo "Fixing Paymenter issues..."
  # Add fix logic here
}

# Main script logic
case "$1" in
  "info")
    main
    ;;
  "install")
    install
    ;;
  "uninstall")
    uninstall
    ;;
  "fix")
    fix
    ;;
  *)
    main
    ;;
esac

exit 0
