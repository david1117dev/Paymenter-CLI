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
  echo "  info      - Show info about the current installation"
  echo "  install   - Install Paymenter"
  echo "  uninstall - Completely uninstall Paymenter"
  echo "  backup    - Backup database & environment"
  echo "  artisan   - Run an artisan command directly"
}

info() {
  PAYMENTER_ENV_FILE=/var/www/paymenter/.env
  if [ -f "$PAYMENTER_ENV_FILE" ]; then
    source "$PAYMENTER_ENV_FILE" 

    # Display the Paymenter information in a formatted way
    echo -e "${WHITE}Paymenter Information:${RESET}"
    echo -e "  ${BLUE}App Name:${RESET} $APP_NAME"
    echo -e "  ${BLUE}App URL:${RESET} $APP_URL"
    echo 
    echo -e "  ${BLUE}Database Name:${RESET} $DB_DATABASE"
    echo -e "  ${BLUE}Database Username:${RESET} $DB_USERNAME"
    echo -e "  ${BLUE}Database Password:${RESET} $DB_PASSWORD"
  else
    echo -e "${cross} Paymenter .env file not found at $PAYMENTER_ENV_FILE"
  fi
}

install() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${cross} This command must be run as root."
    exit 1
  fi
  bash -c "$(curl -s https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-install.sh)"
}

uninstall() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${cross} This command must be run as root."
    exit 1
  fi
  bash -c "$(curl -s https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-uninstall.sh)"

}

backup() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${cross} This command must be run as root."
    exit 1
  fi
  mkdir -p /etc/paymenter/
  rm -f /etc/paymenter/paymenter-backup.sh
  curl -L -o /etc/paymenter/paymenter-backup.sh "https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-backup.sh" > /dev/null 2>&1
  chmod +x /etc/paymenter/paymenter-backup.sh
  bash /etc/paymenter/paymenter-backup.sh $2
}
artisan(){
  if [ "$EUID" -ne 0 ]; then
    echo -e "${cross} This command must be run as root."
    exit 1
  fi
  cd /var/www/paymenter/
  php artisan "$2"

}


# Main script logic
case "$1" in
  "info")
    info
    ;;
  "install")
    install
    ;;
  "uninstall")
    uninstall
    ;;
  "backup")
    backup "$@"
    ;;
  "artisan")
    artisan "$@"
    ;;  
  *)
    main
    ;;
esac

exit 0
