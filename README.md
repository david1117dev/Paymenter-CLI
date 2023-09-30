# Paymenter CLI

Paymenter CLI is a script that simplifies the management of Paymenter, an open-source webshop solution for hosting companies. With this CLI tool, you can easily install, uninstall, and perform common tasks related to Paymenter.

## Features

- Install Paymenter with a single command.
- Uninstall Paymenter completly.
- Backup database & environment
- Display information about the current Paymenter installation.
- Execute artisan commands directly

## Getting Started

### To install the Paymenter command

```bash
curl -L -o /usr/local/bin/paymenter "https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-cli.sh" && chmod +x /usr/local/bin/paymenter
```

Now, the paymenter command should be installed

### To directly install Paymenter

To use the installation script, simply run this command as root.

```bash
bash <(curl -s https://raw.githubusercontent.com/david1117dev/Paymenter-CLI/main/paymenter-install.sh)
```

_Note: On some systems, it's required to be already logged in as root before executing the one-line command (where `sudo` is in front of the command does not work)._
