# golang-rest-api

Rest API untuk ssh, trojan websocket, trojan gRPC, vmess websocket, vmess gRPC, vless websocket, vless gRPC, shadowsocks websocket, shadowsocks gRPC, Socks5 Websocket, Socks5 gRPC, Shadowsocks 2022 Websocket, Shadowsocks 2022 gRPC Bandwidth

original script by Adipati Arya
<br>
remark by xYuki CreateSSH.net & GuGun x Nanda Gunawan

<li>How to build Tunnapi</li>
<pre><code>go build -ldflags="-s -w" -o restapi ./src</code></pre>
<pre><code>shasum -a 256 ./src/main.go | awk '{print $1}'</code></pre>
