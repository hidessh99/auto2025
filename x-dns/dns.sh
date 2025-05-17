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
green='\e[0;32m'
sudo apt update -y >> /dev/null 2>&1
apt install jq curl -y >> /dev/null 2>&1
apiFILE=$(cat /usr/bin/urlpanel)
GIT_CMD="$apiFILE/api/files/"
ns_domain_cloudflare() {
	DOMAIN=portalsrc.mom
	DAOMIN=$(cat /usr/local/etc/xray/domain)
	SUB=$(tr </dev/urandom -dc a-z0-9 | head -c6)
	SUB_DOMAIN=${SUB}.portalsrc.mom
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
	echo -e "${GREEN}NAMESERVER XSLOW DNS POWER BY VIPSSH.NET${NC}"
	sleep 1
	echo ""
	echo ""
	echo "Updating DNS NS for ${NS_DOMAIN}"
	echo $NS_DOMAIN >/usr/local/etc/xray/dns

}

    domain_add() {
    read -p "Input ns-sg1dns Example : " domainns
    echo $domainns >/usr/local/etc/xray/dns

}

setup_dnstt() {
	cd
	rm -rf *
	mkdir -p /usr/local/etc/slowdns
	wget -q --show-progress -O dnstt-server "$apiFILE/api/files/x-dns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server
	wget -q --show-progress -O dnstt-client "$apiFILE/api/files/x-dns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
	chmod +x *
	mv * /usr/local/etc/slowdns
	wget -q --show-progress -O /etc/systemd/system/client.service "$apiFILE/api/files/x-dns/client" >/dev/null 2>&1
	wget -q --show-progress -O /etc/systemd/system/server.service "$apiFILE/api/files/x-dns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service
}

setup_dnstt2() {
	cd
	rm -rf *
	mkdir -p /usr/local/etc/slowdns
	wget -q --show-progress -O dnstt-server "$apiFILE/api/files/x-dns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server
	wget -q --show-progress -O dnstt-client "$apiFILE/api/files/x-dns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
	chmod +x *
	mv * /usr/local/etc/slowdns
	wget -q --show-progress -O /etc/systemd/system/client.service "$apiFILE/api/files/x-dns/client" >/dev/null 2>&1
	wget -q --show-progress -O /etc/systemd/system/server.service "$apiFILE/api/files/x-dns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$domainns/g" /etc/systemd/system/client.service
	sed -i "s/xxxx/$domainns/g" /etc/systemd/system/server.service
}

  install_sc() {
    domain_add
	setup_dnstt2
}

  install_sc_cf() {
    ns_domain_cloudflare
	setup_dnstt
}

installdns() {
echo -e "${RED}SCRIPT AUTO INSTALL XSLOW DNS POWER BY ZENSSH!!!${NC}"
echo -e ""
echo -e "1).${green}MANUAL POINTING${NC}(Manual DNS-resolved IP address of the domain)"
echo -e "2).${green}AUTO POINTING${NC}(Auto DNS-resolved IP address of the domain)"
read -p "between auto pointing / manual pointing what do you choose[ 1 - 2 ] : " menu_num

case $menu_num in
    1)
        install_sc
    ;;
    2)
        install_sc_cf
    ;;
    *)
        echo -e "${RED}You wrong command !${NC}"
        clear
        installdns
    ;;
esac
}
installdns
