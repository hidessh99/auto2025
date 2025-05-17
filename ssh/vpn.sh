#!/bin/bash
# Fatsnet Server
# ==================================================
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(curl -s https://checkip.amazonaws.com/);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');
apiFILE=$(cat /usr/bin/urlpanel)
# Install OpenVPN dan Easy-RSA
apt install openvpn easy-rsa unzip -y
apt install openssl iptables iptables-persistent -y
rm -rfv /etc/openvpn/server/easy-rsa/
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
wget --quiet $apiFILE/api/files/ssh/vpn.zip
unzip vpn.zip
rm -f vpn.zip
chown -R root:root /etc/openvpn/server/easy-rsa/

cd
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so

# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# restart openvpn dan cek status openvpn
systemctl enable --now openvpn-server@server-tcp-1194
systemctl enable --now openvpn-server@server-udp-25000
/etc/init.d/openvpn restart
/etc/init.d/openvpn status

# aktifkan ip4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Buat config client TCP 1194
cat > /etc/openvpn/client-tcp-1194.ovpn <<-END
client
dev tun
proto tcp
sndbuf 0
rcvbuf 0
remote xxxxxxxxx 1194
resolv-retry 5
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo yes
setenv opt block-outside-dns
key-direction 1
verb 3
auth-user-pass
keepalive 10 120
float
END

sed -i $MYIP2 /etc/openvpn/client-tcp-1194.ovpn;

# # Buat config client UDP 25000
cat > /etc/openvpn/client-udp-25000.ovpn <<-END
client
dev tun
proto udp
sndbuf 0
rcvbuf 0
remote xxxxxxxxx 25000
resolv-retry 5
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo yes
setenv opt block-outside-dns
key-direction 1
verb 3
auth-user-pass
keepalive 10 120
float
END

sed -i $MYIP2 /etc/openvpn/client-udp-25000.ovpn;

# # Buat config client SSL
cat > /etc/openvpn/client-ohp.ovpn <<-END
# THANKS TO CREATESSH.ORG AND GITSSH.COM
# Experimental Config only
# Examples demonstrated below on how to Play with OHPServer
client
dev tun
proto tcp
sndbuf 0
rcvbuf 0
# We can also play with CRLFs
# Working Port 443, 80, 1194
remote bug.com 1194
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy xxxxxxxxx 9088
port 443
resolv-retry 5
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo yes
setenv opt block-outside-dns
key-direction 1
verb 3
auth-user-pass
keepalive 10 120
float
END

sed -i $MYIP2 /etc/openvpn/client-ohp.ovpn;

cd
# pada tulisan xxx ganti dengan alamat ip address VPS anda
/etc/init.d/openvpn restart

# masukkan Ca ke dalam config client TCP 1194
echo '<ca>' >> /etc/openvpn/client-tcp-1194.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-tcp-1194.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp-1194.ovpn

# masukkan Crt ke dalam config client TCP 1194
echo '<cert>' >> /etc/openvpn/client-tcp-1194.ovpn
cat /etc/openvpn/server/easy-rsa/pki/issued/client.crt >> /etc/openvpn/client-tcp-1194.ovpn
echo '</cert>' >> /etc/openvpn/client-tcp-1194.ovpn

# masukkan Key ke dalam config client TCP 1194
echo '<key>' >> /etc/openvpn/client-tcp-1194.ovpn
cat /etc/openvpn/server/easy-rsa/pki/private/client.key >> /etc/openvpn/client-tcp-1194.ovpn
echo '</key>' >> /etc/openvpn/client-tcp-1194.ovpn

# masukkan Tls-Auth ke dalam config client TCP 1194
echo '<tls-crypt>' >> /etc/openvpn/client-tcp-1194.ovpn
cat /etc/openvpn/server/tc.key >> /etc/openvpn/client-tcp-1194.ovpn
echo '</tls-crypt>' >> /etc/openvpn/client-tcp-1194.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( TCP 1194 )
cp /etc/openvpn/client-tcp-1194.ovpn /var/www/html/tcp.ovpn

# # masukkan certificatenya ke dalam config client UDP 25000
echo '<ca>' >> /etc/openvpn/client-udp-25000.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-udp-25000.ovpn
echo '</ca>' >> /etc/openvpn/client-udp-25000.ovpn

# masukkan Crt ke dalam config client udp 25000
echo '<cert>' >> /etc/openvpn/client-udp-25000.ovpn
cat /etc/openvpn/server/easy-rsa/pki/issued/client.crt >> /etc/openvpn/client-udp-25000.ovpn
echo '</cert>' >> /etc/openvpn/client-udp-25000.ovpn

# masukkan Key ke dalam config client udp 25000
echo '<key>' >> /etc/openvpn/client-udp-25000.ovpn
cat /etc/openvpn/server/easy-rsa/pki/private/client.key >> /etc/openvpn/client-udp-25000.ovpn
echo '</key>' >> /etc/openvpn/client-udp-25000.ovpn

# masukkan Tls-Auth ke dalam config client udp 25000
echo '<tls-crypt>' >> /etc/openvpn/client-udp-25000.ovpn
cat /etc/openvpn/server/tc.key >> /etc/openvpn/client-udp-25000.ovpn
echo '</tls-crypt>' >> /etc/openvpn/client-udp-25000.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( udp 25000 )
cp /etc/openvpn/client-udp-25000.ovpn /var/www/html/udp.ovpn


# # masukkan certificatenya ke dalam config client ohp
echo '<ca>' >> /etc/openvpn/client-ohp.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-ohp.ovpn
echo '</ca>' >> /etc/openvpn/client-ohp.ovpn

# masukkan Crt ke dalam config client TLS ohp
echo '<cert>' >> /etc/openvpn/client-ohp.ovpn
cat /etc/openvpn/server/easy-rsa/pki/issued/client.crt >> /etc/openvpn/client-ohp.ovpn
echo '</cert>' >> /etc/openvpn/client-ohp.ovpn

# masukkan Key ke dalam config clientTLS ohp
echo '<key>' >> /etc/openvpn/client-ohp.ovpn
cat /etc/openvpn/server/easy-rsa/pki/private/client.key >> /etc/openvpn/client-ohp.ovpn
echo '</key>' >> /etc/openvpn/client-ohp.ovpn

# masukkan Tls-Auth ke dalam config client TLS ohp
echo '<tls-crypt>' >> /etc/openvpn/client-ohp.ovpn
cat /etc/openvpn/server/tc.key >> /etc/openvpn/client-ohp.ovpn
echo '</tls-crypt>' >> /etc/openvpn/client-ohp.ovpn

# # Copy config OpenVPN client ke home directory root agar mudah didownload
cp /etc/openvpn/client-ohp.ovpn /var/www/html/ohp.ovpn

cd /var/www/html/
zip openvpn-config.zip tcp.ovpn udp.ovpn ohp.ovpn > /dev/null 2>&1
cd

#firewall untuk memperbolehkan akses UDP dan akses jalur TCP

iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i eth0 -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o eth0 -j ACCEPT
iptables -I INPUT 1 -i eth0 -p tcp --dport 1194 -j ACCEPT
iptables-save > /etc/iptables/rules.v4 >> /dev/null 2>&1
iptables-save > /etc/iptables.up.rules >> /dev/null 2>&1
netfilter-persistent save >> /dev/null 2>&1
netfilter-persistent reload >> /dev/null 2>&1

# Restart service openvpn
systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

# Delete script
rm -f /root/vpn.sh
