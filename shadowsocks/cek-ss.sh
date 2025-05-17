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
echo -n >/tmp/other.txt
data=($(cat /etc/default/syncron/shadowsocks.json | grep '^#!' | cut -d ' ' -f 2 | sort | uniq))
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "           ${WB}Shadowsocks User Login Account${NC}           "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
for akun in "${data[@]}"; do
if [[ -z "$akun" ]]; then
akun="Tidak Ada"
fi
echo -n >/tmp/ipshadowsocks.txt
data2=($(cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq))
for ip in "${data2[@]}"; do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >>/tmp/ipshadowsocks.txt
else
echo "$ip" >>/tmp/other.txt
fi
jum2=$(cat /tmp/ipshadowsocks.txt)
sed -i "/$jum2/d" /tmp/other.txt >/dev/null 2>&1
done
jum=$(cat /tmp/ipshadowsocks.txt)
if [[ -z "$jum" ]]; then
echo >/dev/null
else
jum2=$(cat /tmp/ipshadowsocks.txt | nl)
byte=$(cat /etc/limit/shadowsocks/$akun)

    # Konversi ke GiB jika nilai melebihi atau sama dengan 1 GiB
    if ((byte >= 1024 * 1024 * 1024)); then
      kon=$((byte / (1024 * 1024 * 1024)))
      unit="GiB"
    # Konversi ke MiB jika nilai melebihi atau sama dengan 1 MiB
    elif ((byte >= 1024 * 1024)); then
      kon=$((byte / (1024 * 1024)))
      unit="MiB"
    # Konversi ke KiB jika nilai melebihi atau sama dengan 1 KiB
    elif ((byte >= 1024)); then
      kon=$((byte / 1024))
      unit="KiB"
    else
      kon=$byte
      unit="byte"
    fi

    echo -e "user : ${BB}"$akun${NC}" ${MB}$kon $unit${NC}"
    echo "$jum2"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
fi
rm -rf /tmp/ipshadowsocks.txt
done
rm -rf /tmp/other.txt
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
shadowsocks
