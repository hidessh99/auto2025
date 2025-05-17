#!/bin/bash
# PT. FASTNET DIGITAL GRUP
# Support me Thanks
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
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
Suffix="\033[0m"
# MULAI INSTALL
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
ns_domain_cloudflare() {
	DOMAIN=cloudsrv.me
	DAOMIN=$(cat /usr/local/etc/xray/domain)
	SUB=$(tr </dev/urandom -dc a-z0-9 | head -c6)
	SUB_DOMAIN=${SUB}.cloudsrv.me
	NS_DOMAIN=ns-${SUB_DOMAIN}
	CF_ID=youemail@gmail.com
    CF_KEY=a014b1da0eab94cbe980e8024334637017497
	set -euo pipefail
	IP=$(wget -qO- ipinfo.io/ip)
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
          -H "X-Auth-Email: ${CF_ID}" \
          -H "X-Auth-Key: ${CF_KEY}" \
          -H "Content-Type: application/json" \
          --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')

	ZONE=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	RECORD=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	if [[ "${#RECORD}" -le 10 ]]; then
		RECORD=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "X-Auth-Email: ${CF_ID}" \
			-H "X-Auth-Key: ${CF_KEY}" \
			-H "Content-Type: application/json" \
			--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DAOMIN}'","proxied":false}' | jq -r .result.id
		)
	fi

	RESULT=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" \
		--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","proxied":false}'
	)
	echo ""
	echo ""
	echo -e "${GREEN}NAMESERVER XSLOW DNS POWER BY ZENSSH${NC}"
	sleep 1
	echo ""
	echo ""
	echo "Updating DNS NS for ${NS_DOMAIN}"
	echo $NS_DOMAIN >/usr/sbin/vipssh/slowdns/dns

}

    domain_add() {
    echo ""
    echo ""
    read -p "Input ns-sg1dns Example : " domainns
    echo $domainns >/usr/sbin/vipssh/slowdns/dns

}

setup_dnstt() {
	cd
	mkdir -p /usr/sbin/vipssh/slowdns
    mkdir -p /etc/slowdns
    cd /etc/slowdns
	wget -q --show-progress -O dnstt-server "$apiFILE/api/files/x-dns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server
	wget -q --show-progress -O dnstt-client "$apiFILE/api/files/x-dns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
	chmod +x *
	mv * /usr/sbin/vipssh/slowdns
    cd
	wget -q --show-progress -O /etc/systemd/system/client.service "$apiFILE/api/files/x-dns/client" >/dev/null 2>&1
	wget -q --show-progress -O /etc/systemd/system/server.service "$apiFILE/api/files/x-dns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service
    rm -rfv /etc/slowdns >/dev/null 2>&1
}

setup_dnstt2() {
	cd
	mkdir -p /usr/sbin/vipssh/slowdns
    mkdir -p /etc/slowdns
    cd /etc/slowdns
	wget -q --show-progress -O dnstt-server "$apiFILE/api/files/x-dns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server
	wget -q --show-progress -O dnstt-client "$apiFILE/api/files/x-dns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
	chmod +x *
	mv * /usr/sbin/vipssh/slowdns
    cd
	wget -q --show-progress -O /etc/systemd/system/client.service "$apiFILE/api/files/x-dns/client" >/dev/null 2>&1
	wget -q --show-progress -O /etc/systemd/system/server.service "$apiFILE/api/files/x-dns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$domainns/g" /etc/systemd/system/client.service
	sed -i "s/xxxx/$domainns/g" /etc/systemd/system/server.service
    rm -rfv /etc/slowdns >/dev/null 2>&1
}

restartdns() {
systemctl daemon-reload
systemctl enable client >> /dev/null 2>&1
systemctl enable server >> /dev/null 2>&1
systemctl start client >> /dev/null 2>&1
systemctl start server >> /dev/null 2>&1
systemctl restart client >> /dev/null 2>&1
systemctl restart server >> /dev/null 2>&1
}

iptablesdns() {
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
iptables-save > /etc/iptables/rules.v4 >> /dev/null 2>&1
iptables-save > /etc/iptables.up.rules >> /dev/null 2>&1
netfilter-persistent save >> /dev/null 2>&1
netfilter-persistent reload >> /dev/null 2>&1
}

delldns() {
systemctl daemon-reload
systemctl stop client >> /dev/null 2>&1
systemctl stop server >> /dev/null 2>&1
systemctl disable client >> /dev/null 2>&1
systemctl disable server >> /dev/null 2>&1
rm -rfv /etc/systemd/system/client.service >> /dev/null 2>&1
rm -rfv /etc/systemd/system/server.service >> /dev/null 2>&1
rm -rfv /usr/sbin/vipssh/slowdns/dnstt-server >> /dev/null 2>&1
rm -rfv /usr/sbin/vipssh/slowdns/dnstt-client >> /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/dns > /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/server.pub > /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/server.key > /dev/null 2>&1
echo "null" >> /usr/sbin/vipssh/slowdns/dns
echo "null" >> /usr/sbin/vipssh/slowdns/server.pub
echo "null" >> /usr/sbin/vipssh/slowdns/server.key
chmod +x /usr/sbin/vipssh/slowdns/*
iptables -D INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
iptables-save > /etc/iptables/rules.v4 >> /dev/null 2>&1
iptables-save > /etc/iptables.up.rules >> /dev/null 2>&1
netfilter-persistent save >> /dev/null 2>&1
netfilter-persistent reload >> /dev/null 2>&1
clear
echo ""
echo ""
echo -e "${green}Success${NC} (XSlowDNS Service) Disable"
menudns
}

hasildns(){
clear
Nameserver=$(cat /usr/sbin/vipssh/slowdns/dns)
pub_key=$(cat /usr/sbin/vipssh/slowdns/server.pub)
echo -e " ${green}SlowDNS is enabled${Suffix}"
echo -e ""
echo -e " Nameserver : ${yellow}${Nameserver}${Suffix}"
echo -e " PUB Key    : ${blue}${pub_key}${Suffix}"
echo -e ""
echo -e "tap enter now back to menu"
read
menudns
}

  install_sc() {
    checkdns
    domain_add
	setup_dnstt2
    iptablesdns
    restartdns
    hasildns
}

  install_sc_cf() {
    checkdns
    ns_domain_cloudflare
	setup_dnstt
    iptablesdns
    restartdns
    hasildns
}

checkdns(){
if systemctl is-active --quiet server.service; then
    clear
    echo ""
    echo ""
    echo -e "${RED}Error${NC} You Already ON (XSlowDNS Service) Please Turn OFF"
    menudns
fi
}

installdns() {
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
if systemctl is-active --quiet server.service; then
    sts="${Info}"
else
    sts="${Error}"
fi
clear
echo -e "${RED}SCRIPT AUTO INSTALL XSLOW DNS POWER BY ZENSSH!!!${NC}"
echo -e ""
echo -e "Status XSlowDNS Service : $sts        "
echo -e ""
echo -e "1).${green}MANUAL POINTING${NC}(Manual DNS-resolved IP address of the domain)"
echo -e "2).${green}AUTO POINTING${NC}(Auto DNS-resolved IP address of the domain)"
echo -e "3).${RED}Turn Off${NC} (XSlowDNS Service)"
echo -e "4).Back to Menu"
echo ""
read -p "between auto pointing / manual pointing what do you choose[ 1 - 4 ] : " menu_num

case $menu_num in
    1)
        install_sc
    ;;
    2)
        install_sc_cf
    ;;
    3)
        delldns
    ;;
    4)
        menu
    ;;
    *)
        echo -e "${RED}You wrong command !${NC}"
        clear
        menudns
    ;;
esac
}
installdns
