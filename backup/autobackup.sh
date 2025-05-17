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
# Mendapatkan alamat IP
IP=$(wget -qO- ipinfo.io/ip)

# Memeriksa status autobackup
cek=$(grep -c -E "^# BEGIN_Backup" /etc/crontab)
if [[ "$cek" = "1" ]]; then
    sts="${GREEN}[ON]${NC}"
else
    sts="${RED}[OFF]${NC}"
fi

# Fungsi untuk memulai autobackup
function start() {
    # Memeriksa apakah file konfigurasi sudah ada
    if [[ ! -f "/home/autobackup.conf" ]]; then
        echo "Please enter your receiver bot token"
        read -rp "Token: " -e receiver_token
        echo "Please enter your chat ID"
        read -rp "Chat ID: " -e chat_id
        echo "RECEIVER_TOKEN=$receiver_token" > /home/autobackup.conf
        echo "CHAT_ID=$chat_id" >> /home/autobackup.conf
    fi

    # Menambahkan entri ke crontab untuk menjalankan backup
    cat <<EOF >> /etc/crontab
# BEGIN_Backup
5 0 * * * root backup
# END_Backup
EOF

    # Merestart cron service
    service cron restart
    sleep 1
    clear
    echo "Autobackup has been started"
    echo "Data will be backed up automatically at 00:05 GMT +7"
    exit 0
}

# Fungsi untuk menghentikan autobackup
function stop() {
    # Menghapus entri crontab untuk backup
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    # Merestart cron service
    service cron restart
    sleep 1
    clear
    echo "Autobackup has been stopped"
    exit 0
}

# Fungsi untuk mengubah token bot penerima
function change_receiver_token() {
    echo "Please enter your receiver bot token"
    read -rp "Token: " -e receiver_token
    sed -i "s/^RECEIVER_TOKEN=.*/RECEIVER_TOKEN=$receiver_token/" /home/autobackup.conf
    clear
    echo "Receiver bot token has been changed"
}

# Fungsi untuk mengubah chat ID
function change_chat_id() {
    echo "Please enter your chat ID"
    read -rp "Chat ID: " -e chat_id
    sed -i "s/^CHAT_ID=.*/CHAT_ID=$chat_id/" /home/autobackup.conf
    clear
    echo "Chat ID has been changed"
}

# Fungsi untuk mengirim pesan uji ke bot
function test_message() {
    # Membaca token bot penerima dan chat ID dari file konfigurasi
    source /home/autobackup.conf
    if [[ "$RECEIVER_TOKEN" = "" || "$CHAT_ID" = "" ]]; then
        echo "Please set the receiver token and chat ID in /home/autobackup.conf file"
        exit 1
    fi

    # Mengirim pesan uji ke bot
    curl -s -X POST "https://api.telegram.org/bot$RECEIVER_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=This is a test message from autobackup script\nIP: $IP\nDate: $(date +"%Y-%m-%d")"

    clear
    echo "Test message has been sent"
}

clear
echo "=============================="
echo -e "     Autobackup Data $sts     "
echo "=============================="
echo "1. Start Autobackup"
echo "2. Stop Autobackup"
echo "3. Change Receiver Bot Token"
echo "4. Change Chat ID"
echo "5. Test Send Message"
echo "=============================="
read -rp "Please enter the correct number: " -e num

case $num in
    1) start ;;
    2) stop ;;
    3) change_receiver_token ;;
    4) change_chat_id ;;
    5) test_message ;;
    *) clear ;;
esac
