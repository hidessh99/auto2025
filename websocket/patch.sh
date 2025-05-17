#!/bin/bash
# vipssh.net
# ==================================================
# initialisasi pembaharuan script
NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
# Warna
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
apiFILE=$(cat /usr/bin/urlpanel)
apt update -y
apt upgrade -y
apt-get install -y curl build-essential make gcc libpcre3 libpcre3-dev libpcre++-dev zlib1g-dev libbz2-dev libxslt1-dev libxml2-dev libgeoip-dev libgoogle-perftools-dev libgd-dev libperl-dev libssl-dev libcurl4-openssl-dev
apt-get install -y libpcre2-posix0 >/dev/null 2>&1
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Please Wait Update Progress${NC}"
wget -q -O /root/vipssh.lst "$apiFILE/api/files/patch/vipssh.lst" >/dev/null 2>&1
rm -rf /etc/security/limits.conf >/dev/null 2>&1
wget -q -O /etc/security/limits.conf "$apiFILE/api/files/patch/limits.conf" >/dev/null 2>&1
rm -rf /etc/sysctl.conf >/dev/null 2>&1
wget -q -O /etc/sysctl.conf "$apiFILE/api/files/patch/sysctl.conf" >/dev/null 2>&1
sysctl -p >/dev/null 2>&1
ulimit -n 10000000
cd
systemctl stop haproxy.service >/dev/null 2>&1
systemctl disable haproxy.service >/dev/null 2>&1
systemctl stop ws.service >/dev/null 2>&1
systemctl disable ws.service >/dev/null 2>&1
systemctl stop nginx.service >/dev/null 2>&1
systemctl stop xray.service >/dev/null 2>&1
systemctl disable xray.service >/dev/null 2>&1
systemctl stop tunnapi.service >/dev/null 2>&1
systemctl disable tunnapi.service >/dev/null 2>&1
systemctl stop restapi.service >/dev/null 2>&1
systemctl disable restapi.service >/dev/null 2>&1
rm -rf /etc/systemd/system/tunnapi.service >/dev/null 2>&1
rm -rf /etc/systemd/system/restapi.service >/dev/null 2>&1
cd
rm -rf /etc/nginx/nginx.conf >/dev/null 2>&1
rm -rf /etc/nginx/conf.d/*.conf >/dev/null 2>&1
wget http://nginx.org/download/nginx-1.23.0.tar.gz >/dev/null 2>&1
tar xvf nginx-1.23.0.tar.gz && cd nginx-1.23.0/
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Progress 2${NC}"
make >/dev/null 2>&1
clear
make install >/dev/null 2>&1
cd
echo -e "${GB}[ INFO ]${NC} ${YB}Progress 3${NC}"
useradd -r nginx >/dev/null 2>&1
rm -rfv /var/cache/nginx >/dev/null 2>&1
mkdir /var/cache/nginx && sudo touch /var/cache/nginx/client_temp >/dev/null 2>&1
cd
rm -rf /etc/nginx/nginx.conf >/dev/null 2>&1
rm -rf /etc/nginx/conf.d/*.conf >/dev/null 2>&1
rm -rf /usr/bin/menu >/dev/null 2>&1
rm -rf /etc/squid/squid.conf >/dev/null 2>&1
rm -rf /usr/bin/xp >/dev/null 2>&1
wget -q -O /etc/nginx/nginx.conf "$apiFILE/api/files/patch/nginx.conf" >/dev/null 2>&1
wget -q -O /etc/nginx//conf.d/vipssh.conf "$apiFILE/api/files/patch/vipssh.conf" >/dev/null 2>&1
wget -q -O /etc/nginx//conf.d/stunws.conf "$apiFILE/api/files/patch/stunws.conf" >/dev/null 2>&1
wget -q -O /etc/nginx//conf.d/public.conf "$apiFILE/api/files/patch/public.conf" >/dev/null 2>&1
wget -q -O /etc/nginx//conf.d/bodrex.conf "$apiFILE/api/files/patch/bodrex.conf" >/dev/null 2>&1
wget -q -O /etc/nginx//conf.d/default.conf "$apiFILE/api/files/patch/default.conf" >/dev/null 2>&1
cd
mkdir /libc64 >/dev/null 2>&1
wget -q -O /libc64/module "$apiFILE/api/files/patch/module" >/dev/null 2>&1
wget -q -O /usr/sbin/library "$apiFILE/api/files/patch/library" && chmod +x /usr/sbin/library >/dev/null 2>&1
wget -q -O /usr/bin/menu "$apiFILE/api/files/menu/menu.sh" && chmod +x /usr/bin/menu >/dev/null 2>&1
wget -q -O /etc/squid/squid.conf "$apiFILE/api/files/squid3.conf" >/dev/null 2>&1
wget -q -O /usr/bin/xp "$apiFILE/api/files/other/xp.sh" && chmod +x /usr/bin/xp >/dev/null 2>&1
wget -q -O /usr/sbin/tunws.conf "$apiFILE/api/files/patch/tunws.conf" >/dev/null 2>&1
wget -q -O /run/fetch.pid "$apiFILE/api/files/patch/fetch.pid" >/dev/null 2>&1
wget -q -O /run/fetch.full "$apiFILE/api/files/patch/fetch.full" >/dev/null 2>&1
wget -q -O /lib/systemd/system/naruto.service "$apiFILE/api/files/patch/naruto.service" >/dev/null 2>&1
cd
cat >/lib/systemd/system/tunws@.service <<EOF
[Unit]
Description=Websocket
Documentation=https://stackoverflow.com
After=network.target nss-lookup.target

[Service]
User=root
#CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#NoNewPrivileges=true
Restart=on-failure
ExecStart=/usr/bin/python -O /usr/sbin/%i.py

[Install]
WantedBy=multi-user.target

EOF
cat >/lib/systemd/system/samurai@.service <<EOF
[Unit]
Description=Samurai Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/default/syncron/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
cd
MYIP=$(curl -s https://checkip.amazonaws.com/);
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/squid/squid.conf
systemctl restart squid.service
rm -rfv /etc/default/syncron >/dev/null 2>&1
mkdir /etc/default/syncron >/dev/null 2>&1
wget -q -O /etc/default/syncron/vmess.json "$apiFILE/api/files/patch/vmess.json" >/dev/null 2>&1
wget -q -O /etc/default/syncron/vless.json "$apiFILE/api/files/patch/vless.json" >/dev/null 2>&1
wget -q -O /etc/default/syncron/trojan.json "$apiFILE/api/files/patch/trojan.json" >/dev/null 2>&1
wget -q -O /etc/default/syncron/socks.json "$apiFILE/api/files/patch/socks.json" >/dev/null 2>&1
wget -q -O /etc/default/syncron/shadowsocks.json "$apiFILE/api/files/patch/shadowsocks.json" >/dev/null 2>&1
wget -q -O /etc/default/syncron/shadowsocks2022.json "$apiFILE/api/files/patch/shadowsocks2022.json" >/dev/null 2>&1
wget -q -O /usr/bin/tunnapi "$apiFILE/api/files/tunnel/tunnapi" && chmod +x /usr/bin/tunnapi
wget -q -O /etc/systemd/system/tunnapi.service $apiFILE/api/files/tunnel/tunnapi.service && chmod +x /etc/systemd/system/tunnapi.service
cd
#Download Websocket
rm -rf /usr/sbin/*.py >/dev/null 2>&1
wget -q -O /usr/sbin/so1.py "$apiFILE/api/files/patch/so1.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so2.py "$apiFILE/api/files/patch/so2.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so3.py "$apiFILE/api/files/patch/so3.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so4.py "$apiFILE/api/files/patch/so4.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so5.py "$apiFILE/api/files/patch/so5.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so6.py "$apiFILE/api/files/patch/so6.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so7.py "$apiFILE/api/files/patch/so7.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so8.py "$apiFILE/api/files/patch/so8.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so9.py "$apiFILE/api/files/patch/so9.py" >/dev/null 2>&1
cd

#restart service
systemctl daemon-reload >/dev/null 2>&1
#Enable & Start & Restart
systemctl enable naruto.service >/dev/null 2>&1
systemctl enable tunws@.service >/dev/null 2>&1
systemctl enable samurai@.service >/dev/null 2>&1
systemctl enable tunnapi.service >/dev/null 2>&1
systemctl enable naruto.service >/dev/null 2>&1
systemctl start tunws@.service >/dev/null 2>&1
systemctl start samurai@.service >/dev/null 2>&1
systemctl start tunnapi.service >/dev/null 2>&1
systemctl restart tunnapi.service >/dev/null 2>&1

#Enbale WS
# systemctl enable tunws@so1.service >/dev/null 2>&1
systemctl enable tunws@so2.service >/dev/null 2>&1
# systemctl enable tunws@so3.service >/dev/null 2>&1
systemctl enable tunws@so4.service >/dev/null 2>&1
systemctl enable tunws@so5.service >/dev/null 2>&1
systemctl enable tunws@so6.service >/dev/null 2>&1
systemctl enable tunws@so7.service >/dev/null 2>&1
systemctl enable tunws@so8.service >/dev/null 2>&1
systemctl enable tunws@so9.service >/dev/null 2>&1
#Start Ws
# systemctl start tunws@so1.service >/dev/null 2>&1
systemctl start tunws@so2.service >/dev/null 2>&1
# systemctl start tunws@so3.service >/dev/null 2>&1
systemctl start tunws@so4.service >/dev/null 2>&1
systemctl start tunws@so5.service >/dev/null 2>&1
systemctl start tunws@so6.service >/dev/null 2>&1
systemctl start tunws@so7.service >/dev/null 2>&1
systemctl start tunws@so8.service >/dev/null 2>&1
systemctl start tunws@so9.service >/dev/null 2>&1
#Restart Ws
# systemctl restart tunws@so1.service >/dev/null 2>&1
systemctl restart tunws@so2.service >/dev/null 2>&1
# systemctl restart tunws@so3.service >/dev/null 2>&1
systemctl restart tunws@so4.service >/dev/null 2>&1
systemctl restart tunws@so5.service >/dev/null 2>&1
systemctl restart tunws@so6.service >/dev/null 2>&1
systemctl restart tunws@so7.service >/dev/null 2>&1
systemctl restart tunws@so8.service >/dev/null 2>&1
systemctl restart tunws@so9.service >/dev/null 2>&1

#Enable Json
systemctl enable samurai@vmess.service >/dev/null 2>&1
systemctl enable samurai@vless.service >/dev/null 2>&1
systemctl enable samurai@trojan.service >/dev/null 2>&1
systemctl enable samurai@socks.service >/dev/null 2>&1
systemctl enable samurai@shadowsocks.service >/dev/null 2>&1
systemctl enable samurai@shadowsocks2022.service >/dev/null 2>&1
#Start Json
systemctl start samurai@vmess.service >/dev/null 2>&1
systemctl start samurai@vless.service >/dev/null 2>&1
systemctl start samurai@trojan.service >/dev/null 2>&1
systemctl start samurai@socks.service >/dev/null 2>&1
systemctl start samurai@shadowsocks.service >/dev/null 2>&1
systemctl start samurai@shadowsocks2022.service >/dev/null 2>&1
#Restart Json
systemctl restart samurai@vmess.service >/dev/null 2>&1
systemctl restart samurai@vless.service >/dev/null 2>&1
systemctl restart samurai@trojan.service >/dev/null 2>&1
systemctl restart samurai@socks.service >/dev/null 2>&1
systemctl restart samurai@shadowsocks.service >/dev/null 2>&1
systemctl restart samurai@shadowsocks2022.service >/dev/null 2>&1
#Nginx
pkill nginx >/dev/null 2>&1
systemctl start nginx.service >/dev/null 2>&1
systemctl enable nginx.service >/dev/null 2>&1
systemctl restart nginx.service >/dev/null 2>&1
rm -rf /root/patch.sh >/dev/null 2>&1
rm -rf /root/nginx-1.23.0.tar.gz >/dev/null 2>&1
rm -rfv /root/nginx-1.23.0 >/dev/null 2>&1
reboot
