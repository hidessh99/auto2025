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
cipher="aes-256-gcm"
cipher2="2022-blake3-aes-256-gcm"
userpsk=$(openssl rand -base64 32)
uuid=$(cat /proc/sys/kernel/random/uuid)
serverpsk=$(cat /usr/local/etc/xray/serverpsk)
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/default/syncron/vmess.json
sed -i '/#vless$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/default/syncron/vless.json
sed -i '/#trojan$/a\#&@ '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/default/syncron/trojan.json
sed -i '/#shadowsocks$/a\#&@ '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks.json
sed -i '/#shadowsocks2022$/a\#&@ '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks2022.json
sed -i '/#socks$/a\#&@ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
sed -i '/#vmess-grpc$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/default/syncron/vmess.json
sed -i '/#vless-grpc$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/default/syncron/vless.json
sed -i '/#trojan-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/default/syncron/trojan.json
sed -i '/#shadowsocks-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks.json
sed -i '/#shadowsocks2022-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks2022.json
sed -i '/#socks-grpc$/a\#&@ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
vmlink1=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vmlink2=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "none"
}
EOF`
vmlink3=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "vmess-grpc",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vmesslink1="vmess://$(echo $vmlink1 | base64 -w 0)"
vmesslink2="vmess://$(echo $vmlink2 | base64 -w 0)"
vmesslink3="vmess://$(echo $vmlink3 | base64 -w 0)"
vlesslink1="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user"
vlesslink2="vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user"
vlesslink3="vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user"
trojanlink1="trojan://$uuid@$domain:443?path=/trojan&security=tls&host=$domain&type=ws&sni=$domain#$user"
trojanlink2="trojan://${uuid}@$domain:80?path=/trojan&security=none&host=$domain&type=ws#$user"
trojanlink3="trojan://${uuid}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user"
echo -n "$cipher2:$serverpsk:$userpsk" | base64 -w 0 > /tmp/log
ss22_base64=$(cat /tmp/log)
ss22link1="ss://${ss22_base64}@$domain:443?path=/shadowsocks2022&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
ss22link2="ss://${ss22_base64}@$domain:80?path=/shadowsocks2022&security=none&host=${domain}&type=ws#${user}"
ss22link3="ss://${ss22_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks2022-grpc&sni=$domain#${user}"
rm -rf /tmp/log
echo -n "$cipher:$uuid" | base64 > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
shadowsockslink1="ss://${shadowsocks_base64}@$domain:443?path=/shadowsocks&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink2="ss://${shadowsocks_base64}@$domain:80?path=/shadowsocks&security=none&host=${domain}&type=ws#${user}"
shadowsockslink3="ss://${shadowsocks_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks-grpc&sni=$domain#${user}"
rm -rf /tmp/log
echo -n "$user:$pass" | base64 > /tmp/log
socks_base64=$(cat /tmp/log)
sockslink1="socks://$socks_base64@$domain:443?path=/socks5&security=tls&host=$domain&type=ws&sni=$domain#$user"
sockslink2="socks://$socks_base64@$domain:80?path=/socks5&security=none&host=$domain&type=ws#$user"
sockslink3="socks://$socks_base64@$domain:443?security=tls&encryption=none&type=grpc&serviceName=socks5-grpc&sni=$domain#$user"
rm -rf /tmp/log
cat > /var/www/html/allxray/allxray-$user.txt << END
========================================
----- [ All Xray ] -----
Vmess, Vless, Trojan
Shadowsocks 2022, Shadowsocks, Socks5
========================================
Domain           : $domain
Wildcard         : (bug.com).$domain
ISP              : $ISP
City             : $CITY
Port TLS         : 443
Port NTLS        : 80
Port gRPC        : 443
Alt Port TLS     : 2053, 2083, 2087, 2096, 8443
Alt Port NTLS    : 8080, 8880, 2052, 2082, 2086, 2095
Cipher SS        : $cipher
Cipher SS2022    : $cipher2
Password         : $uuid
Pass SS2022      : $serverpsk:$userpsk
Username Socks5  : $user
Password Socks5  : $pass
Network          : Websocket, gRPC
Alpn             : h2, http/1.1
Expired On       : $exp
========================================
----- [ Vmess Link ] -----
========================================
Link TLS   : $vmesslink1
========================================
Link NTLS  : $vmesslink2
========================================
Link gRPC  : $vmesslink3
========================================
========================================
----- [ Vless Link ] -----
========================================
Link TLS   : $vlesslink1
========================================
Link NTLS  : $vlesslink2
========================================
Link gRPC  : $vlesslink3
========================================
========================================
----- [ Trojan Link ] -----
========================================
Link TLS   : $trojanlink1
========================================
Link NTLS  : $trojanlink2
========================================
Link gRPC  : $trojanlink3
========================================
========================================
----- [ Shadowsocks 2022 Link ] -----
========================================
Link TLS   : $ss22link1
========================================
Link NTLS  : $ss22link2
========================================
Link gRPC  : $ss22link3
========================================
========================================
----- [ Shadowsocks Link ] -----
========================================
Link TLS   : $shadowsockslink1
========================================
Link NTLS  : $shadowsockslink2
========================================
Link gRPC  : $shadowsockslink3
========================================
========================================
----- [ Socks5 Link ] -----
========================================
Link TLS   : $sockslink1
========================================
Link NTLS  : $sockslink2
========================================
Link gRPC  : $sockslink3
========================================
END
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "           ----- [ Trial All Xray ] -----           " | tee -a /user/log-allxray-$user.txt
echo -e "                Vmess, Vless, Trojan                " | tee -a /user/log-allxray-$user.txt
echo -e "       Shadowsocks 2022, Shadowsocks, Socks5        " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Domain           : $domain" | tee -a /user/log-allxray-$user.txt
echo -e "Wildcard         : (bug.com).$domain" | tee -a /user/log-allxray-$user.txt
echo -e "ISP              : $ISP" | tee -a /user/log-allxray-$user.txt
echo -e "City             : $CITY" | tee -a /user/log-allxray-$user.txt
echo -e "Port TLS         : 443" | tee -a /user/log-allxray-$user.txt
echo -e "Port NTLS        : 80" | tee -a /user/log-allxray-$user.txt
echo -e "Port gRPC        : 443" | tee -a /user/log-allxray-$user.txt
echo -e "Alt Port TLS     : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-allxray-$user.txt
echo -e "Alt Port NTLS    : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-allxray-$user.txt
echo -e "Cipher SS        : $cipher" | tee -a /user/log-allxray-$user.txt
echo -e "Cipher SS2022    : $cipher2" | tee -a /user/log-allxray-$user.txt
echo -e "Password         : $uuid" | tee -a /user/log-allxray-$user.txt
echo -e "Pass SS2022      : $serverpsk:$userpsk" | tee -a /user/log-allxray-$user.txt
echo -e "Username Socks5  : $user" | tee -a /user/log-allxray-$user.txt
echo -e "Password Socks5  : $pass" | tee -a /user/log-allxray-$user.txt
echo -e "Network          : Websocket, gRPC" | tee -a /user/log-allxray-$user.txt
echo -e "Alpn             : h2, http/1.1" | tee -a /user/log-allxray-$user.txt
echo -e "Expired On       : $exp" | tee -a /user/log-allxray-$user.txt
echo -e "Link Akun        : http://$domain:81/allxray/allxray-$user.txt" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "             ----- [ Vmess Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $vmesslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $vmesslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $vmesslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "             ----- [ Vless Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $vlesslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $vlesslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $vlesslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "            ----- [ Trojan Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $trojanlink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $trojanlink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $trojanlink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "        ----- [ Shadowsocks 2022 Link ] -----       " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $ss22link1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $ss22link2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $ss22link3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "           ----- [ Shadowsocks Link ] -----         " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $shadowsockslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $shadowsockslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $shadowsockslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "             ----- [ Socks5 Link ] -----            " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $sockslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $sockslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $sockslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
allxray
