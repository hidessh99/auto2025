#!/bin/bash

NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
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
CLIENT_EXISTS=("vmess.json" "vless.json" "trojan.json" "socks.json" "shadowsocks.json" "shadowsocks2022.json")
# Check if any of the JSON files exist and count lines in each file
total_lines=0
for client_file in "${CLIENT_EXISTS[@]}"; do
    file_path="/etc/default/syncron/$client_file"

    if [ -e "$file_path" ]; then
        lines_in_file=$(grep -c -E "^#&@ " "$file_path")
        total_lines=$((total_lines + lines_in_file))
    fi
done
if [[ ${total_lines} == '0' ]]; then
    clear
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "              ${WB}Delete All Xray Accounts${NC}               "
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "  ${YB}You have no existing clients!${NC}"
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    read -n 1 -s -r -p "Press any key to return to the menu"
    allxray
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "              ${WB}Delete All Xray Accounts${NC}               "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Delete All Xray Accounts${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"

# Menggunakan perulangan untuk mencari dan menampilkan daftar akun yang telah kedaluwarsa
for json_file in /etc/default/syncron/*.json; do
    file_name=$(basename "$json_file")
    account_type=${file_name%.json}
    account_type=${account_type^}  # Membuat huruf pertama menjadi kapital

    expired_accounts=$(grep -E "^#&@ " "$json_file" | cut -d ' ' -f 2-3 | sort | uniq)

    if [ -n "$expired_accounts" ]; then
        echo "Account $account_type Ws and gRPC"
        echo "$expired_accounts"
    fi
done

echo ""
echo -e "${YB}Press Enter to Return${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Masukkan Username : " user

if [ -z $user ]; then
    allxray
else
    # Menghapus akun dari berkas konfigurasi JSON yang sesuai
    for json_file in /etc/default/syncron/*.json; do
        exp=$(grep -wE "^#&@ $user" "$json_file" | cut -d ' ' -f 3 | sort | uniq)
        sed -i "/^#&@ $user $exp/,/^},{/d" "$json_file"
    done

    # Hapus berkas log yang terkait
    rm -rf /var/www/html/allxray/allxray-$user.txt
    rm -rf /user/log-allxray-$user.txt

    # Hapus akun dari database
    sed -i "/\b$user\b/d" /etc/allxray/.allxray.db

    # Hapus direktori akun
    rm -rf /etc/allxray/$user

    # Hapus berkas batasan (jika ada)
    rm -rf /etc/limit/allxray/$user

    # Hapus berkas sementara
    rm -rf /tmp/$user

    # Restart layanan Xray
    systemctl restart xray

    clear
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "          ${WB}Delete Xray Account Successfully${NC}          "
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e " ${YB}Client Name :${NC} $user"
    echo -e " ${YB}Expires On  :${NC} $exp"
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to return to the menu"
    clear
    allxray
fi
