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
  echo "  info      - Show information about the current installation"
  echo "  install   - Install Paymenter"
  echo "  uninstall - Completely uninstall Paymenter"
  echo "  fix       - Fix common Paymenter issues"
}


install() {
  bash <(https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-install.sh)
}

uninstall() {
  bash <(https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-uninstall.sh)
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
