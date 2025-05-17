#!/bin/bash
#Install WS
apiFILE=$(cat /usr/bin/urlpanel)
wget -q --no-check-certificate -O /usr/sbin/ws $apiFILE/api/files/websocket/ws
wget -q --no-check-certificate -O /usr/sbin/tunws.conf $apiFILE/api/files/websocket/tunws.conf
#izin permision
chmod +x /usr/sbin/ws
chmod 644 /usr/sbin/tunws.conf
#System WS
wget -q --no-check-certificate -O /etc/systemd/system/ws.service $apiFILE/api/files/websocket/ws.service && chmod +x /etc/systemd/system/ws.service
cd
#restart service
rm -rf /root/ws


