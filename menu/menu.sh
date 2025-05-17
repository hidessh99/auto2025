#!/bin/bash

NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\033[0;31m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[1;32m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
RED='\033[0;31m'
GREEN='\033[0;32m'

declare ROLES
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

xray_service=$(systemctl status vipssh@vmess.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nginx_service=$(systemctl status nginx | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
tunnapi_service=$(systemctl status tunnapi | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
haproxy_service=$(systemctl status multiport.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
udp_service=$(systemctl status udp-custom.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
slowdns_service=$(systemctl status server.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $xray_service == "running" ]]; then
status_xray="${GB}[ ON ]${NC}"
else
status_xray="${RB}[ OFF ]${NC}"
fi
if [[ $nginx_service == "running" ]]; then
status_nginx="${GB}[ ON ]${NC}"
else
status_nginx="${RB}[ OFF ]${NC}"
fi
if [[ $tunnapi_service == "running" ]]; then
status_tunnapi="${GB}[ ON ]${NC}"
else
status_tunnapi="${RB}[ OFF ]${NC}"
fi
if [[ $haproxy_service == "running" ]]; then
status_haproxy="${GB}[ ON ]${NC}"
else
status_haproxy="${RB}[ OFF ]${NC}"
fi
if [[ $udp_service == "running" ]]; then
status_udp="${GB}[ ON ]${NC}"
else
status_udp="${RB}[ OFF ]${NC}"
fi
if [[ $slowdns_service == "running" ]]; then
status_slowdns="${GB}[ ON ]${NC}"
else
status_slowdns="${RB}[ OFF ]${NC}"
fi

ssh_akun=$(grep "^###" /etc/ssh/.ssh.db | wc -l)
vmess_akun=$(grep "^###" /etc/vmess/.vmess.db | wc -l)
vless_akun=$(grep "^###" /etc/vless/.vless.db | wc -l)
trojan_akun=$(grep "^###" /etc/trojan/.trojan.db | wc -l)
shadowsocks_akun=$(grep "^###" /etc/shadowsocks/.shadowsocks.db | wc -l)
shadowsocks2022_akun=$(grep "^###" /etc/shadowsocks2022/.shadowsocks2022.db | wc -l)
socks_akun=$(grep "^###" /etc/socks/.socks.db | wc -l)
allxray_akun=$(grep "^###" /etc/allxray/.allxray.db | wc -l)

MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
LOADCPU=$(printf '%-0.00001s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
CORE=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
vnstat -i ${vnstat_profile} >/etc/t1
bulan=$(date +%b)
tahun=$(date +%y)
ba=$(curl -s https://pastebin.com/raw/0gWiX6hE)
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
todayd=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')
if [ "$(grep -wc ${bulan} /etc/t1)" != '0' ]; then
bulan=$(date +%b)
month=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $9}')
month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $10}')
month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $3}')
month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $4}')
month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $6}')
month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $7}')
else
bulan2=$(date +%Y-%m)
month=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $8}')
month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $9}')
month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $2}')
month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $3}')
month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $5}')
month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $6}')
fi
if [ "$(grep -wc yesterday /etc/t1)" != '0' ]; then
yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
yesterday=NULL
yesterday_v=NULL
yesterday_rx=NULL
yesterday_rxv=NULL
yesterday_tx=0B
yesterday_txv=
fi

capitalizeFirstLetter() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}'
}

CAPITALIZED_ROLE=$(capitalizeFirstLetter "$ROLES")

start_date=$(date +'%Y-%m-%d')
start_unix=$(date -d "$start_date" +%s)
end_unix=$(date -d "$EXPIRED" +%s)
diff=$(( (end_unix - start_unix) / (24*60*60) ))

domain=$(cat /usr/local/etc/xray/domain)
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
WKT=$(cat /usr/local/etc/xray/timezone)
DATE=$(date -R | cut -d " " -f -4)
MYIP=$(curl -sS ipv4.icanhazip.com)
uphours=`uptime -p | awk '{print $2,$3}' | cut -d , -f1`
upminutes=`uptime -p | awk '{print $4,$5}' | cut -d , -f1`
uptimecek=`uptime -p | awk '{print $6,$7}' | cut -d , -f1`
tram=$( free -h | awk 'NR==2 {print $2}' )
uram=$( free -h | awk 'NR==2 {print $3}' )
clear
clear && clear && clear
clear;clear;clear
echo -e " $YB╭══════════════════════════════════════════════════════════╮${NC}"
echo -e " $YB│${NC} ${COLBG1}               ${WB} • VIPSSH VPN TUNNELING •                ${NC} $YB│ $NC"
echo -e " $YB╰══════════════════════════════════════════════════════════╯${NC}"
echo -e " $YB╭══════════════════════════════════════════════════════════╮${NC}"
echo -e " $YB│$NC${WB} ❈ OS                 ${YB}: ${WB}$MODEL2${NC}"
echo -e " $YB│ $NC${WB}❈ CORE & CPU Usage   ${YB}: ${WB}$CORE Core & $cpu_usage"
echo -e " $YB│$NC${WB} ❈ RAM                ${YB}: ${WB}$tram / $uram${NC}"
echo -e " $YB│$NC${WB} ❈ DATE               ${YB}: ${WB}$DATE WIB${NC}"
echo -e " $YB│$NC${WB} ❈ UPTIME             ${YB}: ${WB}$uphours $upminutes $uptimecek"
echo -e " $YB│$NC${WB} ❈ TIME               ${YB}: ${WB}$WKT${NC}"
echo -e " $YB│$NC${WB} ❈ ISP                ${YB}: ${WB}$ISP${NC}"
echo -e " $YB│$NC${WB} ❈ City               ${YB}: ${WB}$CITY${NC}"
echo -e " $YB│$NC${WB} ❈ IP VPS             ${YB}: ${WB}$MYIP${NC}"
echo -e " $YB│$NC${WB} ❈ DOMAIN             ${YB}: ${WB}$domain${NC}"
echo -e " $YB│$NC${WB} ❈ NSDomain           ${YB}: ${WB}$(cat /usr/sbin/vipssh/slowdns/dns)"
echo -e " $YB╰══════════════════════════════════════════════════════════╯${NC}"
echo -e "    $YB╭═════════════════ • ${NC}${WB}STATUS SERVER${NC}${YB} • ═══════════════╮${NC}"
echo -e "     ${WB} RESTAPI : ${status_tunnapi} ${WB} XRAY : ${status_xray} ${WB} NGINX : ${status_nginx}$NC"
echo -e "     ${WB} BALANCE : ${status_haproxy} ${WB} SLOW : ${status_slowdns} ${WB} SSHUD : ${status_udp} ${NC}"
echo -e "    $YB╰═══════════════════════════════════════════════════╯${NC}"
echo -e "              ${WB}----- [ Total Accounts ] -----${NC}"
echo -e ""
echo -e " ${WB}| SSH  | Vmess | Vless | Trojan | Shadowsocks | Shadowsocks2022 | Socks5 | ${NC}"
echo -e " ${MB}| $(printf "%4s" $ssh_akun) | $(printf "%5s" $((vmess_akun + allxray_akun))) | $(printf "%5s" $((vless_akun + allxray_akun))) | $(printf "%6s" $((trojan_akun + allxray_akun))) |$(printf "%12s" $((shadowsocks_akun + allxray_akun))) |$(printf "%16s" $((shadowsocks2022_akun + allxray_akun))) | $(printf "%6s" $((socks_akun + allxray_akun))) | ${NC}"
echo -e "${BB}——————————————————————————————————————————————————————————————————————————${NC}"
echo -e "                ${WB}----- [ Xray Menu ] -----${NC}               "
echo -e "${BB}——————————————————————————————————————————————————————————————————————————${NC}"
echo -e " ${MB}[1]${NC} ${YB}SSH Menu${NC}            ${MB}[5]${NC} ${YB}Shadowsocks Menu${NC}"
echo -e " ${MB}[2]${NC} ${YB}Vmess Menu${NC}          ${MB}[6]${NC} ${YB}Shadowsocks 2022 Menu${NC}"
echo -e " ${MB}[3]${NC} ${YB}Vless Menu${NC}          ${MB}[7]${NC} ${YB}Socks5 Menu${NC}"
echo -e " ${MB}[4]${NC} ${YB}Trojan Menu${NC}         ${MB}[8]${NC} ${YB}All Xray Menu${NC}"
echo -e "${BB}——————————————————————————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}----- [ Utility ] -----${NC}                "
echo -e "${BB}——————————————————————————————————————————————————————————————————————————${NC}"
echo -e " ${MB}[9]${NC}  ${YB}Log Create Account${NC}  ${MB}[16]${NC} ${YB}DNS Setting${NC}"
echo -e " ${MB}[10]${NC} ${YB}Speedtest${NC}           ${MB}[17]${NC} ${YB}Check DNS Status${NC}"
echo -e " ${MB}[11]${NC} ${YB}Change Domain${NC}       ${MB}[18]${NC} ${YB}Change Xray-core Mod${NC}"
echo -e " ${MB}[12]${NC} ${YB}Cert Acme.sh${NC}        ${MB}[19]${NC} ${YB}Change Xray-core Official${NC}"
echo -e " ${MB}[13]${NC} ${YB}About Script${NC}        ${MB}[20]${NC} ${YB}Menu Backup Telegram${NC}"
echo -e " ${MB}[14]${NC} ${YB}Status Limit${NC}        ${MB}[21]${NC} ${YB}Auto Backup Telegram${NC}"
echo -e " ${MB}[15]${NC} ${YB}SlowDNS Service${NC}"    
echo -e "${BB}——————————————————————————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}----- [ Registered ] -----${NC}                "
echo -e ""
echo -e "$MB╭═════════════════════════════════════════════════════════╮${NC}"
echo -e "$MB│$NC ${YB} ❈ Registered Client ${NC}  : ${YB}$USERNAME${NC}"
echo -e "$MB│$NC ${YB} ❈ Roles License ${NC}      : ${YB}$CAPITALIZED_ROLE${NC}$MB"
echo -e "$MB│$NC ${YB} ❈ Validity Period ${NC}    : ${YB}Remaining $diff Days Expiration ${NC}$MB"
echo -e "$MB╰═════════════════════════════════════════════════════════╯${NC}"
echo -e ""
read -p " Select Menu :  "  opt
echo -e ""
case $opt in
1) clear ; menussh ;;
2) clear ; vmess ;;
3) clear ; vless ;;
4) clear ; trojan ;;
5) clear ; shadowsocks ;;
6) clear ; shadowsocks2022 ;;
7) clear ; socks ;;
8) clear ; allxray ;;
9) clear ; log-create ;;
10) clear ; speedtest ;;
11) clear ; dns ;;
12) clear ; certxray ;;
13) clear ; about ;;
14) clear ; status-limit ;;
15) clear ; menudns ;;
16) clear ; changer ;;
17) clear ;
resolvectl status
echo ""
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
echo ""
echo ""
menu ;;
18) clear ; xraymod ;;
19) clear ; xrayofficial ;;
# 20) clear ; encshc ;;
20) clear ; menu_backup ;;
21) clear ; autobackup ;;
x) exit ;;
*) echo -e "${YB}salah input${NC}" ; sleep 1 ; menu ;;
esac


