#!/bin/bash

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

domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
pass=`echo $RANDOM | head -c4`
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#socks$/a\#÷ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
sed -i '/#socks-grpc$/a\#÷ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
echo -n "$user:$pass" | base64 > /tmp/log
socks_base64=$(cat /tmp/log)
sockslink1="socks://$socks_base64@$domain:443?path=/socks5&security=tls&host=$domain&type=ws&sni=$domain#$user"
sockslink2="socks://$socks_base64@$domain:80?path=/socks5&security=none&host=$domain&type=ws#$user"
sockslink3="socks://$socks_base64@$domain:443?security=tls&encryption=none&type=grpc&serviceName=socks5-grpc&sni=$domain#$user"
rm -rf /tmp/log
cat > /var/www/html/socks5/socks5-$user.txt << EOF
========================
Format Json Socks5
========================
{
"inbounds": [],
"outbounds": [
{
"mux": {
"enabled": true
},
"protocol": "socks",
"settings": {
"servers": [
{
"address": "$domain",
"port": 443,
"users": [
{
"level": 8,
"pass": "$pass",
"user": "$user"
}
]
}
]
},
"streamSettings": {
"network": "ws",
"security": "tls",
"tlsSettings": {
"allowInsecure": true,
"serverName": "$domain"
},
"wsSettings": {
"headers": {
"Host": "$domain"
},
"path": "/socks5"
}
},
"tag": "XRAY"
}
],
"policy": {
"levels": {
"8": {
"connIdle": 300,
"downlinkOnly": 1,
"handshake": 4,
"uplinkOnly": 1
}
}
}
}
===============================
Link Socks5 Account
===============================
Link TLS : socks://$socks_base64@$domain:443?path=/socks5&security=tls&host=$domain&type=ws&sni=$domain#$user
==============================
Link NTLS : socks://$socks_base64@$domain:80?path=/socks5&security=none&host=$domain&type=ws#$user
==============================
Link gRPC : socks://$socks_base64@$domain:443?security=tls&encryption=none&type=grpc&serviceName=socks5-grpc&sni=$domain#$user
==============================
EOF
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart vipssh@socks.service
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "               Trial Socks5 Account                 " | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Username      : ${user}" | tee -a /user/log-socks5-$user.txt
echo -e "Password      : ${pass}" | tee -a /user/log-socks5-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-socks5-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-socks5-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-socks5-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-socks5-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-socks5-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-socks5-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-socks5-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-socks5-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-socks5-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-socks5-$user.txt
echo -e "Path          : /socks5" | tee -a /user/log-socks5-$user.txt
echo -e "ServiceName   : socks5-grpc" | tee -a /user/log-socks5-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link TLS      : ${sockslink1}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link NTLS     : ${sockslink2}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link gRPC     : ${sockslink3}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Format JSON   : http://$domain:81/socks5/socks5-$user.txt" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
socks
