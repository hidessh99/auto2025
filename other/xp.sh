#!/bin/bash
##------ Auto Remove SSH
# Mendapatkan tanggal hari ini
hariini=$(date +%d-%m-%Y)
# Mengambil username dan tanggal kadaluarsa dari /etc/shadow
cat /etc/shadow | cut -d: -f1,8 | sed '/:$/d' > /tmp/expirelist.txt
# Menghitung total akun
totalaccounts=$(wc -l < /tmp/expirelist.txt)
# Loop untuk memproses setiap akun
for ((i=1; i<=totalaccounts; i++))
do
tuserval=$(sed -n "${i}p" /tmp/expirelist.txt)
username=$(echo "$tuserval" | cut -d: -f1)
userexp=$(echo "$tuserval" | cut -d: -f2)
# Menghitung tanggal kadaluarsa dalam detik
userexpireinseconds=$(( userexp * 86400 ))
tglexp=$(date -d "@$userexpireinseconds" '+%d-%b-%Y')
todaystime=$(date +%s)
# Memeriksa apakah akun telah kadaluarsa
if [ "$userexpireinseconds" -lt "$todaystime" ]; then
userdel --force "$username"
sed -i "/\b$username\b/d" /usr/local/etc/xray/ssh.txt
sed -i "/\b$username\b/d" /etc/ssh/.ssh.db
fi
done
# Restart layanan SSH
systemctl restart sshd
systemctl restart ssh
systemctl restart dropbear
rm /tmp/expirelist.txt

# AUTO REMOVE XRAY
data=($(cat /etc/default/syncron/vmess.json | grep '^#@' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#@ $user" "/etc/default/syncron/vmess.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#@ $user $exp/,/^},{/d" /etc/default/syncron/vmess.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/vmess.json
rm -rf /var/www/html/vmess/vmess-$user.txt
rm -rf /user/log-vmess-$user.txt
sed -i "/\b$user\b/d" /etc/vmess/.vmess.db
rm -rf /etc/vmess/$user
rm -rf /etc/limit/vmess/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
data=($(cat /etc/default/syncron/vless.json | grep '^#=' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#= $user" "/etc/default/syncron/vless.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#= $user $exp/,/^},{/d" /etc/default/syncron/vless.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/vless.json
rm -rf /var/www/html/vless/vless-$user.txt
rm -rf /user/log-vless-$user.txt
sed -i "/\b$user\b/d" /etc/vless/.vless.db
rm -rf /etc/vless/$user
rm -rf /etc/limit/vless/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
data=($(cat /etc/default/syncron/trojan.json | grep '^#&' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#& $user" "/etc/default/syncron/trojan.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#& $user $exp/,/^},{/d" /etc/default/syncron/trojan.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/trojan.json
rm -rf /var/www/html/trojan/trojan-$user.txt
rm -rf /user/log-trojan-$user.txt
sed -i "/\b$user\b/d" /etc/trojan/.trojan.db
rm -rf /etc/trojan/$user
rm -rf /etc/limit/trojan/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
data=($(cat /etc/default/syncron/shadowsocks.json | grep '^#!' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#! $user" "/etc/default/syncron/shadowsocks.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#! $user $exp/,/^},{/d" /etc/default/syncron/shadowsocks.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/shadowsocks.json
rm -rf /var/www/html/shadowsocks/shadowsocks-$user.txt
rm -rf /user/log-shadowsocks-$user.txt
sed -i "/\b$user\b/d" /etc/shadowsocks/.shadowsocks.db
rm -rf /etc/shadowsocks/$user
rm -rf /etc/limit/shadowsocks/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
data=($(cat /etc/default/syncron/shadowsocks2022.json | grep '^#%' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#% $user" "/etc/default/syncron/shadowsocks2022.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#% $user $exp/,/^},{/d" /etc/default/syncron/shadowsocks2022.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/shadowsocks2022.json
rm -rf /var/www/html/shadowsocks2022/shadowsocks2022-$user.txt
rm -rf /user/log-shadowsocks-$user.txt
sed -i "/\b$user\b/d" /etc/shadowsocks2022/.shadowsocks2022.db
rm -rf /etc/shadowsocks2022/$user
rm -rf /etc/limit/shadowsocks2022/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
data=($(cat /etc/default/syncron/socks.json | grep '^#÷' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
exp=$(grep -w "^#÷ $user" "/etc/default/syncron/socks.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#÷ $user $exp/,/^},{/d" /etc/default/syncron/socks.json
sed -i "/^#&@ $user $exp/,/^},{/d" /etc/default/syncron/socks.json
rm -rf /var/www/html/socks5/socks5-$user.txt
rm -rf /user/log-socks5-$user.txt
sed -i "/\b$user\b/d" /etc/socks/.socks.db
rm -rf /etc/socks/$user
rm -rf /etc/limit/socks/$user
rm -rf /tmp/$user
rm -rf /var/www/html/allxray/allxray-$user.txt
rm -rf /user/log-allxray-$user.txt
sed -i "/\b$user\b/d" /etc/allxray/.allxray.db
rm -rf /etc/allxray/$user
rm -rf /etc/limit/allxray/$user
rm -rf /tmp/$user
fi
done
systemctl restart vipssh@vmess.service
systemctl restart vipssh@vless.service
systemctl restart vipssh@trojan.service
systemctl restart vipssh@socks.service
systemctl restart vipssh@shadowsocks.service
systemctl restart vipssh@shadowsocks2022.service
