#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset warna

clear
checkPermission() {
    if [ ! -f /usr/bin/key ]; then
      echo -e "${RED}Error: Rest API Problem Please Contact Admin.${NC}"
      sleep 3
      exit 1
    fi
    apiURL=$(cat /usr/bin/key)
    MYIP=$(curl -sS ipv4.icanhazip.com)
    HTTP_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "$apiURL")

   if [ "$HTTP_STATUS" -eq 403 ]; then
        echo ""
        echo -e "${RED}Access Denied. IP Not Allow, Please Register To Panel.${NC}"
        echo ""
        sleep 3
        exit 1
    elif [ "$HTTP_STATUS" -ne 200 ]; then
        echo -e "${RED}Sorry, the server is currently under maintenance, please wait until it's finished.${NC}"
        sleep 3
        exit 1
    fi

    OUTPUT=$(curl -sS "$apiURL")
    permission_found=false
    TODAY=$(date +%Y-%m-%d)

    while IFS= read -r line; do
        # Skip lines that don't start with ###
        if [[ "$line" =~ ^### ]]; then
            # Remove leading ###
            line=${line:4}

            # Extract fields from the line
            USERNAME=$(echo "$line" | awk '{print $1}')
            EXPIRED=$(echo "$line" | awk '{print $2}')
            IP=$(echo "$line" | awk '{print $3}')
            X_API_KEY=$(echo "$line" | awk '{print $5}')
            ROLES=$(echo "$line" | awk '{print $6}')
            STATUS=$(echo "$line" | awk '{print $7}')

            if [ "$MYIP" = "$IP" ] && [ "$TODAY" \< "$EXPIRED" ]; then
                permission_found=true
                if [ "$STATUS" = "active" ]; then
                    echo -e "${GREEN}Permission Accepted for user $USERNAME with Key $X_API_KEY!${NC}"
                    clear
                    break
                elif [ "$STATUS" = "suspended" ]; then
                    echo -e "${RED}Access Denied! Your Permission Suspended for user $USERNAME with Key $X_API_KEY!${NC}"
                    sleep 3
                    exit 1
                elif [ "$STATUS" = "expired" ]; then
                    echo -e "${RED}Access Denied! Your permission has expired for user $USERNAME with Key $X_API_KEY!${NC}"
                    sleep 3
                    exit 1
                else
                    echo -e "${RED}Unknown Status for user $USERNAME with Key $X_API_KEY!${NC}"
                    sleep 3
                    exit 1
                fi
            fi
        fi
    done <<< "$OUTPUT"

    if [ "$permission_found" = false ]; then
        echo -e "${RED}Access Denied! Your IP is not registered or permission has expired.${NC}"
        sleep 3
        exit 1
    fi
}

checkPermission
# RECEIVER_TOKEN bot Telegram
source /home/autobackup.conf

show_menu() {
    echo "Menu:"
    echo "1. Backup"
    echo "2. Restore"
    echo "3. Membersihkan Offset"
    echo "0. Keluar"
}

backup() {
    send_message() {
    message="$1"
    curl -s -X POST "https://api.telegram.org/bot$RECEIVER_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$message" > /dev/null 2>&1
}

send_file() {
    file_path="$1"
    response=$(curl -s -F chat_id="$CHAT_ID" -F document=@"$file_path" "https://api.telegram.org/bot$RECEIVER_TOKEN/sendDocument") > /dev/null 2>&1
    file_id=$(echo "$response" | jq -r '.result.document.file_id')
    echo "$file_id"
}

IP=$(wget -qO- ipinfo.io/ip);
domain=$(cat /usr/local/etc/xray/domain)
date=$(date +"%Y-%m-%d")

rm -rf /root/backup
mkdir -p /root/backup
mkdir -p /root/backup/limit
mkdir -p /root/backup/html

echo "Mohon Menunggu, Proses Backup sedang berlangsung !!"

cp -r /usr/local/etc/xray/ backup/
cp -r /etc/default/syncron/ backup/

cp -r /etc/allxray/ backup/
cp -r /etc/vmess/ backup/
cp -r /etc/vless/ backup/
cp -r /etc/trojan/ backup/
cp -r /etc/shadowsocks/ backup/
cp -r /etc/shadowsocks2022/ backup/
cp -r /etc/socks/ backup/
cp -r /etc/ssh/ backup/

cp /etc/passwd backup/
cp /etc/group backup/
cp /etc/shadow backup/
cp /etc/gshadow backup/

cp -r /var/www/html/allxray/ backup/html/allxray
cp -r /var/www/html/vmess/ backup/html/vmess
cp -r /var/www/html/vless/ backup/html/vless
cp -r /var/www/html/trojan/ backup/html/trojan
cp -r /var/www/html/shadowsocks/ backup/html/shadowsocks
cp -r /var/www/html/shadowsocks2022/ backup/html/shadowsocks2022
cp -r /var/www/html/socks5/ backup/html/socks
cp -r /var/www/html/ssh/ backup/html/ssh

cp -r /etc/limit/vmess/ backup/limit/vmess
cp -r /etc/limit/vless/ backup/limit/vless
cp -r /etc/limit/trojan/ backup/limit/trojan
cp -r /etc/limit/shadowsocks/ backup/limit/shadowsocks
cp -r /etc/limit/shadowsocks2022/ backup/limit/shadowsocks2022
cp -r /etc/limit/socks/ backup/limit/socks

cd /root
zip -r "$domain-$date.zip" backup > /dev/null 2>&1

send_message "Proses Backup telah selesai. ${IP}"
send_file "/root/$domain-$date.zip"
rm -rf /root/backup
rm -r /root/$domain-$date.zip
clear
echo "Proses Backup telah selesai."
}

restore() {
    get_last_file_id() {
    updates=$(curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates")
    file_id=$(echo "$updates" | jq -r '.result[-1].message.document.file_id')
    echo "$file_id"
}

get_file() {
    file_id=$(get_last_file_id)

    if [[ -n "$file_id" ]]; then
        file_name=$(curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates" | jq -r '.result[].message.document | select(.file_id == "'$file_id'") | .file_name')
        response=$(curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getFile?file_id=$file_id")
        file_path=$(echo "$response" | jq -r '.result.file_path')
        download_url="https://api.telegram.org/file/bot$RECEIVER_TOKEN/$file_path"
        curl -s -o "$file_name" "$download_url"

        # Proses restore file di sini
        unzip "$file_name"
        rm -f "$file_name"
        sleep 1
        echo Start Restore
        cd /root/backup
        cp -r xray /usr/local/etc/
        cp -r syncron /etc/default/
        cp -r vmess /etc/
        cp -r ssh /etc/
        cp -r allxray /etc/
        cp -r vless /etc/
        cp -r trojan /etc/
        cp -r shadowsocks /etc/
        cp -r shadowsocks2022 /etc/
        cp -r socks /etc/
        cp passwd /etc/
        cp group /etc/
        cp shadow /etc/
        cp gshadow /etc/
        cd limit/
        cp -r * /etc/limit/
        cd /root/backup/html
        cp -r * /var/www/html/
        rm -rf /root/backup
        rm -f "$file_name"
        echo Done
    else
        echo "File tidak ditemukan."
    fi
}

get_file
}

cleanup_offset() {
    cleanup_updates() {
    response=$(curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates")
    update_ids=$(echo "$response" | jq -r '.result[].update_id')

    for id in $update_ids; do
        curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates?offset=$((id + 1))"
    done
}

cleanup_updates
}

clear
if [[ ! -f "/home/autobackup.conf" ]]; then
        echo "Please enter your receiver bot token"
        read -rp "Token: " -e receiver_token
        echo "Please enter your chat ID"
        read -rp "Chat ID: " -e chat_id
        echo "RECEIVER_TOKEN=$receiver_token" > /home/autobackup.conf
        echo "CHAT_ID=$chat_id" >> /home/autobackup.conf
fi
show_menu

while true; do
    read -p "Masukkan pilihan (0-3): " choice

    case $choice in
        0)
            break
            ;;
        1)
			cd
            backup
            ;;
        2)
			cd
            restore
            ;;
        3)
			cd
            cleanup_offset
            ;;
        *)
            echo "Pilihan tidak valid."
            ;;
    esac

    echo
    show_menu
done

exit 0
