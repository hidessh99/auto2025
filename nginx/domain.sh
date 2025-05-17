#!/bin/bash
apt install jq curl -y >> /dev/null 2>&1
DOMAIN=sshserver.sbs
subb=$(</dev/urandom tr -dc a-z0-9 | head -c4)
SUB_DOMAIN=${subb}.sshserver.sbs
CF_ID=youemail@gmail.com
CF_KEY=a014b1da0eab94cbe980e8024334637017497
set -euo pipefail
IPP=$(wget -qO- ipinfo.io/ip)
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
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IPP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IPP}'","ttl":120,"proxied":false}')
touch /usr/local/etc/xray/domain
echo "$SUB_DOMAIN" > /usr/local/etc/xray/domain
echo "$SUB_DOMAIN" > /var/lib/dnsvps.conf
rm -rfv /root/domain
