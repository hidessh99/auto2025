#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/vipssh/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
RB="\033[0;31m"
BB='\e[1;32m'
RED='\033[0;31m'
GREEN='\033[0;32m'
COLOR1="$(cat /etc/vipssh/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/vipssh/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
###########- END COLOR CODE -##########
apiFILE=$(cat /usr/bin/urlpanel)
checkPermission() {
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

red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
checkPermission
function addssh(){
clear
dnsdomain=$(cat /usr/sbin/vipssh/slowdns/dns)
dnskey=$(cat /usr/sbin/vipssh/slowdns/server.pub)
domen=`cat /usr/local/etc/xray/domain`
portsshws="80, 8880, 8080, 2082, 2086, 2095"
wsssl="443, 2053, 2083, 2087, 2096, 8443"

echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • SSH PANEL MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -p "   Username : " Login

CEKFILE=/usr/local/etc/xray/ssh.txt
if [ -f "$CEKFILE" ]; then
file001="OK"
else
touch /usr/local/etc/xray/ssh.txt
fi

if grep -qw "$Login" /usr/local/etc/xray/ssh.txt; then
echo -e "$COLOR1│${NC}  [Error] Username \e[31m$Login\e[0m already exist"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menussh
else
echo "$Login" >> /usr/local/etc/xray/ssh.txt
fi

if [ -z $Login ]; then
echo -e "$COLOR1│${NC} [Error] Username cannot be empty "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "    Press any key to back on menu"
clear
menussh
fi

read -p "   Password : " Pass
if [ -z $Pass ]; then
echo -e "$COLOR1│${NC}  [Error] Password cannot be empty "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
clear
menussh
fi
read -p "   Expired (hari): " masaaktif
if [ -z $masaaktif ]; then
echo -e "$COLOR1│${NC}  [Error] EXP Date cannot be empty "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menussh
fi

IP=$(curl -sS ifconfig.me);
ossl="443, 1194, 2200"
opensh="22, 2222, 2223"
db="143, 90, 69"
ssl="443, 2053, 2083, 2087, 2096, 8443"
sqd="8080, 3128"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
dnsdomain=$(cat /usr/sbin/vipssh/slowdns/dns)
dnskey=$(cat /usr/sbin/vipssh/slowdns/server.pub)
# OhpSSH=`cat /root/log-install.txt | grep -w "OHP SSH" | cut -d: -f2 | awk '{print $1}'`
# OhpDB=`cat /root/log-install.txt | grep -w "OHP DBear" | cut -d: -f2 | awk '{print $1}'`
# OhpOVPN=`cat /root/log-install.txt | grep -w "OHP OpenVPN" | cut -d: -f2 | awk '{print $1}'`

sleep 1
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
if [ ! -e /etc/ssh ]; then
  mkdir -p /etc/ssh
fi
DATADB=$(cat /etc/ssh/.ssh.db | grep "^###" | grep -w "${Login}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${Login}\b/d" /etc/ssh/.ssh.db
fi
echo "### ${Login}" >>/etc/ssh/.ssh.db
if [[ ! -z "${PID}" ]]; then
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • SSH PANEL MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│$NC  Username   : $Login"
echo -e "$COLOR1│$NC  Password   : $Pass"
echo -e "$COLOR1│$NC  Expired On : $exp"
echo -e "$COLOR1──────────────────────────────────────────────────${NC}"
echo -e "$COLOR1 $NC  IP         : $IP"
echo -e "$COLOR1 $NC  Host       : $domen"
echo -e "$COLOR1 $NC  OpenSSH    : $opensh"
echo -e "$COLOR1 $NC  UDP-CUSTOM : 1-65535"
echo -e "$COLOR1 $NC  Dropbear   : $db"
echo -e "$COLOR1 $NC  SSH-WS     : $portsshws"
echo -e "$COLOR1 $NC  SSH-SSL-WS : $wsssl"
echo -e "$COLOR1 $NC  SSL/TLS    : $ssl"
echo -e "$COLOR1 $NC  UDPGW      : 7100-7300-7400-7500"
echo -e "$COLOR1 $NC  NS Slowdns : $dnsdomain"
echo -e "$COLOR1 $NC  DNS PubKey : $dnskey"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "  GET wss://bug.com/ HTTP/1.1[crlf]Host: [host] [crlf]Upgrade: websocket[crlf][crlf]"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
else
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • SSH PANEL MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC  Username   : $Login"
echo -e "$COLOR1 $NC  Password   : $Pass"
echo -e "$COLOR1 $NC  Expired On : $exp"
echo -e "$COLOR1──────────────────────────────────────────────────${NC}"
echo -e "$COLOR1 $NC  IP         : $IP"
echo -e "$COLOR1 $NC  Host       : $domen"
echo -e "$COLOR1 $NC  OpenSSH    : $opensh"
echo -e "$COLOR1 $NC  UDP-CUSTOM : 1-65535"
echo -e "$COLOR1 $NC  Dropbear   : $db"
echo -e "$COLOR1 $NC  SSH-WS     : $portsshws"
echo -e "$COLOR1 $NC  SSH-SSL-WS : $wsssl"
echo -e "$COLOR1 $NC  SSL/TLS    : $ssl"
echo -e "$COLOR1 $NC  UDPGW      : 7100-7300-7400-7500"
echo -e "$COLOR1 $NC  NS Slowdns : $dnsdomain"
echo -e "$COLOR1 $NC  DNS PubKey : $dnskey"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "  GET wss://bug.com/ HTTP/1.1[crlf]Host: [host] [crlf]Upgrade: websocket[crlf][crlf]"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
fi
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menussh
}
function sshwss(){
    clear
portdb="143, 90, 69"
portsshws="80, 8880, 8080, 2082, 2086, 2095"
if [ -f "/etc/systemd/system/sshws.service" ]; then
clear
else
wget -q -O /usr/bin/proxy3.js "https://raw.githubusercontent.com/SSHSEDANG4/multiws/main/ssh/proxy3.js"
cat <<EOF > /etc/systemd/system/sshws.service
[Unit]
Description=WSenabler
Documentation=https://t.me/yukikuroyamaa

[Service]
Type=simple
ExecStart=/usr/bin/ssh-wsenabler
KillMode=process
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

fi

function start() {
        clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • WEBSOCKET MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
wget -q -O /usr/bin/ssh-wsenabler "https://raw.githubusercontent.com/SSHSEDANG4/multiws/main/ssh/sshws-true.sh" && chmod +x /usr/bin/ssh-wsenabler
systemctl daemon-reload >/dev/null 2>&1
systemctl enable sshws.service >/dev/null 2>&1
systemctl start sshws.service >/dev/null 2>&1
sed -i "/SSH Websocket/c\   - SSH Websocket           : $portsshws [ON]" /root/log-install.txt
echo -e "$COLOR1│${NC}  [INFO] • ${green}SSH Websocket Started${NC}"
echo -e "$COLOR1│${NC}  [INFO] • Restart is require for Changes"
echo -e "$COLOR1│${NC}           to take effect"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
sshwss
}

function stop() {
        clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • WEBSOCKET MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
systemctl stop sshws.service >/dev/null 2>&1
tmux kill-session -t sshws >/dev/null 2>&1
sed -i "/SSH Websocket/c\   - SSH Websocket           : $portsshws [OFF]" /root/log-install.txt
echo -e "$COLOR1│${NC}  [INFO] • ${red}SSH Websocket Stopped${NC}"
echo -e "$COLOR1│${NC}  [INFO] • Restart is require for Changes"
echo -e "$COLOR1│${NC}           to take effect"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
sshwss
}

clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • WEBSOCKET MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
if [[ ! -z "${PID}" ]]; then
echo -e "$COLOR1│$NC   • Websocket Is ${COLOR1}Running$NC"
else
echo -e "$COLOR1│$NC   • Websocket Is ${red}Not Running$NC"
fi
echo -e "$COLOR1│$NC"
echo -e "$COLOR1│$NC   ${COLOR1}[01]${NC} • Enable SSH WS   ${COLOR1}[02]${NC} • Disable SSH WS"
echo -e "$COLOR1│$NC"
echo -e "$COLOR1│$NC   ${COLOR1}[00]${NC} • GO BACK"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; start ;;
02 | 2) clear ; stop ;;
00 | 0) clear ; menu ;;
*) clear ; menu-set ;;
esac
}
function cekssh(){

clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}              • SSH ACTIVE USERS •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e ""

if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure";
fi

data=( `ps aux | grep -i dropbear | awk '{print $2}'`);
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt;
for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $10}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $12}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi

done
echo " "
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $9}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi


done
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
        echo " "

        cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
        cat /tmp/vpn-login-tcp.txt
fi

if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
        echo " "

        cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
        cat /tmp/vpn-login-udp.txt
fi


rm -f /tmp/login-db-pid.txt
rm -f /tmp/login-db.txt
rm -f /tmp/vpn-login-tcp.txt
rm -f /tmp/vpn-login-udp.txt
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo "";
read -n 1 -s -r -p "   Press any key to back on menu"
clear
menussh
}

function delssh() {
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}  • SSH DELETE USERS •             ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"

    # Fetch the list of users with UID >= 1000 and not "nobody"
    users_list=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

    # Check if there are any users that match the criteria
    if [ -z "$users_list" ]; then
        echo -e "$COLOR1[INFO] No users found that match the criteria${NC}"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
        echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        echo -e ""
        read -n 1 -s -r -p "   Press any key to back on menu"
        clear
        menussh
        return
    fi

    i=1
    # Display the list of users with numbers for selection
    echo -e "$COLOR1[INFO] Select User For Delete:${NC}"
    while read -r user; do
        echo "   $i. $user"
        ((i++))
    done <<< "$users_list"

    echo -e ""
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    read -p "Select the number of the user to delete: " choice
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

    # Validate user input
    if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $i ]]; then
        selected_user=$(echo "$users_list" | sed -n "${choice}p")

        # Perform user deletion
        userdel -r -f "$selected_user" > /dev/null 2>&1
        sed -i "/\b$selected_user\b/d" /usr/local/etc/xray/ssh.txt
        rm -rf /var/www/html/ssh/ssh-$selected_user.txt
        sed -i "/\b$selected_user\b/d" /etc/ssh/.ssh.db
        systemctl restart ssh > /dev/null 2>&1
        systemctl restart sshd > /dev/null 2>&1
        systemctl restart dropbear > /dev/null 2>&1
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}• [INFO] User $selected_user was removed. • ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    else
        echo -e "$COLOR1│${NC} [ERROR] Invalid Select Number. "
    fi

    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
    echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    clear
    menussh
}

function renewssh(){
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             • RENEW SSH ACCOUNT •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -p "   Username : " User

if getent passwd $User > /dev/null 2>&1; then
ok="ok"
else
echo -e "$COLOR1│${NC}   [INFO] Failure: User $User Not Exist."
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
fi

if [ -z $User ]; then
echo -e "$COLOR1│${NC}   [Error] Username cannot be empty "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
fi

egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Day Extend : " Days
if [ -z $Days ]; then
Days="1"
fi
Today=`date +%s`
Days_Detailed=$(( $Days * 86400 ))
Expire_On=$(($Today + $Days_Detailed))
Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
passwd -u $User
usermod -e  $Expiration $User
egrep "^$User" /etc/passwd >/dev/null
echo -e "$Pass\n$Pass\n"|passwd $User &> /dev/null
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             • RENEW SSH ACCOUNT •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "   Username   : $User"
echo -e "   Days Added : $Days Days"
echo -e "   Expires on : $Expiration_Display"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
else
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             • RENEW SSH ACCOUNT •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "   Username Doesnt Exist      "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
clear
menussh
}

function memberssh(){
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}            • MEMBER SSH ACCOUNT •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo "   USERNAME          EXP DATE          STATUS"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "   • $AKUN" "$exp   " "LOCKED"
else
printf "%-17s %2s %-17s %2s \n" "   • $AKUN" "$exp   " "UNLOCKED"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo "   Total: $JUMLAH User"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
clear
menussh
}

function unlocksshall() {
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}            • UNLOCK SSH ACCOUNTS •            ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo "   USERNAME          EXP DATE          STATUS"
    echo -e "$COLOR1├─────────────────────────────────────────────────┤${NC}"

        # Declare an empty array to hold locked usernames
            locked_users=()

            while IFS=: read -r username _ uid _; do
                if [[ $uid -ge 1000 ]] && [[ "$username" != "nobody" ]]; then
                    status=$(passwd -S "$username" | awk '{print $2}')
                    if [[ "$status" == "L" ]]; then
                        passwd -u "$username" &> /dev/null  # Ignore output from passwd command
                        exp_date=$(chage -l $username | grep "Account expires" | awk -F": " '{print $2}')
                        printf "%-17s %2s %-17s %2s \n" "   • $username" "$exp_date     " "UNLOCKED"

                        # Append the username to the locked_users array
                        locked_users+=("$username")
                    fi
                fi
            done < /etc/passwd

            # Construct the JSON array
            json_array=$(printf '"%s",' "${locked_users[@]}")
            json_array=${json_array%,}

            # Sending all locked usernames to the API in one request
            curl -X POST -H "Content-Type: application/json" \
                -d "{ \"usernames\": [$json_array] }" \
                https://panel.zenssh.com/api/permission/update/unlock > /dev/null 2>&1

    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
    echo -e "$COLOR1│${NC}                   • VIPSSH.NET •            $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo ""
    read -n 1 -s -r -p "   Press any key to continue"
    menussh
}

function unlockssh() {
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}            • SSH UNLOCK USERS •               ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

    # Fetch the list of users with UID >= 1000, not "nobody", and are locked
    locked_users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while read -r user; do
        status=$(passwd -S "$user" | awk '{print $2}')
        if [[ "$status" == "L" ]]; then
            echo "$user"
        fi
    done)

    # Check if there are any locked users
    if [ -z "$locked_users" ]; then
        echo -e "$COLOR1[INFO] No locked users found.${NC}"
        read -n 1 -s -r -p "   Press any key to back to menu"
        menussh
        return
    fi

    i=1
    # Display the list of locked users with numbers for selection
    echo -e "$COLOR1[INFO] Select User For Unlock:${NC}"
    while read -r user; do
        echo "   $i. $user"
        ((i++))
    done <<< "$locked_users"

    echo -e ""
    read -p "Select the number of the user to unlock: " choice

    # Validate user input
    if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $((i-1)) ]]; then
        selected_user=$(echo "$locked_users" | sed -n "${choice}p")

        # Perform user unlocking
        passwd -u "$selected_user" > /dev/null 2>&1

        curl -X POST -H "Content-Type: application/json" \
            -d "{\"usernames\": [\"${selected_user}\"]}" \
            https://panel.zenssh.com/api/permission/update/unlock > /dev/null 2>&1

        echo -e "$COLOR1[INFO] User $selected_user was unlocked.${NC}"
    else
        echo -e "$COLOR1[ERROR] Invalid selection number."
    fi

    unlockssh
}


function lockssh() {
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}              • SSH LOCKED USERS •             ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"

    # Fetch the list of users with UID >= 1000 and not "nobody"
    users_list=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while read -r user; do
        status=$(passwd -S "$user" | awk '{print $2}')
        if [[ "$status" == "P" ]]; then
            echo "$user"
        fi
    done)

    # Check if there are any users that match the criteria
    if [ -z "$users_list" ]; then
        echo -e "$COLOR1[INFO] No users found that match the criteria${NC}"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
        echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        echo -e ""
        read -n 1 -s -r -p "   Press any key to back on menu"
        clear
        menussh
        return
    fi

    i=1
    # Display the list of users with numbers for selection
    echo -e "$COLOR1   [INFO] Select User For Locked:${NC}"
    while read -r user; do
        echo "   $i. $user"
        ((i++))
    done <<< "$users_list"

    echo -e ""
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    read -p "     Select the number of the user to locked: " choice
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

    # Validate user input
    if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $i ]]; then
        selected_user=$(echo "$users_list" | sed -n "${choice}p")

        # Perform user deletion
        passwd -l "$selected_user" > /dev/null 2>&1
        curl -X POST -H "Content-Type: application/json" \
            -d "{\"usernames\": [\"${selected_user}\"]}" \
            https://panel.zenssh.com/api/permission/update/lock > /dev/null 2>&1
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│   • [INFO] User $selected_user was locked. •     ${NC}"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    else
        echo -e "$COLOR1│${NC} [ERROR] Invalid Select Number. "
    fi

    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
    echo -e "$COLOR1│${NC}           • VIPSSH.NET •                    $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    clear
    menussh
}


function trialssh(){
clear
domen=`cat /usr/local/etc/xray/domain`
portsshws="80, 8880, 8080, 2082, 2086, 2095"
wsssl="443, 2053, 2083, 2087, 2096, 8443"
clear
IP=$(curl -sS ifconfig.me);
ossl="443, 1194, 2200"
opensh="22, 2222, 2223"
db="143, 90, 69"
ssl="443, 2053, 2083, 2087, 2096, 8443"
# OhpSSH=`cat /root/log-install.txt | grep -w "OHP SSH" | cut -d: -f2 | awk '{print $1}'`
dnsdomain=$(cat /usr/sbin/vipssh/slowdns/dns)
dnskey=$(cat /usr/sbin/vipssh/slowdns/server.pub)


Login=TRIAL`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=1
echo Ping Host &> /dev/null
echo Create Akun: $Login &> /dev/null
sleep 0.5
echo Setting Password: $Pass &> /dev/null
sleep 0.5
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
if [ ! -e /etc/ssh ]; then
  mkdir -p /etc/ssh
fi
DATADB=$(cat /etc/ssh/.ssh.db | grep "^###" | grep -w "${Login}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${Login}\b/d" /etc/ssh/.ssh.db
fi
echo "### ${Login}" >>/etc/ssh/.ssh.db
if [[ ! -z "${PID}" ]]; then
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}            • SSH TRIAL ACCOUNT •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC  Username   : $Login"
echo -e "$COLOR1 $NC  Password   : $Pass"
echo -e "$COLOR1 $NC  Expired On : $exp"
echo -e "$COLOR1──────────────────────────────────────────────────${NC}"
echo -e "$COLOR1 $NC  IP         : $IP"
echo -e "$COLOR1 $NC  Host       : $domen"
echo -e "$COLOR1 $NC  OpenSSH    : $opensh"
echo -e "$COLOR1 $NC  UDP-CUSTOM : 1-65535"
echo -e "$COLOR1 $NC  Dropbear   : $db"
echo -e "$COLOR1 $NC  SSH-WS     : $portsshws"
echo -e "$COLOR1 $NC  SSH-SSL-WS : $wsssl"
echo -e "$COLOR1 $NC  SSL/TLS    : $ssl"
echo -e "$COLOR1 $NC  UDPGW      : 7100-7300-7400-7500"
echo -e "$COLOR1 $NC  NS Slowdns : $dnsdomain"
echo -e "$COLOR1 $NC  DNS PubKey : $dnskey"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "  GET wss://bug.com/ HTTP/1.1[crlf]Host: [host] [crlf]Upgrade: websocket[crlf][crlf]"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

else

echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}            • SSH TRIAL ACCOUNT •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC  Username   : $Login"
echo -e "$COLOR1 $NC  Password   : $Pass"
echo -e "$COLOR1 $NC  Expired On : $exp"
echo -e "$COLOR1──────────────────────────────────────────────────${NC}"
echo -e "$COLOR1 $NC  IP         : $IP"
echo -e "$COLOR1 $NC  Host       : $domen"
echo -e "$COLOR1 $NC  OpenSSH    : $opensh"
echo -e "$COLOR1 $NC  UDP-CUSTOM : 1-65535"
echo -e "$COLOR1 $NC  Dropbear   : $db"
echo -e "$COLOR1 $NC  SSH-WS     : $portsshws"
echo -e "$COLOR1 $NC  SSH-SSL-WS : $wsssl"
echo -e "$COLOR1 $NC  SSL/TLS    : $ssl"
echo -e "$COLOR1 $NC  UDPGW      : 7100-7300-7400-7500"
echo -e "$COLOR1 $NC  NS Slowdns : $dnsdomain"
echo -e "$COLOR1 $NC  DNS PubKey : $dnskey"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC}  GET wss://bug.com/ HTTP/1.1[crlf]Host: [host] [crlf]Upgrade: websocket[crlf][crlf]"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
clear
menussh
}
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}               • SSH PANEL MENU •              ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e " $COLOR1┌───────────────────────────────────────────────┐${NC}"

if [ "$ROLES" == "admin" ]; then
    echo -e " $COLOR1│$NC   ${COLOR1}[01]${NC} • ADD SSH         ${COLOR1}[06]${NC} • DELETE SSH    $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[02]${NC} • TRIAL SSH       ${COLOR1}[07]${NC} • RENEW SSH     $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[03]${NC} • USER ONLINE     ${COLOR1}[08]${NC} • USERS LIST    $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[04]${NC} • LIMIT SSH       ${COLOR1}[09]${NC} • UNLOCK SSH    $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[05]${NC} • UNLOCK ALL      ${COLOR1}[10]${NC} • LOCK SSH      $COLOR1│$NC"
else
    echo -e " $COLOR1│$NC   ${COLOR1}[01]${NC} • ADD SSH         ${COLOR1}[04]${NC} • DELETE SSH    $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[02]${NC} • TRIAL SSH       ${COLOR1}[05]${NC} • RENEW SSH     $COLOR1│$NC"
    echo -e " $COLOR1│$NC   ${COLOR1}[03]${NC} • USER ONLINE     ${COLOR1}[06]${NC} • USERS LIST    $COLOR1│$NC"
fi

echo -e " $COLOR1│$NC                                               $COLOR1│$NC"
echo -e " $COLOR1│$NC   ${COLOR1}[00]${NC} • GO BACK                              $COLOR1│$NC"
echo -e " $COLOR1└───────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}                  • VIPSSH.NET •                 $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

read -p " Select menu :  "  opt
echo -e ""

case $opt in
    01 | 1) clear ; addssh ;;
    02 | 2) clear ; trialssh ;;
    03 | 3) clear ; cekssh ;;
    04 | 4)
        if [ "$ROLES" == "admin" ]; then
            clear ; autokill
        else
            clear ; delssh
        fi ;;
    05 | 5)
        if [ "$ROLES" == "admin" ]; then
            clear ; unlocksshall
        else
            clear ; renewssh
        fi ;;
    06 | 6)
        if [ "$ROLES" == "admin" ]; then
            clear ; delssh
        else
            clear ; memberssh
        fi ;;
    07 | 7) [ "$ROLES" == "admin" ] && clear ; renewssh ;;
    08 | 8) [ "$ROLES" == "admin" ] && clear ; memberssh ;;
    09 | 9) [ "$ROLES" == "admin" ] && clear ; unlockssh ;;
    10 ) [ "$ROLES" == "admin" ] && clear ; lockssh ;;
    00 | 0) clear ; menu ;;
    *) menussh ; clear menussh ;;
esac



