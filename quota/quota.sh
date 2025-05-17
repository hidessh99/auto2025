#!/bin/bash
apiFILE=$(cat /usr/bin/urlpanel)
wget -q -O /etc/systemd/system/limitvmess.service "$apiFILE/api/files/quota/vmess.service"
wget -q -O /etc/systemd/system/limitvless.service "$apiFILE/api/files/quota/vless.service"
wget -q -O /etc/systemd/system/limittrojan.service "$apiFILE/api/files/quota/trojan.service"
wget -q -O /etc/systemd/system/limitshadowsocks.service "$apiFILE/api/files/quota/shadowsocks.service"
wget -q -O /etc/systemd/system/limitshadowsocks2022.service "$apiFILE/api/files/quota/shadowsocks2022.service"
wget -q -O /etc/systemd/system/limitsocks.service "$apiFILE/api/files/quota/socks.service"
wget -q -O /usr/local/etc/xray/limit.vmess "$apiFILE/api/files/quota/vmess.sh"
wget -q -O /usr/local/etc/xray/limit.vless "$apiFILE/api/files/quota/vless.sh"
wget -q -O /usr/local/etc/xray/limit.trojan "$apiFILE/api/files/quota/trojan.sh"
wget -q -O /usr/local/etc/xray/limit.shadowsocks "$apiFILE/api/files/quota/shadowsocks.sh"
wget -q -O /usr/local/etc/xray/limit.shadowsocks2022 "$apiFILE/api/files/quota/shadowsocks2022.sh"
wget -q -O /usr/local/etc/xray/limit.socks "$apiFILE/api/files/quota/socks.sh"
chmod +x /etc/systemd/system/limitvmess.service
chmod +x /etc/systemd/system/limitvless.service
chmod +x /etc/systemd/system/limittrojan.service
chmod +x /etc/systemd/system/limitshadowsocks.service
chmod +x /etc/systemd/system/limitshadowsocks2022.service
chmod +x /etc/systemd/system/limitsocks.service
chmod +x /usr/local/etc/xray/limit.vmess
chmod +x /usr/local/etc/xray/limit.vless
chmod +x /usr/local/etc/xray/limit.trojan
chmod +x /usr/local/etc/xray/limit.shadowsocks
chmod +x /usr/local/etc/xray/limit.shadowsocks2022
chmod +x /usr/local/etc/xray/limit.socks
systemctl daemon-reload
systemctl enable limitvmess >> /dev/null 2>&1
systemctl enable limitvless >> /dev/null 2>&1
systemctl enable limittrojan >> /dev/null 2>&1
systemctl enable limitshadowsocks >> /dev/null 2>&1
systemctl enable limitshadowsocks2022 >> /dev/null 2>&1
systemctl enable limitsocks >> /dev/null 2>&1
systemctl start limitvmess >> /dev/null 2>&1
systemctl start limitvless >> /dev/null 2>&1
systemctl start limittrojan >> /dev/null 2>&1
systemctl start limitshadowsocks >> /dev/null 2>&1
systemctl start limitshadowsocks2022 >> /dev/null 2>&1
systemctl start limitsocks >> /dev/null 2>&1
systemctl restart limitvmess >> /dev/null 2>&1
systemctl restart limitvless >> /dev/null 2>&1
systemctl restart limittrojan >> /dev/null 2>&1
systemctl restart limitshadowsocks >> /dev/null 2>&1
systemctl restart limitshadowsocks2022 >> /dev/null 2>&1
systemctl restart limitsocks >> /dev/null 2>&1
rm -rf /root/quota
