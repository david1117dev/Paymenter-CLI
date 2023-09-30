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

backup_dir="/etc/paymenter/backups"

function select_option {

    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    for opt; do printf "\n"; done

    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        
        cursor_to $startrow
        echo -e "$ask Select the backup to restore:"

        local idx=0
        for opt; do
            cursor_to $(($startrow + 2 + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}
export_backup() {
    backup_dir="$backup_dir/$(date '+%Y-%m-%d_%H-%M-%S')"
    mkdir -p "$backup_dir"
    if [ -f /var/www/paymenter/.env ]; then
        source /var/www/paymenter/.env
    else
        echo -e "$cross Paymenter .env file not found at /var/www/paymenter/"
        exit 1
    fi
    mysqldump -h 127.0.0.1 -u "$DB_USERNAME" -p"$DB_PASSWORD" --opt "$DB_DATABASE" > "$backup_dir/paymenter.sql"
    cp /var/www/paymenter/.env "$backup_dir/.env"
    tar -czvf "$backup_dir.tar.gz" -C "$(dirname "$backup_dir")" "$(basename "$backup_dir")" > /dev/null 2>&1
    rm -r "$backup_dir"
    echo -e "$checkmark Backup completed and saved to: $backup_dir.tar.gz"
}

select_backup() {
    backups=("$backup_dir"/*.tar.gz)
    num_backups=${#backups[@]}
    if [ $num_backups -eq 0 ]; then
        echo -e "$cross No backup archives found in $backup_dir."
        exit 1
    fi
    options=()
    for backup in "${backups[@]}"; do
        options+=("$(basename "$backup")")
    done
    select_option "${options[@]}"
    choice=$?
    restore_backup "${backups[$choice]}"
}
restore_backup() {
    local backup_archive="$1"
    backup_name=$(basename "$backup_archive" .tar.gz)
    echo -e -n "$ask Warning: Restoring a backup will overwrite the current database and environment. Continue? (y/n): " 
    read -r confirm
    if [ "$confirm" != "y" ]; then
        echo -e "$cross Restore cancelled."
        exit 1
    fi
    tar -xzvf "$backup_archive" -C "$backup_dir" > /dev/null 2>&1
    if [ -f /var/www/paymenter/.env ]; then
        source /var/www/paymenter/.env
    else
        echo -e "$cross Paymenter .env file not found at /var/www/paymenter/"
        exit 1
    fi
    mysql -h 127.0.0.1 -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < "/etc/paymenter/backups/$backup_name/paymenter.sql"
    cp "/etc/paymenter/backups/$backup_name/.env" /var/www/paymenter/.env
    echo -e "$checkmark Restore completed."
}
if [ "$1" == "export" ]; then
    export_backup
elif [ "$1" == "import" ]; then
    select_backup
else
    echo -e "$cross Usage: paymenter backup [export|import]"
    exit 1
fi
