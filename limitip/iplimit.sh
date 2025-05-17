#!/bin/bash
apiURL=$(cat /usr/bin/urlpanel)
wget -q -O /etc/systemd/system/limitipvmess.service "$apiURL/api/files/limitip/vmess.service"
wget -q -O /etc/systemd/system/limitipvless.service "$apiURL/api/files/limitip/vless.service"
wget -q -O /etc/systemd/system/limitiptrojan.service "$apiURL/api/files/limitip/trojan.service"
wget -q -O /etc/systemd/system/limitipss.service "$apiURL/api/files/limitip/ss.service"
wget -q -O /etc/systemd/system/limitipss2022.service "$apiURL/api/files/limitip/ss2022.service"
wget -q -O /etc/systemd/system/limitipsocks.service "$apiURL/api/files/limitip/socks.service"

wget -q -O /usr/bin/limitipvmess "$apiURL/api/files/limitip/limitipvmess.sh"
wget -q -O /usr/bin/limitipvless "$apiURL/api/files/limitip/limitipvless.sh"
wget -q -O /usr/bin/limitiptrojan "$apiURL/api/files/limitip/limitiptrojan.sh"
wget -q -O /usr/bin/limitipss "$apiURL/api/files/limitip/limitipss.sh"
wget -q -O /usr/bin/limitipss2022 "$apiURL/api/files/limitip/limitipss2022.sh"
wget -q -O /usr/bin/limitipsocks "$apiURL/api/files/limitip/limitipsocks.sh"

wget -q -O /usr/bin/status-limit "$apiURL/api/files/limitip/status.sh"

chmod +x /etc/systemd/system/limitipvmess.service
chmod +x /etc/systemd/system/limitipvless.service
chmod +x /etc/systemd/system/limitiptrojan.service
chmod +x /etc/systemd/system/limitipss.service
chmod +x /etc/systemd/system/limitipss2022.service
chmod +x /etc/systemd/system/limitipsocks.service

chmod +x /usr/bin/limitipvmess
chmod +x /usr/bin/limitipvless
chmod +x /usr/bin/limitiptrojan
chmod +x /usr/bin/limitipss
chmod +x /usr/bin/limitipss2022
chmod +x /usr/bin/limitipsocks
chmod +x /usr/bin/status-limit

systemctl daemon-reload

# systemctl enable limitipvmess
# systemctl enable limitipvless
# systemctl enable limitiptrojan
# systemctl enable limitipss
# systemctl enable limitipss2022
# systemctl enable limitipsocks

# systemctl start limitipvmess
# systemctl start limitipvless
# systemctl start limitiptrojan
# systemctl start limitipss
# systemctl start limitipss2022
# systemctl start limitipsocks

# systemctl restart limitipvmess
# systemctl restart limitipvless
# systemctl restart limitiptrojan
# systemctl restart limitipss
# systemctl restart limitipss2022
# systemctl restart limitipsocks
rm -rf /root/iplimit
