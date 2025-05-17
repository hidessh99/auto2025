#!/bin/bash

clear
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
apiFILE=$(cat /usr/bin/urlpanel)
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

cd /usr/bin
BASE_URL="$apiFILE/api/files"
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Main Menu${NC}"
wget -q -O menu "${BASE_URL}/menu/menu.sh"
wget -q -O menussh "${BASE_URL}/menu/menu-ssh.sh"
wget -q -O autokill "${BASE_URL}/menu/autokillsh"
wget -q -O vmess "${BASE_URL}/menu/vmess.sh"
wget -q -O vless "${BASE_URL}/menu/vless.sh"
wget -q -O trojan "${BASE_URL}/menu/trojan.sh"
wget -q -O shadowsocks "${BASE_URL}/menu/shadowsocks.sh"
wget -q -O shadowsocks2022 "${BASE_URL}/menu/shadowsocks2022.sh"
wget -q -O socks "${BASE_URL}/menu/socks.sh"
wget -q -O allxray "${BASE_URL}/menu/allxray.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vmess${NC}"
wget -q -O add-vmess "${BASE_URL}/vmess/add-vmess.sh"
wget -q -O del-vmess "${BASE_URL}/vmess/del-vmess.sh"
wget -q -O extend-vmess "${BASE_URL}/vmess/extend-vmess.sh"
wget -q -O trialvmess "${BASE_URL}/vmess/trialvmess.sh"
wget -q -O cek-vmess "${BASE_URL}/vmess/cek-vmess.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vless${NC}"
wget -q -O add-vless "${BASE_URL}/vless/add-vless.sh"
wget -q -O del-vless "${BASE_URL}/vless/del-vless.sh"
wget -q -O extend-vless "${BASE_URL}/vless/extend-vless.sh"
wget -q -O trialvless "${BASE_URL}/vless/trialvless.sh"
wget -q -O cek-vless "${BASE_URL}/vless/cek-vless.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Trojan${NC}"
wget -q -O add-trojan "${BASE_URL}/trojan/add-trojan.sh"
wget -q -O del-trojan "${BASE_URL}/trojan/del-trojan.sh"
wget -q -O extend-trojan "${BASE_URL}/trojan/extend-trojan.sh"
wget -q -O trialtrojan "${BASE_URL}/trojan/trialtrojan.sh"
wget -q -O cek-trojan "${BASE_URL}/trojan/cek-trojan.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Shadowsocks${NC}"
wget -q -O add-ss "${BASE_URL}/shadowsocks/add-ss.sh"
wget -q -O del-ss "${BASE_URL}/shadowsocks/del-ss.sh"
wget -q -O extend-ss "${BASE_URL}/shadowsocks/extend-ss.sh"
wget -q -O trialss "${BASE_URL}/shadowsocks/trialss.sh"
wget -q -O cek-ss "${BASE_URL}/shadowsocks/cek-ss.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Shadowsocks 2022${NC}"
wget -q -O add-ss2022 "${BASE_URL}/shadowsocks2022/add-ss2022.sh"
wget -q -O del-ss2022 "${BASE_URL}/shadowsocks2022/del-ss2022.sh"
wget -q -O extend-ss2022 "${BASE_URL}/shadowsocks2022/extend-ss2022.sh"
wget -q -O trialss2022 "${BASE_URL}/shadowsocks2022/trialss2022.sh"
wget -q -O cek-ss2022 "${BASE_URL}/shadowsocks2022/cek-ss2022.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Socks5${NC}"
wget -q -O add-socks "${BASE_URL}/socks/add-socks.sh"
wget -q -O del-socks "${BASE_URL}/socks/del-socks.sh"
wget -q -O extend-socks "${BASE_URL}/socks/extend-socks.sh"
wget -q -O trialsocks "${BASE_URL}/socks/trialsocks.sh"
wget -q -O cek-socks "${BASE_URL}/socks/cek-socks.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu All Xray${NC}"
wget -q -O add-xray "${BASE_URL}/allxray/add-xray.sh"
wget -q -O del-xray "${BASE_URL}/allxray/del-xray.sh"
wget -q -O extend-xray "${BASE_URL}/allxray/extend-xray.sh"
wget -q -O trialxray "${BASE_URL}/allxray/trialxray.sh"
wget -q -O cek-xray "${BASE_URL}/allxray/cek-xray.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Log${NC}"
wget -q -O log-create "${BASE_URL}/log/log-create.sh"
wget -q -O log-vmess "${BASE_URL}/log/log-vmess.sh"
wget -q -O log-vless "${BASE_URL}/log/log-vless.sh"
wget -q -O log-trojan "${BASE_URL}/log/log-trojan.sh"
wget -q -O log-ss "${BASE_URL}/log/log-ss.sh"
wget -q -O log-ss2022 "${BASE_URL}/log/log-ss2022.sh"
wget -q -O log-socks "${BASE_URL}/log/log-socks.sh"
wget -q -O log-allxray "${BASE_URL}/log/log-allxray.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Other Menu${NC}"
wget -q -O xp "${BASE_URL}/other/xp.sh"
wget -q -O dns "${BASE_URL}/other/dns.sh"
wget -q -O certxray "${BASE_URL}/other/certxray.sh"
wget -q -O xraymod "${BASE_URL}/other/xraymod.sh"
wget -q -O xrayofficial "${BASE_URL}/other/xrayofficial.sh"
wget -q -O about "${BASE_URL}/other/about.sh"
wget -q -O clear-log "${BASE_URL}/other/clear-log.sh"
wget -q -O changer "${BASE_URL}/other/changer.sh"
echo -e "${GB}[ INFO ]${NC} ${YB}Download All Menu Done${NC}"
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Done...${NC}"
cd /usr/bin
chmod +x add-vmess
chmod +x del-vmess
chmod +x extend-vmess
chmod +x trialvmess
chmod +x cek-vmess
chmod +x add-vless
chmod +x del-vless
chmod +x extend-vless
chmod +x trialvless
chmod +x cek-vless
chmod +x add-trojan
chmod +x del-trojan
chmod +x extend-trojan
chmod +x trialtrojan
chmod +x cek-trojan
chmod +x add-ss
chmod +x del-ss
chmod +x extend-ss
chmod +x trialss
chmod +x cek-ss
chmod +x add-ss2022
chmod +x del-ss2022
chmod +x extend-ss2022
chmod +x trialss2022
chmod +x cek-ss2022
chmod +x add-socks
chmod +x del-socks
chmod +x extend-socks
chmod +x trialsocks
chmod +x cek-socks
chmod +x add-xray
chmod +x del-xray
chmod +x extend-xray
chmod +x trialxray
chmod +x cek-xray
chmod +x log-create
chmod +x log-vmess
chmod +x log-vless
chmod +x log-trojan
chmod +x log-ss
chmod +x log-ss2022
chmod +x log-socks
chmod +x log-allxray
chmod +x menu
chmod +x menu_backup
chmod +x backup
chmod +x clean_offset
chmod +x autobackup
chmod +x vmess
chmod +x autokill
chmod +x menussh
chmod +x vless
chmod +x trojan
chmod +x shadowsocks
chmod +x shadowsocks2022
chmod +x socks
chmod +x allxray
chmod +x xp
chmod +x dns
chmod +x certxray
chmod +x xraymod
chmod +x xrayofficial
chmod +x about
chmod +x clear-log
chmod +x changer
sleep 1
cd
rm -f /root/update.sh >> /dev/null 2>&1
rm -f /root/update >> /dev/null 2>&1
