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
