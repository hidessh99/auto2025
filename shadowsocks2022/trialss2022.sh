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
cipher2="2022-blake3-aes-256-gcm"
userpsk=$(openssl rand -base64 32)
serverpsk=$(cat /usr/local/etc/xray/serverpsk)
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#shadowsocks2022$/a\#% '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks2022.json
sed -i '/#shadowsocks2022-grpc$/a\#% '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks2022.json
echo -n "$cipher2:$serverpsk:$userpsk" | base64 -w 0 > /tmp/log
ss2022_base64=$(cat /tmp/log)
ss2022link1="ss://${ss2022_base64}@$domain:443?path=/shadowsocks2022&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
ss2022link2="ss://${ss2022_base64}@$domain:80?path=/shadowsocks2022&security=none&host=${domain}&type=ws#${user}"
ss2022link3="ss://${ss2022_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks2022-grpc&sni=$domain#${user}"
rm -rf /tmp/log
cat > /var/www/html/shadowsocks2022/shadowsocks2022-$user.txt << END
===============================
Shadowsocks 2022 WS (CDN) TLS
===============================
- name: SS2022-$user
type: ss
server: $domain
port: 443
cipher: $cipher2
password: $serverpsk:$userpsk
plugin: v2ray-plugin
plugin-opts:
mode: websocket
tls: true
skip-cert-verify: true
host: $domain
path: "/shadowsocks2022"
mux: true
=============================
Shadowsocks 2022 WS (CDN)
=============================
- name: SS2022-$user
type: ss
server: $domain
port: 80
cipher: $cipher2
password: $serverpsk:$userpsk
plugin: v2ray-plugin
plugin-opts:
mode: websocket
tls: false
skip-cert-verify: false
host: $domain
path: "/shadowsocks2022"
mux: true
===============================
Link Shadowsocks 2022 Account
===============================
Link TLS : ss://${ss2022_base64}@$domain:443?path=/shadowsocks2022&security=tls&host=${domain}&type=ws&sni=${domain}#${user}
==============================
Link NTLS : ss://${ss2022_base64}@$domain:80?path=/shadowsocks2022&security=none&host=${domain}&type=ws#${user}
==============================
Link gRPC : ss://${ss2022_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks2022-grpc&sni=$domain#${user}
==============================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart vipssh@shadowsocks2022.service
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "           Trial Shadowsocks 2022 Account           " | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-ss2022-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-ss2022-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-ss2022-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-ss2022-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-ss2022-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-ss2022-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-ss2022-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-ss2022-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-ss2022-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-ss2022-$user.txt
echo -e "Cipher        : ${cipher2}" | tee -a /user/log-ss2022-$user.txt
echo -e "Password      : $serverpsk:$userpsk" | tee -a /user/log-ss2022-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-ss2022-$user.txt
echo -e "Path          : /shadowsocks2022" | tee -a /user/log-ss2022-$user.txt
echo -e "ServiceName   : shadowsocks2022-grpc" | tee -a /user/log-ss2022-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link TLS      : ${ss2022link1}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link NTLS     : ${ss2022link2}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link gRPC     : ${ss2022link3}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Format Clash  : http://$domain:81/shadowsocks2022/shadowsocks2022-$user.txt" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
shadowsocks2022
