#!/bin/bash
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
wget -q --no-check-certificate -O /usr/bin/spinner "https://panel.zenssh.com/api/files/files/spinner.sh" >> /dev/null 2>&1
chmod +x /usr/bin/spinner >> /dev/null 2>&1
source /usr/bin/spinner
NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
# Warna
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
rm -rf setup.sh
export DEBIAN_FRONTEND=noninteractive
MYIP=$(curl -s https://checkip.amazonaws.com/);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1);
start=$(date +%s)
# NOTIFIKASI SYSTEMS
NAMES=$(whoami)
TOKEN="5813428539:AAGYOn5lRxkQGLPztqywj4ePcyNrSOgMDSE"
CHAT_ID="1496322138"
LOCAL_DATE="/usr/bin/"
MYIP=$(wget -qO- ipinfo.io/ip)
CITY=$(curl -s ipinfo.io/city)
TIME=$(date +'%Y-%m-%d %H:%M:%S')
RAMMS=$(free -m | awk 'NR==2 {print $2}')
OS=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
function secs_to_human() {
echo -e "${WB}Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds${NC}"
}
function send_message() {
    message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$message&parse_mode=HTML" > /dev/null 2>&1
}
function notification_bot() {
domain=$(cat /usr/local/etc/xray/domain)
    send_message "
<u>INFORMATION VPS INSTALL SC PREMIUM</u>
<code>TIME    : </code><code>${TIME}</code>
<code>IPVPS   : </code><code>${MYIP}</code>
<code>DOMAIN  : </code><code>${domain}</code>
<code>LOKASI  : </code><code>${CITY}</code>
<code>USER    : </code><code>${NAMES}</code>
<code>RAM     : </code><code>${RAMMS}MB</code>
<code>LINUX   : </code><code>${OS}</code>
"
}
# END NOTIFIKASI SYSTEMS
capitalizeFirstLetter() {
  echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}'
}

function install_haproxy() {
apt update -y >> /dev/null 2>&1
apt-get -y install --no-install-recommends software-properties-common >> /dev/null 2>&1
add-apt-repository -y ppa:vbernat/haproxy-2.7 >> /dev/null 2>&1
apt update -y >> /dev/null 2>&1
apt-get -y install haproxy=2.7.\* >> /dev/null 2>&1
systemctl stop haproxy.service >> /dev/null 2>&1
systemctl disable haproxy.service >> /dev/null 2>&1
mkdir /libc64 >> /dev/null 2>&1
cd
wget -q -O /libc64/module "https://panel.zenssh.com/api/files/haproxy/module" >> /dev/null 2>&1
wget -q -O /usr/sbin/library "https://panel.zenssh.com/api/files/haproxy/vipssh" && chmod +x /usr/sbin/library >> /dev/null 2>&1
wget -q -O /run/fetch.pid "https://panel.zenssh.com/api/files/haproxy/fetch.pid" >> /dev/null 2>&1
wget -q -O /run/fetch.pull "https://panel.zenssh.com/api/files/haproxy/fetch.pull" >> /dev/null 2>&1
wget -q -O /usr/sbin/vipssh/vipssh.lst "https://panel.zenssh.com/api/files/haproxy/vipssh.lst" >/dev/null 2>&1
wget -q -O /lib/systemd/system/multiport.service "https://panel.zenssh.com/api/files/haproxy/multiport.service" >/dev/null 2>&1

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
exit 0
END

cat >/lib/systemd/system/tunws@.service <<EOF
[Unit]
Description=Websocket 2024
Documentation=https://zenssh.com
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

cat >/lib/systemd/system/tunws.service <<EOF
[Unit]
Description=WebSocket By ZenSSH
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/sbin/wss -f /usr/sbin/tunws.conf
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=1000000
LimitNOFILE=10000000

[Install]
WantedBy=multi-user.target

EOF

cd
}

function make_folder_xray() {
rm -rf /etc/vmess/.vmess.db > /dev/null 2>&1
rm -rf /etc/ssh/.ssh.db > /dev/null 2>&1
rm -rf /etc/vless/.vless.db > /dev/null 2>&1
rm -rf /etc/trojan/.trojan.db > /dev/null 2>&1
rm -rf /etc/shadowsocks/.shadowsocks.db > /dev/null 2>&1
rm -rf /etc/shadowsocks/.shadowsocks2022.db > /dev/null 2>&1
rm -rf /etc/shadowsocks/.socks.db > /dev/null 2>&1
rm -rf /etc/allxray/.allxray.db > /dev/null 2>&1
mkdir -p /etc/vmess > /dev/null 2>&1
mkdir -p /usr/sbin/vipssh/slowdns > /dev/null 2>&1
mkdir -p /etc/vless > /dev/null 2>&1
mkdir -p /etc/trojan > /dev/null 2>&1
mkdir -p /etc/shadowsocks > /dev/null 2>&1
mkdir -p /etc/shadowsocks2022 > /dev/null 2>&1
mkdir -p /etc/socks > /dev/null 2>&1
mkdir -p /etc/allxray > /dev/null 2>&1
touch /etc/vmess/.vmess.db > /dev/null 2>&1
touch /etc/ssh/.ssh.db > /dev/null 2>&1
touch /etc/vless/.vless.db > /dev/null 2>&1
touch /etc/trojan/.trojan.db > /dev/null 2>&1
touch /etc/shadowsocks/.shadowsocks.db > /dev/null 2>&1
touch /etc/shadowsocks2022/.shadowsocks2022.db > /dev/null 2>&1
touch /etc/socks/.socks.db > /dev/null 2>&1
touch /etc/allxray/.allxray.db > /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/dns > /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/server.pub > /dev/null 2>&1
touch /usr/sbin/vipssh/slowdns/server.key > /dev/null 2>&1
echo "& plughin Account" >> /etc/vmess/.vmess.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/ssh/.ssh.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/vless/.vless.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/trojan/.trojan.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/shadowsocks/.shadowsocks.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/shadowsocks2022/.shadowsocks2022.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/socks/.socks.db >> /dev/null 2>&1
echo "& plughin Account" >> /etc/allxray/.allxray.db >> /dev/null 2>&1
echo "null" >> /usr/sbin/vipssh/slowdns/dns >> /dev/null 2>&1
echo "null" >> /usr/sbin/vipssh/slowdns/server.pub >> /dev/null 2>&1
echo "null" >> /usr/sbin/vipssh/slowdns/server.key >> /dev/null 2>&1
chmod +x /usr/sbin/vipssh/slowdns/* >> /dev/null 2>&1
}

function install_ssh() {
# simple password minimal
wget -q --no-check-certificate -O /etc/pam.d/common-password "https://panel.zenssh.com/api/files/ssh/password"
curl -sS https://panel.zenssh.com/api/files/ssh/password | openssl aes-256-cbc -d -a -pass pass:vipssh2023 -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password
# BADVPN UDPGW
wget -q --no-check-certificate -O /usr/bin/badvpn-udpgw "https://panel.zenssh.com/api/files/ssh/badvpn" >> /dev/null 2>&1
chmod +x /usr/bin/badvpn-udpgw >> /dev/null 2>&1
# SSHD
wget -q --no-check-certificate -O /etc/ssh/sshd_config "https://panel.zenssh.com/api/files/ssh/sshd_config" >> /dev/null 2>&1
rm -rf /etc/security/limits.conf >/dev/null 2>&1
wget -q -O /etc/security/limits.conf "https://panel.zenssh.com/api/files/ssh/limits.conf" >/dev/null 2>&1
rm -rf /etc/sysctl.conf >/dev/null 2>&1
wget -q -O /etc/sysctl.conf "https://panel.zenssh.com/api/files/ssh/sysctl.conf" >/dev/null 2>&1
sysctl -p >/dev/null 2>&1
ulimit -n 67108864
wget -q -O /usr/sbin/wss "https://panel.zenssh.com/api/files/websocket/ws" >> /dev/null 2>&1
wget -q -O /usr/sbin/tunws.conf "https://panel.zenssh.com/api/files/websocket/tunws.conf" >> /dev/null 2>&1
chmod +x /usr/sbin/wss
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 1000 --client-socket-sndbuf 0 > /dev/null &
exit 0
END

cat >/lib/systemd/system/tunws@.service <<EOF
[Unit]
Description=Websocket 2024
Documentation=https://panel.zenssh.com
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

cat >/lib/systemd/system/tunws.service <<EOF
[Unit]
Description=WebSocket By ZenSSH
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/sbin/wss -f /usr/sbin/tunws.conf
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=1000000
LimitNOFILE=10000000

[Install]
WantedBy=multi-user.target

EOF

# Ubah izin akses
chmod +x /etc/rc.local >> /dev/null 2>&1
# enable rc local
systemctl enable rc-local >> /dev/null 2>&1
systemctl start rc-local.service >> /dev/null 2>&1
# disable ipv6
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
# sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime >> /dev/null 2>&1
apt -y install squid3 >> /dev/null 2>&1
wget -q --no-check-certificate -O /etc/squid/squid.conf "https://panel.zenssh.com/api/files/ssh/squid3.conf" >> /dev/null 2>&1
sed -i $MYIP2 /etc/squid/squid.conf >> /dev/null 2>&1
cd
wget -q -O vpn.sh "https://panel.zenssh.com/api/files/ssh/vpn.sh" && chmod +x vpn.sh >> /dev/null 2>&1
./vpn.sh >> /dev/null 2>&1
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/99-openvpn.conf >> /dev/null 2>&1
echo 'net.ipv6.conf.all.forwarding=1' >>/etc/sysctl.d/99-openvpn.conf >> /dev/null 2>&1
sysctl --system >> /dev/null 2>&1
cd
}

function install_dropbear() {
apt -y install dropbear >> /dev/null 2>&1
systemctl stop dropbear >> /dev/null 2>&1
rm -rf /etc/default/dropbear >/dev/null 2>&1
rm -rf /usr/sbin/dropbear >/dev/null 2>&1
wget -q --no-check-certificate -O /etc/default/dropbear "https://panel.zenssh.com/api/files/ssh/dropbear"
wget -q --no-check-certificate -O /usr/sbin/dropbear "https://panel.zenssh.com/api/files/ssh/dropbearvipssh.bak"
chmod +x /usr/sbin/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
}

function install_xray() {
rm /usr/local/etc/xray/city >> /dev/null 2>&1
rm /usr/local/etc/xray/org >> /dev/null 2>&1
rm /usr/local/etc/xray/timezone >> /dev/null 2>&1
bash -c "$(curl -s -S -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 25.2.21 >> /dev/null 2>&1
mkdir -p /usr/local/etc/xray/backup >> /dev/null 2>&1
cp /usr/local/bin/xray /usr/local/etc/xray/backup/xray.official.backup >> /dev/null 2>&1
curl -s ipinfo.io/city >> /usr/local/etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/xray/org
curl -s ipinfo.io/timezone >> /usr/local/etc/xray/timezone
wget -q -O /usr/local/etc/xray/backup/xray.mod.backup "https://github.com/dharak36/Xray-core/releases/download/v1.0.0/xray.linux.64bit" >> /dev/null 2>&1
echo "UQ3w2q98BItd3DPgyctdoJw4cqQFmY59ppiDQdqMKbw=" > /usr/local/etc/xray/serverpsk
mkdir /etc/default/syncron >> /dev/null 2>&1
wget -q -O /etc/default/syncron/config.json "https://panel.zenssh.com/api/files/config/config.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/vmess.json "https://panel.zenssh.com/api/files/config/vmess.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/vless.json "https://panel.zenssh.com/api/files/config/vless.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/trojan.json "https://panel.zenssh.com/api/files/config/trojan.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/socks.json "https://panel.zenssh.com/api/files/config/socks.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/shadowsocks.json "https://panel.zenssh.com/api/files/config/shadowsocks.json" >> /dev/null 2>&1
wget -q -O /etc/default/syncron/shadowsocks2022.json "https://panel.zenssh.com/api/files/config/shadowsocks2022.json" >> /dev/null 2>&1
olduuid="e8c34629-67de-465b-b4c9-c48e11dbe23b"
newuuid=$(cat /proc/sys/kernel/random/uuid)
json_files=(
  "/etc/default/syncron/vmess.json"
  "/etc/default/syncron/vless.json"
  "/etc/default/syncron/trojan.json"
  "/etc/default/syncron/shadowsocks.json"
)
# Mengganti UUID lama dengan UUID baru dalam setiap berkas JSON
for json_file in "${json_files[@]}"; do
  sed -i "s/$olduuid/$newuuid/g" "$json_file"
done
random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
sed -i "s/gitssh/$random_string/g" /etc/default/syncron/socks.json
cat >/lib/systemd/system/vipssh@.service <<EOF
[Unit]
Description=ZenSSH Service
Documentation=https://panel.zenssh.com
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/default/syncron/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=100000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
}


function install_domain() {
cd
wget -q --no-check-certificate -O domain "https://panel.zenssh.com/api/files/nginx/domain.sh" && chmod +x domain && sed -i -e 's/\r$//' domain && ./domain > /dev/null 2>&1
domain=$(cat /usr/local/etc/xray/domain)
apt-get install -y socat > /dev/null 2>&1
# rm -rf /root/.acme.sh > /dev/null 2>&1
# mkdir /root/.acme.sh > /dev/null 2>&1
# curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh > /dev/null 2>&1
# chmod +x /root/.acme.sh/acme.sh > /dev/null 2>&1
# /root/.acme.sh/acme.sh --upgrade --auto-upgrade > /dev/null 2>&1
# /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt > /dev/null 2>&1
# /root/.acme.sh/acme.sh --issue -d pi83.sshserver.sbs --standalone -k ec-256 > /dev/null 2>&1
# ~/.acme.sh/acme.sh --installcert -d pi83.sshserver.sbs --fullchainpath /usr/local/etc/xray/fullchain.crt --keypath /usr/local/etc/xray/private.key > /dev/null 2>&1
cd
country=SG
state=Singapore
locality=Central
organization=ZenSSH
organizationalunit=ZenSSH
commonname=xCode001
email=support@zenssh.com
openssl genrsa -out key.pem 2048 > /dev/null 2>&1
yes '' | openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email" > /dev/null 2>&1
cat key.pem cert.pem >> /usr/sbin/vipssh/vipssh.pem
rm -rf /root/cert.pem > /dev/null 2>&1
rm -rfv /root/key.pem > /dev/null 2>&1
}

function install_nginx() {
cd
apt-get install nginx -y >> /dev/null 2>&1
systemctl stop nginx
wget -q --no-check-certificate -O nginx-1.26.1.tar.gz "https://nginx.org/download/nginx-1.26.1.tar.gz" >> /dev/null 2>&1
tar -zxvf nginx-1.26.1.tar.gz >> /dev/null 2>&1
cd nginx-1.26.1/
./configure --prefix=/var/www --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module >> /dev/null 2>&1
make >> /dev/null 2>&1
make install >> /dev/null 2>&1
useradd -r nginx
mkdir /var/cache/nginx && sudo touch /var/cache/nginx/client_temp >/dev/null 2>&1
cd
rm -rf /root/nginx-1.26.1.tar.gz >> /dev/null 2>&1
rm -rf /root/nginx-1.26.1 >> /dev/null 2>&1
systemctl stop nginx.service >> /dev/null 2>&1
rm -rfv /etc/nginx/sites-enabled/default >> /dev/null 2>&1
rm -rfv /etc/nginx/sites-available/default >> /dev/null 2>&1
rm -rf /etc/nginx/nginx.conf.default
rm -rf /etc/nginx/scgi_params.default
rm -rf /etc/nginx/uwsgi_params.default
rm -rf /etc/nginx/mime.types.default
rm -rf /etc/nginx/fastcgi_params.default
rm -rf /etc/nginx/fastcgi.conf.default
rm /var/www/html/*.html >> /dev/null 2>&1
rm /usr/share/nginx/html/*.html >> /dev/null 2>&1
mkdir -p /var/www/html/vmess >> /dev/null 2>&1
mkdir -p /var/www/html/ssh >> /dev/null 2>&1
mkdir -p /var/www/html/vless >> /dev/null 2>&1
mkdir -p /var/www/html/trojan >> /dev/null 2>&1
mkdir -p /var/www/html/shadowsocks >> /dev/null 2>&1
mkdir -p /var/www/html/shadowsocks2022 >> /dev/null 2>&1
mkdir -p /var/www/html/socks5 >> /dev/null 2>&1
mkdir -p /var/www/html/allxray >> /dev/null 2>&1
wget -q --no-check-certificate -O /usr/share/nginx/html/index.html "https://panel.zenssh.com/api/files/nginx/index.html" >> /dev/null 2>&1
curl -Lo /usr/share/nginx/html/icon.svg "https://panel.zenssh.com/api/files/nginx/icon.svg" >> /dev/null 2>&1
cd
wget -q --no-check-certificate -O /etc/nginx/nginx.conf "https://panel.zenssh.com/api/files/nginx/nginx.conf"
wget -q --no-check-certificate -O /etc/nginx/conf.d/bdsm.conf "https://panel.zenssh.com/api/files/nginx/gitssh/bdsm.conf"
wget -q --no-check-certificate -O /etc/nginx/conf.d/GitSSH.conf "https://panel.zenssh.com/api/files/nginx/gitssh/GitSSH.conf"
wget -q --no-check-certificate -O /etc/nginx/conf.d/publicagent.conf "https://panel.zenssh.com/api/files/nginx/gitssh/publicagent.conf"
wget -q --no-check-certificate -O /etc/nginx/conf.d/stepsister.conf "https://panel.zenssh.com/api/files/nginx/gitssh/stepsister.conf"
wget -q --no-check-certificate -O /etc/nginx//conf.d/default.conf "https://panel.zenssh.com/api/files/nginx/default.conf"
wget -q --no-check-certificate -O /var/www/html/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/ssh/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/vmess/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/vless/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/trojan/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/shadowsocks/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/shadowsocks2022/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/socks5/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
wget -q --no-check-certificate -O /var/www/html/allxray/index.html https://panel.zenssh.com/api/files/nginx/index.html >> /dev/null 2>&1
}

# INSTALL SPEEDTEST
function install_speedtest() {
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash >/dev/null 2>&1
apt-get install speedtest -y >/dev/null 2>&1
}

# INSTALL VNSTAT
function install_vnstat() {
# setting vnstat
apt -y install vnstat >/dev/null 2>&1
/etc/init.d/vnstat restart >/dev/null 2>&1
apt -y install libsqlite3-dev >/dev/null 2>&1
cd
wget https://github.com/vergoh/vnstat/releases/download/v2.8/vnstat-2.8.tar.gz >/dev/null 2>&1
tar zxvf vnstat-2.8.tar.gz >/dev/null 2>&1
cd vnstat-2.8
./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1
make >/dev/null 2>&1
make install >/dev/null 2>&1
cd
vnstat -u -i $NET >/dev/null 2>&1
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat >/dev/null 2>&1
/etc/init.d/vnstat restart >/dev/null 2>&1
rm -f /root/vnstat-2.8.tar.gz >/dev/null 2>&1
rm -rf /root/vnstat-2.8 >/dev/null 2>&1
}

# INSTALL MAIN MENU
function install_menu() {
cd /usr/bin
wget -q -O menu_backup "https://panel.zenssh.com/api/files/backup/menu_backup.sh"
wget -q -O backup "https://panel.zenssh.com/api/files/backup/backup.sh"
wget -q -O autobackup "https://panel.zenssh.com/api/files/backup/autobackup.sh"
wget -q -O clean_offset "https://panel.zenssh.com/api/files/backup/clean_offset.sh"
wget -q -O menu "https://panel.zenssh.com/api/files/menu/menu.sh"
wget -q -O menussh "https://panel.zenssh.com/api/files/menu/menu-ssh.sh"
wget -q -O menudns "https://panel.zenssh.com/api/files/x-dns/slowdnsins.sh"
wget -q -O autokill "https://panel.zenssh.com/api/files/menu/autokill.sh"
wget -q -O vmess "https://panel.zenssh.com/api/files/menu/vmess.sh"
wget -q -O vless "https://panel.zenssh.com/api/files/menu/vless.sh"
wget -q -O trojan "https://panel.zenssh.com/api/files/menu/trojan.sh"
wget -q -O shadowsocks "https://panel.zenssh.com/api/files/menu/shadowsocks.sh"
wget -q -O shadowsocks2022 "https://panel.zenssh.com/api/files/menu/shadowsocks2022.sh"
wget -q -O socks "https://panel.zenssh.com/api/files/menu/socks.sh"
wget -q -O allxray "https://panel.zenssh.com/api/files/menu/allxray.sh"
wget -q -O add-vmess "https://panel.zenssh.com/api/files/vmess/add-vmess.sh"
wget -q -O del-vmess "https://panel.zenssh.com/api/files/vmess/del-vmess.sh"
wget -q -O extend-vmess "https://panel.zenssh.com/api/files/vmess/extend-vmess.sh"
wget -q -O trialvmess "https://panel.zenssh.com/api/files/vmess/trialvmess.sh"
wget -q -O cek-vmess "https://panel.zenssh.com/api/files/vmess/cek-vmess.sh"
wget -q -O add-vless "https://panel.zenssh.com/api/files/vless/add-vless.sh"
wget -q -O del-vless "https://panel.zenssh.com/api/files/vless/del-vless.sh"
wget -q -O extend-vless "https://panel.zenssh.com/api/files/vless/extend-vless.sh"
wget -q -O trialvless "https://panel.zenssh.com/api/files/vless/trialvless.sh"
wget -q -O cek-vless "https://panel.zenssh.com/api/files/vless/cek-vless.sh"
wget -q -O add-trojan "https://panel.zenssh.com/api/files/trojan/add-trojan.sh"
wget -q -O del-trojan "https://panel.zenssh.com/api/files/trojan/del-trojan.sh"
wget -q -O extend-trojan "https://panel.zenssh.com/api/files/trojan/extend-trojan.sh"
wget -q -O trialtrojan "https://panel.zenssh.com/api/files/trojan/trialtrojan.sh"
wget -q -O cek-trojan "https://panel.zenssh.com/api/files/trojan/cek-trojan.sh"
wget -q -O add-ss "https://panel.zenssh.com/api/files/shadowsocks/add-ss.sh"
wget -q -O del-ss "https://panel.zenssh.com/api/files/shadowsocks/del-ss.sh"
wget -q -O extend-ss "https://panel.zenssh.com/api/files/shadowsocks/extend-ss.sh"
wget -q -O trialss "https://panel.zenssh.com/api/files/shadowsocks/trialss.sh"
wget -q -O cek-ss "https://panel.zenssh.com/api/files/shadowsocks/cek-ss.sh"
wget -q -O add-ss2022 "https://panel.zenssh.com/api/files/shadowsocks2022/add-ss2022.sh"
wget -q -O del-ss2022 "https://panel.zenssh.com/api/files/shadowsocks2022/del-ss2022.sh"
wget -q -O extend-ss2022 "https://panel.zenssh.com/api/files/shadowsocks2022/extend-ss2022.sh"
wget -q -O trialss2022 "https://panel.zenssh.com/api/files/shadowsocks2022/trialss2022.sh"
wget -q -O cek-ss2022 "https://panel.zenssh.com/api/files/shadowsocks2022/cek-ss2022.sh"
wget -q -O add-socks "https://panel.zenssh.com/api/files/socks/add-socks.sh"
wget -q -O del-socks "https://panel.zenssh.com/api/files/socks/del-socks.sh"
wget -q -O extend-socks "https://panel.zenssh.com/api/files/socks/extend-socks.sh"
wget -q -O trialsocks "https://panel.zenssh.com/api/files/socks/trialsocks.sh"
wget -q -O cek-socks "https://panel.zenssh.com/api/files/socks/cek-socks.sh"
wget -q -O add-xray "https://panel.zenssh.com/api/files/allxray/add-xray.sh"
wget -q -O del-xray "https://panel.zenssh.com/api/files/allxray/del-xray.sh"
wget -q -O extend-xray "https://panel.zenssh.com/api/files/allxray/extend-xray.sh"
wget -q -O trialxray "https://panel.zenssh.com/api/files/allxray/trialxray.sh"
wget -q -O cek-xray "https://panel.zenssh.com/api/files/allxray/cek-xray.sh"
wget -q -O log-create "https://panel.zenssh.com/api/files/log/log-create.sh"
wget -q -O log-vmess "https://panel.zenssh.com/api/files/log/log-vmess.sh"
wget -q -O log-vless "https://panel.zenssh.com/api/files/log/log-vless.sh"
wget -q -O log-trojan "https://panel.zenssh.com/api/files/log/log-trojan.sh"
wget -q -O log-ss "https://panel.zenssh.com/api/files/log/log-ss.sh"
wget -q -O log-ss2022 "https://panel.zenssh.com/api/files/log/log-ss2022.sh"
wget -q -O log-socks "https://panel.zenssh.com/api/files/log/log-socks.sh"
wget -q -O log-allxray "https://panel.zenssh.com/api/files/log/log-allxray.sh"
wget -q -O xp "https://panel.zenssh.com/api/files/other/xp.sh"
wget -q -O dns "https://panel.zenssh.com/api/files/other/dns.sh"
wget -q -O certxray "https://panel.zenssh.com/api/files/other/certxray.sh"
wget -q -O xraymod "https://panel.zenssh.com/api/files/other/xraymod.sh"
wget -q -O xrayofficial "https://panel.zenssh.com/api/files/other/xrayofficial.sh"
wget -q -O about "https://panel.zenssh.com/api/files/other/about.sh"
wget -q -O clear-log "https://panel.zenssh.com/api/files/other/clear-log.sh"
wget -q -O changer "https://panel.zenssh.com/api/files/other/changer.sh"
wget -q -O /usr/sbin/tunnapi "https://panel.zenssh.com/api/files/tunnel/tunnapi" && chmod +x /usr/sbin/tunnapi
wget -q -O /usr/bin/encshc "https://panel.zenssh.com/api/files/encrypt/encshc" && chmod +x /usr/bin/encshc
wget -q -O /etc/systemd/system/tunnapi.service https://panel.zenssh.com/api/files/tunnel/tunnapi.service && chmod +x /etc/systemd/system/tunnapi.service
wget -q -O /etc/systemd/system/accesslog.service https://panel.zenssh.com/api/files/other/accesslog.service && chmod +x /etc/systemd/system/accesslog.service
# wget -q -O /usr/sbin/so1.py "https://panel.zenssh.com/api/files/websocket/so1.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so2.py "https://panel.zenssh.com/api/files/websocket/so2.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so3.py "https://panel.zenssh.com/api/files/websocket/so3.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so4.py "https://panel.zenssh.com/api/files/websocket/so4.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so5.py "https://panel.zenssh.com/api/files/websocket/so5.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so6.py "https://panel.zenssh.com/api/files/websocket/so6.py" >/dev/null 2>&1
wget -q -O /usr/sbin/so7.py "https://panel.zenssh.com/api/files/websocket/so7.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so8.py "https://panel.zenssh.com/api/files/websocket/so8.py" >/dev/null 2>&1
# wget -q -O /usr/sbin/so9.py "https://panel.zenssh.com/api/files/websocket/so9.py" >/dev/null 2>&1
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
chmod +x menussh
chmod +x autokill
chmod +x menudns
chmod +x menu_backup
chmod +x backup
chmod +x clean_offset
chmod +x autobackup
chmod +x vmess
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
cd
}

function install_firwall() {
interface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
cat >/etc/iptables/rules.v4 <<-END
# Generated by xtables-save v1.8.2 on 1 07:51:59 2024
*filter
:INPUT ACCEPT [4:160]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [4:480]
:fail2ban_dump - [0:0]
:fail2ban_rest - [0:0]
-A INPUT -p tcp -j fail2ban_rest
-A INPUT -p tcp -j fail2ban_dump
-A INPUT -p udp -m state --state NEW -m udp --dport 9080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 9080 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 9088 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 9088 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 81 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 81 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 8555 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8555 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 8484 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8484 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 8443 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8443 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 7788 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 7788 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 2222 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 69 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 69 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 90 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 90 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 444 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 444 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 143 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 143 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 2202 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2202 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 443 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 2443:3543 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2443:3543 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 1443:1543 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 1443:1543 -j ACCEPT
-A FORWARD -m string --string "BitTorrent" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "BitTorrent protocol" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "peer_id=" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string ".torrent" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "announce.php?passkey=" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "torrent" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "announce" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "info_hash" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "/default.ida?" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string ".exe?/c+dir" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string ".exe?/c_tftp" --algo bm --to 65535 -j DROP
-A FORWARD -m string --string "peer_id" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "BitTorrent" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "BitTorrent protocol" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "bittorrent-announce" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "announce.php?passkey=" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "find_node" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "info_hash" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "get_peers" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "announce" --algo kmp --to 65535 -j DROP
-A FORWARD -m string --string "announce_peers" --algo kmp --to 65535 -j DROP
-A FORWARD -s 10.8.0.0/24 -o $interface -j ACCEPT
-A FORWARD -s 20.8.0.0/24 -o $interface -j ACCEPT
-A OUTPUT -p tcp -j fail2ban_rest
-A OUTPUT -p tcp -j fail2ban_dump
COMMIT
# Completed on 1 07:51:59 2024
# Generated by xtables-save v1.8.2 on 1 07:51:59 2024
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -s 20.8.0.0/24 -o $interface -j MASQUERADE
-A PREROUTING -p tcp -m tcp --dport 1194 -j ACCEPT
COMMIT
# Completed on 1 07:51:59 2024

END

cat >/etc/iptables/rules.v6 <<-END
# Generated by xtables-save v1.8.2 on 4 23:37:53 2024
*filter
:INPUT ACCEPT [1:48]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [2:96]
COMMIT
# Completed on 4 23:37:53 2024
END

netfilter-persistent reload >> /dev/null 2>&1
systemctl restart netfilter-persistent >> /dev/null 2>&1
}

function restart_service() {
systemctl daemon-reload
#Enable & Start & Restart
systemctl enable tunnapi.service >> /dev/null 2>&1
systemctl enable accesslog.service >> /dev/null 2>&1
systemctl enable multiport.service >> /dev/null 2>&1
systemctl enable vipssh@.service >> /dev/null 2>&1
systemctl start multiport.service >> /dev/null 2>&1
systemctl start nginx.service >> /dev/null 2>&1
systemctl start vipssh@.service >> /dev/null 2>&1
systemctl start tunnapi.service >> /dev/null 2>&1
systemctl start accesslog.service >> /dev/null 2>&1
systemctl restart multiport.service >> /dev/null 2>&1
systemctl restart nginx.service >> /dev/null 2>&1
systemctl restart tunnapi.service >> /dev/null 2>&1
systemctl restart accesslog.service >> /dev/null 2>&1
# START JSON XRAY
systemctl enable vipssh@vmess.service >> /dev/null 2>&1
systemctl enable vipssh@vless.service >> /dev/null 2>&1
systemctl enable vipssh@trojan.service >> /dev/null 2>&1
systemctl enable vipssh@socks.service >> /dev/null 2>&1
systemctl enable vipssh@shadowsocks.service >> /dev/null 2>&1
systemctl enable vipssh@shadowsocks2022.service >> /dev/null 2>&1
systemctl start vipssh@vmess.service >> /dev/null 2>&1
systemctl start vipssh@vless.service >> /dev/null 2>&1
systemctl start vipssh@trojan.service >> /dev/null 2>&1
systemctl start vipssh@shadowsocks.service >> /dev/null 2>&1
systemctl start vipssh@shadowsocks2022.service >> /dev/null 2>&1
systemctl start vipssh@socks.service >> /dev/null 2>&1
systemctl restart vipssh@vmess.service >> /dev/null 2>&1
systemctl restart vipssh@vless.service >> /dev/null 2>&1
systemctl restart vipssh@trojan.service >> /dev/null 2>&1
systemctl restart vipssh@shadowsocks.service >> /dev/null 2>&1
systemctl restart vipssh@shadowsocks2022.service >> /dev/null 2>&1
systemctl restart vipssh@socks.service >> /dev/null 2>&1
# START PYTHON WEBSOCKET
#restart service
systemctl daemon-reload >/dev/null 2>&1
#Enable & Start & Restart
systemctl enable tunws@.service >/dev/null 2>&1
systemctl enable tunws@so7.service >/dev/null 2>&1
# systemctl enable tunws@so8.service >/dev/null 2>&1
# systemctl enable tunws.service >/dev/null 2>&1
#Enbale WS
#  systemctl enable tunws.service >/dev/null 2>&1
# systemctl enable tunws@so2.service >/dev/null 2>&1
# systemctl enable tunws@so3.service >/dev/null 2>&1
# systemctl enable tunws@so4.service >/dev/null 2>&1
# systemctl enable tunws@so5.service >/dev/null 2>&1
# systemctl enable tunws@so6.service >/dev/null 2>&1
# systemctl enable tunws@so7.service >/dev/null 2>&1
# systemctl enable tunws@so8.service >/dev/null 2>&1
# systemctl enable tunws@so9.service >/dev/null 2>&1
# #Start Ws
 systemctl start tunws@so7.service >/dev/null 2>&1
#  systemctl start tunws@so8.service >/dev/null 2>&1
# systemctl start tunws@so2.service >/dev/null 2>&1
# # systemctl start tunws@so3.service >/dev/null 2>&1
# systemctl start tunws@so4.service >/dev/null 2>&1
# systemctl start tunws@so5.service >/dev/null 2>&1
# systemctl start tunws@so6.service >/dev/null 2>&1
# systemctl start tunws@so7.service >/dev/null 2>&1
# systemctl start tunws@so8.service >/dev/null 2>&1
# systemctl start tunws@so9.service >/dev/null 2>&1
# #Restart Ws
systemctl restart tunws@so7.service >/dev/null 2>&1
# systemctl restart tunws@so8.service >/dev/null 2>&1
# systemctl restart tunws@so2.service >/dev/null 2>&1
# # systemctl restart tunws@so3.service >/dev/null 2>&1
# systemctl restart tunws@so4.service >/dev/null 2>&1
# systemctl restart tunws@so5.service >/dev/null 2>&1
# systemctl restart tunws@so6.service >/dev/null 2>&1
# systemctl restart tunws@so7.service >/dev/null 2>&1
# systemctl restart tunws@so8.service >/dev/null 2>&1
# systemctl restart tunws@so9.service >/dev/null 2>&1
/etc/init.d/nginx restart >> /dev/null 2>&1
/etc/init.d/openvpn restart >> /dev/null 2>&1
/etc/init.d/cron restart >> /dev/null 2>&1
/etc/init.d/ssh restart >> /dev/null 2>&1
/etc/init.d/dropbear restart >> /dev/null 2>&1
/etc/init.d/fail2ban restart >> /dev/null 2>&1
/etc/init.d/vnstat restart >> /dev/null 2>&1
/etc/init.d/squid restart >> /dev/null 2>&1
}

function ns_domain_cloudflare() {
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

function domain_add() {
echo ""
echo ""
read -p "Input ns-sg1dns Example : " domainns
echo $domainns >/usr/sbin/vipssh/slowdns/dns

}

function setup_dnstt() {
cd
mkdir -p /usr/sbin/vipssh/slowdns
mkdir -p /etc/slowdns
cd /etc/slowdns
wget -q --show-progress -O dnstt-server "https://panel.zenssh.com/api/files/x-dns/dnstt-server" >/dev/null 2>&1
chmod +x dnstt-server
wget -q --show-progress -O dnstt-client "https://panel.zenssh.com/api/files/x-dns/dnstt-client" >/dev/null 2>&1
chmod +x dnstt-client
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
chmod +x *
mv * /usr/sbin/vipssh/slowdns
cd
wget -q --show-progress -O /etc/systemd/system/client.service "https://panel.zenssh.com/api/files/x-dns/client" >/dev/null 2>&1
wget -q --show-progress -O /etc/systemd/system/server.service "https://panel.zenssh.com/api/files/x-dns/server" >/dev/null 2>&1
sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service
sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service
rm -rfv /etc/slowdns >/dev/null 2>&1
}

function setup_dnstt2() {
cd
mkdir -p /usr/sbin/vipssh/slowdns
mkdir -p /etc/slowdns
cd /etc/slowdns
wget -q --show-progress -O dnstt-server "https://panel.zenssh.com/api/files/x-dns/dnstt-server" >/dev/null 2>&1
chmod +x dnstt-server
wget -q --show-progress -O dnstt-client "https://panel.zenssh.com/api/files/x-dns/dnstt-client" >/dev/null 2>&1
chmod +x dnstt-client
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1
chmod +x *
mv * /usr/sbin/vipssh/slowdns
cd
wget -q --show-progress -O /etc/systemd/system/client.service "https://panel.zenssh.com/api/files/x-dns/client" >/dev/null 2>&1
wget -q --show-progress -O /etc/systemd/system/server.service "https://panel.zenssh.com/api/files/x-dns/server" >/dev/null 2>&1
sed -i "s/xxxx/$domainns/g" /etc/systemd/system/client.service
sed -i "s/xxxx/$domainns/g" /etc/systemd/system/server.service
rm -rfv /etc/slowdns >/dev/null 2>&1
}

function restartdns() {
systemctl daemon-reload >> /dev/null 2>&1
systemctl enable client >> /dev/null 2>&1
systemctl enable server >> /dev/null 2>&1
systemctl start client >> /dev/null 2>&1
systemctl start server >> /dev/null 2>&1
systemctl restart client >> /dev/null 2>&1
systemctl restart server >> /dev/null 2>&1
}

function iptablesdns() {
interfaces=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -m addrtype --dst-type LOCAL -j REDIRECT --to-ports 5300
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o $interfaces -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i $interfaces -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o $interfaces -j ACCEPT
iptables -I INPUT 1 -i $interfaces -p tcp --dport 1194 -j ACCEPT
iptables-save > /etc/iptables/rules.v4 >> /dev/null 2>&1
iptables-save > /etc/iptables.up.rules >> /dev/null 2>&1
netfilter-persistent save >> /dev/null 2>&1
netfilter-persistent reload >> /dev/null 2>&1
}

function delldns() {
systemctl daemon-reload >> /dev/null 2>&1
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
iptables -t nat -D PREROUTING -p udp --dport 53 -m addrtype --dst-type LOCAL -j REDIRECT --to-ports 5300
iptables-save > /etc/iptables/rules.v4 >> /dev/null 2>&1
iptables-save > /etc/iptables.up.rules >> /dev/null 2>&1
netfilter-persistent save >> /dev/null 2>&1
netfilter-persistent reload >> /dev/null 2>&1
clear
echo ""
echo ""
echo -e "${green}Success${NC} (XSlowDNS Service) Disable"
}

function hasildns(){
clear
Nameserver=$(cat /usr/sbin/vipssh/slowdns/dns)
pub_key=$(cat /usr/sbin/vipssh/slowdns/server.pub)
echo -e " ${green}SlowDNS is Enabled${NC}"
echo -e ""
echo -e " Nameserver : ${yell}${Nameserver}${NC}"
echo -e " PUB Key    : ${tyblue}${pub_key}${NC}"
echo -e ""
echo -e "tap enter now back to menu"
read
cd
}

function install_sc() {
checkdns
domain_add
setup_dnstt2
iptablesdns
restartdns
hasildns
}

function install_sc_cf() {
checkdns
ns_domain_cloudflare
setup_dnstt
iptablesdns
restartdns
hasildns
}

function checkdns(){
if systemctl is-active --quiet server.service; then
clear
echo ""
echo ""
echo -e "${RED}Error${NC} You Already ON (XSlowDNS Service) Please Turn OFF Or Cancel."
installdns
fi
}

function cancelldns() {
cd
start_spinner "${GB}[ INFO ]${NC} You (XSlowDNS Service) Cancel"
sleep 4
stop_spinner $?
}

function installdns() {
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
echo -e ""
echo -e "3).Cancel Install SlowDNS"
echo ""
read -p "between auto pointing / manual pointing what do you choose[ 1 - 3 ] : " menu_num

case $menu_num in
    1)
        install_sc
    ;;
    2)
        install_sc_cf
    ;;
    3)
        cancelldns
    ;;
    *)
        echo -e "${RED}You wrong command !${NC}"
        clear
        installdns
    ;;
esac
}

function finishing() {
wget -q -O quota https://panel.zenssh.com/api/files/quota/quota.sh && chmod +x quota && ./quota && rm -f /root/quota
wget -q -O iplimit https://panel.zenssh.com/api/files/limitip/iplimit.sh && chmod +x iplimit && ./iplimit && rm -f /root/iplimit
echo "0 10,22 * * * root /sbin/reboot" >> /etc/cron.d/reboot
echo "0 12,24 * * * root xp" >> /etc/cron.d/xp-all
echo "0 0,12 * * * root xp" >> /etc/cron.d/xp-all
echo "0 0,12 * * * root /usr/bin/xp" >> /etc/cron.d/xp-expired
systemctl restart cron >> /dev/null 2>&1
cat > /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
history -c
menu
END
chmod 644 /root/.profile
echo '' > .bash_history
echo "unset HISTFILE" >> ~/.bashrc
source ~/.bashrc
make_folder_xray
cd
apt autoclean -y >/dev/null 2>&1
apt -y remove --purge unscd >/dev/null 2>&1
apt-get -y --purge remove samba* >/dev/null 2>&1
apt-get -y --purge remove apache2* >/dev/null 2>&1
apt-get -y --purge remove bind9* >/dev/null 2>&1
apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
chown -R www-data:www-data /var/www/html
# finishing
cp /etc/openvpn/client-tcp-1194.ovpn /var/www/html/tcp.ovpn
cp /etc/openvpn/client-udp-25000.ovpn /var/www/html/udp.ovpn
cp /etc/openvpn/client-ohp.ovpn /var/www/html/ohp.ovpn
cd /var/www/html/
zip openvpn-config.zip tcp.ovpn udp.ovpn ohp.ovpn > /dev/null 2>&1
cd
}

function install_noobz() {
cd
wget -q --no-check-certificate -O noobzvpns.zip "https://panel.zenssh.com/api/files/ssh/noobzvpns.zip" >/dev/null 2>&1
unzip noobzvpns.zip >> /dev/null 2>&1
chmod +x noobzvpns/*
cd noobzvpns
bash install.sh >> /dev/null 2>&1
cd
systemctl restart noobzvpns >> /dev/null 2>&1
rm -rf /root/noobzvpns.zip >> /dev/null 2>&1
rm -rf /root/noobzvpns >> /dev/null 2>&1
clear
}

function update_systems() {
# UPDATE SYSTEM
rm -rf /usr/sbin/vipssh >> /dev/null 2>&1
apt update -y >> /dev/null 2>&1
apt install sudo -y >> /dev/null 2>&1
apt-get clean all -y >> /dev/null 2>&1
apt-get autoremove -y >> /dev/null 2>&1
apt-get debconf-utils -y >> /dev/null 2>&1
apt-get remove --purge exim4 -y >> /dev/null 2>&1
apt-get remove --purge ufw firewalld -y >> /dev/null 2>&1
apt install -y --no-install-recommends software-properties-common >> /dev/null 2>&1
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections >> /dev/null 2>&1
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections >> /dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install iptables iptables-persistent netfilter-persistent figlet ruby libxml-parser-perl squid nmap screen curl jq bzip2 gzip coreutils rsyslog iftop htop zip unzip net-tools sed gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch screenfetch lsof openssl openvpn easy-rsa fail2ban tmux stunnel4 squid3 socat cron bash-completion ntpdate xz-utils apt-transport-https gnupg2 dnsutils lsb-release chrony libnss3-dev libnspr4-dev pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools libevent-dev xl2tpd pptpd apt git speedtest-cli p7zip-full libjpeg-dev zlib1g-dev python python3 python3-pip shc build-essential nodejs php php-fpm php-cli php-mysql p7zip-full >> /dev/null 2>&1
apt install curl -y >> /dev/null 2>&1
apt install jq -y >> /dev/null 2>&1
apt-get install gnupg -y >> /dev/null 2>&1
apt-get install -y libsqlite3-dev >> /dev/null 2>&1
apt-get install -y sudo >> /dev/null 2>&1
apt-get install -y wget >> /dev/null 2>&1
apt-get install -y build-essential >> /dev/null 2>&1
apt install -y libnss3-dev libnspr4-dev pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools libevent-dev xl2tpd pptpd >> /dev/null 2>&1
apt-get install -y curl build-essential make gcc libpcre3 libpcre3-dev libpcre++-dev zlib1g-dev libbz2-dev libxslt1-dev libxml2-dev libgeoip-dev libgoogle-perftools-dev libgd-dev libperl-dev libssl-dev libcurl4-openssl-dev >> /dev/null 2>&1
apt-get install -y libpcre2-posix0 >> /dev/null 2>&1
apt update -y >> /dev/null 2>&1
apt upgrade -y >> /dev/null 2>&1
apt install socat netfilter-persistent -y >> /dev/null 2>&1
apt install lsof fail2ban -y >> /dev/null 2>&1
apt install curl sudo -y >> /dev/null 2>&1
apt install -y jq >> /dev/null 2>&1
mkdir /backup >> /dev/null 2>&1
mkdir /user >> /dev/null 2>&1
mkdir /tmp >> /dev/null 2>&1
apt install resolvconf network-manager dnsutils bind9 -y >> /dev/null 2>&1
cat > /etc/systemd/resolved.conf << 'END'
[Resolve]
DNS=8.8.8.8 8.8.4.4
ReadEtcHosts=yes
END
systemctl enable resolvconf >> /dev/null 2>&1
systemctl enable systemd-resolved >> /dev/null 2>&1
systemctl enable NetworkManager >> /dev/null 2>&1
rm -rf /etc/resolv.conf >> /dev/null 2>&1
rm -rf /etc/resolvconf/resolv.conf.d/head >> /dev/null 2>&1
echo "
nameserver 127.0.0.53
" >> /etc/resolv.conf
echo "
" >> /etc/resolvconf/resolv.conf.d/head
systemctl restart resolvconf >> /dev/null 2>&1
systemctl restart systemd-resolved >> /dev/null 2>&1
systemctl restart NetworkManager >> /dev/null 2>&1
echo "Google DNS" > /usr/current
}

function install_update2() {
# UPDATE TWO STEP
apt -y install fail2ban >> /dev/null 2>&1
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof >> /dev/null 2>&1
apt install ssl-cert -y >> /dev/null 2>&1
apt install ca-certificates -y >> /dev/null 2>&1
apt update -y >> /dev/null 2>&1
apt upgrade -y >> /dev/null 2>&1
apt install dos2unix -y >> /dev/null 2>&1
apt install socat -y >> /dev/null 2>&1
apt install ruby -y >> /dev/null 2>&1
apt install python -y >> /dev/null 2>&1
apt install make -y >> /dev/null 2>&1
apt install shc -y >> /dev/null 2>&1
apt install at -y >> /dev/null 2>&1
sudo systemctl start atd >> /dev/null 2>&1
sudo systemctl enable atd >> /dev/null 2>&1
apt install rsyslog -y >> /dev/null 2>&1
apt install zip -y >> /dev/null 2>&1
apt install unzip -y >> /dev/null 2>&1
apt install nano -y >> /dev/null 2>&1
apt install sed -y >> /dev/null 2>&1
apt install gnupg -y >> /dev/null 2>&1
apt install gnupg1 -y >> /dev/null 2>&1
apt install bc -y >> /dev/null 2>&1
apt install lsof -y >> /dev/null 2>&1
apt install libz-dev -y >> /dev/null 2>&1
apt install gcc -y >> /dev/null 2>&1
apt install g++ -y >> /dev/null 2>&1
mkdir -p /usr/sbin/vipssh >/dev/null 2>&1
# remove unnecessary files
sudo apt-get autoclean -y >/dev/null 2>&1
audo apt-get -y --purge removd unscd >/dev/null 2>&1
sudo apt-get -y --purge remove samba* >/dev/null 2>&1
sudo apt-get -y --purge remove apache2* >/dev/null 2>&1
sudo apt-get -y --purge remove bind9* >/dev/null 2>&1
sudo apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
wget -q --no-check-certificate -O /usr/bin/urlpanel "https://raw.githubusercontent.com/xploitbatam/key/main/urlpanel" >/dev/null 2>&1
wget -q --no-check-certificate -O /usr/bin/key "https://raw.githubusercontent.com/xploitbatam/key/main/key" >/dev/null 2>&1
}
# end remove unnecessary files
# PROSSES STEP INSTALL
start_spinner "${GB}[ INFO ]${NC} Installation Wait 1 Sec"
sleep 1
stop_spinner $?
clear
# END PROCCES STEP
# START UPDATE
start_spinner "${GB}[ INFO ]${NC} Please Wait Update Progress Step 1"
sleep 2
update_systems
stop_spinner $?
# END UPDATE
# START UPDATE
start_spinner "${GB}[ INFO ]${NC} Please Wait Update Progress Step 2"
sleep 2
install_update2
stop_spinner $?
# END UPDATE
echo ""
echo -e "[ ${tyblue}NOTES${NC} ] Before we go.. "
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] I need check your headers first.."
sleep 1
echo -e "[ ${green}INFO${NC} ] Checking headers"
sleep 1
echo -e "[ ${yell}WARNING${NC} ] Try to install ...."
sleep 1
echo ""
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] If error you need.. to do this"
sleep 1
echo ""
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] 1. apt update -y"
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] 2. apt upgrade -y"
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] 3. apt dist-upgrade -y"
sleep 1
echo ""
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] After rebooting"
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] Then run this script again"
echo -e "[ ${tyblue}NOTES${NC} ] Notes, Script By : ZenSSH"
echo ""
# Variabel yang mungkin Anda miliki
declare ROLES
function license() {
    apiURL="https://panel.zenssh.com/api/data/ip"
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
        PRICE=$(echo "$line" | awk '{print $4}')
        X_API_KEY=$(echo "$line" | awk '{print $5}')
        ROLES=$(echo "$line" | awk '{print $6}')
        STATUS=$(echo "$line" | awk '{print $7}')

        start_date=$(date +'%Y-%m-%d')
        start_unix=$(date -d "$start_date" +%s)
        end_unix=$(date -d "$EXPIRED" +%s)
        diff=$(( (end_unix - start_unix) / (24*60*60) ))

        # Memeriksa izin berdasarkan IP dan status
        if [ "$MYIP" = "$IP" ] && [ "$TODAY" \< "$EXPIRED" ]; then
            permission_found=true
            if [ "$STATUS" = "active" ]; then
                CAPITALIZED_ROLE=$(capitalizeFirstLetter "$ROLES")
                echo -e "${BB}┌───────────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BB}│${NC} ${yell}                       • LICENSE VIPSSH •                    ${NC} ${BB}│$NC"
                echo -e "${BB}└───────────────────────────────────────────────────────────────┘${NC}"
                echo -e "${BB}╭───────────────────────────────────────────────────────────────╮${NC}"
                echo -e "${tyblue}   Registered Name : ${YB}$USERNAME${NC}                                     ${BB}"
                echo -e "${tyblue}   Registered IP   : ${YB}$IP${NC}                               ${BB}"
                echo -e "${tyblue}   X-API KEY       : ${YB}$X_API_KEY${NC}                               ${BB}"
                echo -e "${tyblue}   Roles License   : ${YB}$CAPITALIZED_ROLE${NC}                                      ${BB}"
                echo -e "${tyblue}   Charge Balance  : ${YB}$PRICE${NC}                                      ${BB}"
                echo -e "${tyblue}   Expired         : ${YB}Remaining $diff Days Until Expiration${NC}         ${BB}"
                echo -e "${BB}╰───────────────────────────────────────────────────────────────╯${NC}"
            elif [ "$STATUS" = "suspended" ]; then
                # Menampilkan informasi dengan bentuk lain
                echo -e "${BB}╭────────────────────────────────────────────────────────────────╮${NC}"
                echo -e "${RED}   Your Account is Suspended for user $USERNAME${NC}"
                echo -e "${BB}╰────────────────────────────────────────────────────────────────╯${NC}"
                sleep 3
                exit 1
            elif [ "$STATUS" = "expired" ]; then
                # Menampilkan informasi dengan bentuk lain
                echo -e "${BB}╭───────────────────────────────────────────────────────────────╮${NC}"
                echo -e "${RED}   Your Account has Expired for user $USERNAME${NC}"
                echo -e "${BB}╰───────────────────────────────────────────────────────────────╯${NC}"
                sleep 3
                exit 1
            else
                echo -e "${BB}╭───────────────────────────────────────────────────────────────╮${NC}"
                echo -e "${RED}   Invalid Account Status${NC}"
                echo -e "${BB}╰───────────────────────────────────────────────────────────────╯${NC}"
                sleep 3
                exit 1
              fi
           fi
        fi
    done <<< "$OUTPUT"
    # Menampilkan pesan jika izin tidak ditemukan
    if [ "$permission_found" = false ]; then
        echo -e "${BB}╭───────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${RED}      Access denied Please Register Your License${NC}"
        echo -e "${BB}╰───────────────────────────────────────────────────────────────╯${NC}"
        sleep 3
        exit 1
    fi
}
echo -e "[ ${tyblue}NOTES${NC} ] I need check your license first.."
sleep 2
license
echo -e "[ ${tyblue}NOTES${NC} ] if you understand and start installing tap enter now.."
read
sleep 1
echo -e "[ ${GB}INFO${NC} ] Okay, Installation Will Proccess."
sleep 1
mkdir -p /etc/vipssh/theme
#THEME RED
cat <<EOF>> /etc/vipssh/theme/red
BG : \E[40;1;41m
TEXT : \033[0;31m
EOF
#THEME BLUE
cat <<EOF>> /etc/vipssh/theme/blue
BG : \E[40;1;44m
TEXT : \033[0;34m
EOF
#THEME GREEN
cat <<EOF>> /etc/vipssh/theme/green
BG : \E[40;1;42m
TEXT : \033[0;32m
EOF
#THEME YELLOW
cat <<EOF>> /etc/vipssh/theme/yellow
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME MAGENTA
cat <<EOF>> /etc/vipssh/theme/magenta
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME CYAN
cat <<EOF>> /etc/vipssh/theme/cyan
BG : \E[40;1;46m
TEXT : \033[0;36m
EOF
#THEME CONFIG
cat <<EOF>> /etc/vipssh/theme/color.conf
blue
EOF
#INSTALL BANNER SSH
if [ "$CAPITALIZED_ROLE" = "Admin" ]; then
country=$(curl -s ipinfo.io/city)
echo '<font color="green"><b><h3>&nbsp;&nbsp;Connected</h3></b>
<h3>&nbsp;&nbsp;BANNER COUNTRY</h3>
&nbsp;&nbsp;- <strong>[FREE SERVER]<strong><br>
&nbsp;&nbsp;- OUR SITE VISIT<br>
&nbsp;&nbsp;- ZENSSH.COM<br>
&nbsp;&nbsp;- SPEEDSSH.NET<br>
&nbsp;&nbsp;- ROCKETSSH.NET<br>
&nbsp;&nbsp;- No Torrent Activity<br>
&nbsp;&nbsp;- No Multi Login 2 More Devices<br></font>
&nbsp;&nbsp;<font color="red">- Breaking The Rules > Terminate<br><br></font>
&nbsp;&nbsp; <font color="#00990E"> HAPPY USE SUPPORT BY ZENSSH.COM </font> ' > /etc/zenssh
sed -i '2d' "/etc/zenssh"
sed -i '2i<h3>&nbsp;&nbsp;'"$country"'</h3>' "/etc/zenssh"
elif [ "$CAPITALIZED_ROLE" = "Reseller" ]; then
country=$(curl -s ipinfo.io/city)
echo '<font color="green"><b><h3>&nbsp;&nbsp;Connected</h3></b>
<h3>&nbsp;&nbsp;BANNER COUNTRY</h3>
&nbsp;&nbsp;- <strong>[VIPSERVER]<strong><br>
&nbsp;&nbsp;- No Torrent Activity<br>
&nbsp;&nbsp;- No Multi Login 2 More Devices<br></font>
&nbsp;&nbsp;<font color="red">- Breaking The Rules > Terminate<br><br></font>
&nbsp;&nbsp; <font color="#00990E"> HAPPY USE SUPPORT BY ZENSSH.COM </font> ' > /etc/zenssh
sed -i '2d' "/etc/zenssh"
sed -i '2i<h3>&nbsp;&nbsp;'"$country"'</h3>' "/etc/zenssh"
else
country=$(curl -s ipinfo.io/city)
echo '<font color="green"><b><h3>&nbsp;&nbsp;Connected</h3></b>
<h3>&nbsp;&nbsp;BANNER COUNTRY</h3>
&nbsp;&nbsp;- <strong>[FREE SERVER]<strong><br>
&nbsp;&nbsp;- OUR SITE VISIT<br>
&nbsp;&nbsp;- ZENSSH.COM<br>
&nbsp;&nbsp;- SPEEDSSH.NET<br>
&nbsp;&nbsp;- ROCKETSSH.NET<br>
&nbsp;&nbsp;- No Torrent Activity<br>
&nbsp;&nbsp;- No Multi Login 2 More Devices<br></font>
&nbsp;&nbsp;<font color="red">- Breaking The Rules > Terminate<br><br></font>
&nbsp;&nbsp; <font color="#00990E"> HAPPY USE SUPPORT BY ZENSSH.COM </font> ' > /etc/zenssh
sed -i '2d' "/etc/zenssh"
sed -i '2i<h3>&nbsp;&nbsp;'"$country"'</h3>' "/etc/zenssh"
fi
# END THEME
clear
# START INSTALL HAPROXY
start_spinner "${GB}[ INFO ]${NC} Installation Systems 1"
sleep 1
install_haproxy
stop_spinner $?
# END INSTALL HAPROXY

# START INSTALL SSH
start_spinner "${GB}[ INFO ]${NC} Installation Systems 2"
sleep 1
install_ssh
install_dropbear
stop_spinner $?
# END INSTALL SSH

# START INSTALL XRAY
start_spinner "${GB}[ INFO ]${NC} Installation Systems 3"
sleep 1
install_xray
install_domain
stop_spinner $?
# END INSTALL XRAY

# START INSTALL DOMAIN
start_spinner "${GB}[ INFO ]${NC} Installation Systems 4"
sleep 2
install_domain
stop_spinner $?
# END INSTALL DOMAIN

# START INSTALL NGINX
start_spinner "${GB}[ INFO ]${NC} Installation Systems 5"
sleep 1
install_nginx
install_speedtest
install_vnstat
stop_spinner $?
# END INSTALL NGINX

# START INSTALL MENU AND FIRWALL
start_spinner "${GB}[ INFO ]${NC} Installation Systems 6"
sleep 1
install_menu
install_firwall
stop_spinner $?
# END INSTALL MENU AND FIRWALL


# START INSTALL OHP OPENVPN
start_spinner "${GB}[ INFO ]${NC} Installation Systems 7"
sleep 1
wget -q --no-check-certificate -O ohp "https://panel.zenssh.com/api/files/ohp/ohp.sh" && chmod +x ohp && sed -i -e 's/\r$//' ohp && bash ohp >/dev/null 2>&1
rm -rf /root/ohp >> /dev/null 2>&1
stop_spinner $?
# END INSTALL OHP OPENVPN

# START INSTALL UDP CUSTOM
start_spinner "${GB}[ INFO ]${NC} Installation Systems 8"
sleep 1
wget -q --no-check-certificate -O udpinstall "https://panel.zenssh.com/api/files/udpcustom/udp-custom.sh" && chmod +x udpinstall && sed -i -e 's/\r$//' udpinstall && bash udpinstall 7100,7200,7300,7400,7500,7600,25000,2443,2052,9090,14022,8488,5355,53,5300,443,80,69,444,22,2222,143,1194,55,808,10000 >/dev/null 2>&1
stop_spinner $?
# END INSTALL UDP CUSTOM

# START INSTALL RESTART
start_spinner "${GB}[ INFO ]${NC} Installation Systems 9"
sleep 2
restart_service
stop_spinner $?
# END INSTALL RESTART

# START INSTALL FINISH
start_spinner "${GB}[ INFO ]${NC} Installation Complete"
sleep 2
finishing
install_noobz
stop_spinner $?
clear
cd
installdns
start_spinner "${GB}[ INFO ]${NC} Installation All Complated, Thanks You Use AutoScript."
sleep 4
stop_spinner $?  
# END INSTALL FINISH
# END INSTALL FINISH
clear
echo ""
echo -e "${tyblue}╭════════════════════════════════════════════╮${NC}"
echo -e "${tyblue}│         ${GB}${GB} INSTALL SCRIPT SELESAI..         ${NC}${tyblue} │${NC}"
echo -e "${tyblue}╰════════════════════════════════════════════╯${NC}"
echo ""
echo ""
echo -e "[ ${tyblue}NOTES${NC} ] Please Reboot After Installation All Complated."
echo ""
echo ""
notification_bot
history -c >/dev/null 2>&1
> ~/.bash_history >/dev/null 2>&1
rm -rf /root/setup.sh >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))"
echo -e "${YB}[ WARNING ] reboot now ? (Y/N)${NC} "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
rm -rf /root/setup.sh >/dev/null 2>&1
reboot
fi
