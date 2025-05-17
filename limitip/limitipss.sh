#!/bin/bash

NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
RED='\033[0;31m'
GREEN='\033[0;32m'

while true; do
  sleep 30
  echo -n >/tmp/other.txt
  data=($(cat /etc/default/syncron/shadowsocks.json | grep '^#!' | cut -d ' ' -f 2 | sort | uniq))
  for akun in "${data[@]}"; do
    # Kode lainnya di dalam perulangan for
    
    echo -n >/tmp/ipshadowsocks.txt
    data2=($(cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq))
    for ip in "${data2[@]}"; do
      jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
      if [[ "$jum" = "$ip" ]]; then
        echo "$jum" >>/tmp/ipshadowsocks.txt
      else
        echo "$ip" >>/tmp/other.txt
      fi
      jum2=$(cat /tmp/ipshadowsocks.txt | sort | uniq)
      sed -i "/$jum2/d" /tmp/other.txt >/dev/null 2>&1
    done
    
    jum=$(cat /tmp/ipshadowsocks.txt)
    if [[ -z "$jum" ]]; then
      echo >/dev/null
    else
      jum2=$(echo "$jum" | wc -l)
      byte=$(cat /etc/limit/shadowsocks/$akun)

      # Konversi ke GiB jika nilai melebihi atau sama dengan 1 GiB
      if ((byte >= 1024 * 1024 * 1024)); then
        quota=$((byte / (1024 * 1024 * 1024)))
        unit="GiB"
      # Konversi ke MiB jika nilai melebihi atau sama dengan 1 MiB
      elif ((byte >= 1024 * 1024)); then
        quota=$((byte / (1024 * 1024)))
        unit="MiB"
      # Konversi ke KiB jika nilai melebihi atau sama dengan 1 KiB
      elif ((byte >= 1024)); then
        quota=$((byte / 1024))
        unit="KiB"
      else
        quota=$byte
        unit="byte"
      fi
      limit=$(cat /etc/shadowsocks/.shadowsocks.db | grep -w "$akun" | awk '{print $5}')
      TOKEN="5813428539:AAGYOn5lRxkQGLPztqywj4ePcyNrSOgMDSE"
      CHAT_ID="1496322138"
      DATE=$(date '+%Y-%m-%d')
      TIME=$(date '+%H:%M:%S')
      domain=$(cat /usr/local/etc/xray/domain)

      # Fungsi untuk mengirim pesan menggunakan bot Telegram
      send_message() {
        message=$(echo -e "$1")
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID&parse_mode=HTML&text=$message" >/dev/null
      }

      if [ "$jum2" -gt "$limit" ]; then
        IPS=$(echo "$jum" | awk '{printf "%s  \n", $0}' | sort | uniq)
        IP_LIST=""
        while read -r IP; do
          ISP=$(curl -s "http://ip-api.com/json/$IP" | grep -oP '(?<="isp":")[^"]+')
          IP_LIST+="$IP - $ISP\n"
        done <<< "$IPS"
        send_message "
<code>───────────────────────────</code>
    <b>Laporan VPS - Multi Login</b>
      <code><b>$domain</b></code>
<code>───────────────────────────</code>
        <b>XRay Shadowsocks</b>
<code>───────────────────────────</code>

Tanggal: $DATE
Waktu: $TIME
User: <b>$akun</b>
Quota: <b>$quota $unit</b>
Jumlah: <b>$jum2</b> Akun
Limit Login: $limit
IP Address:
$IP_LIST

Terdapat multi-login pada VPS.
<code>───────────────────────────</code>
"
      elif [ "$jum2" -lt "$limit" ]; then
        echo ""
      else
        echo ""
      fi
    fi
    rm -rf /tmp/ipshadowsocks.txt
  done
  rm -rf /tmp/other.txt
done
