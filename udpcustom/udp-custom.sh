#!/bin/bash

cd
rm -rf /usr/sbin/udp > /dev/null 2>&1
mkdir -p /usr/sbin/udp > /dev/null 2>&1
apiFILE=$(cat /usr/bin/urlpanel)
# install udp-custom
wget -q --no-check-certificate -O /usr/sbin/udp/udp-custom $apiFILE/api/files/udpcustom/udp-custom-linux-amd64
chmod +x /usr/sbin/udp/udp-custom

wget -q --no-check-certificate -O /usr/sbin/udp/config.json $apiFILE/api/files/udpcustom/config.json
chmod 644 /usr/sbin/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/usr/sbin/udp/udp-custom server
WorkingDirectory=/usr/sbin/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/usr/sbin/udp/udp-custom server -exclude $1
WorkingDirectory=/usr/sbin/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

systemctl start udp-custom &>/dev/null
systemctl enable udp-custom &>/dev/null

rm -rf /root/udpinstall >/dev/null 2>&1
