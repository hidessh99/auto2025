#!/bin/bash
  while true; do
  sleep 30
  data=($(cat /etc/default/syncron/vmess.json | grep '^#@' | cut -d ' ' -f 2 | sort | uniq))
  if [[ ! -e /etc/limit/vmess ]]; then
  mkdir -p /etc/limit/vmess
  fi
  for user in ${data[@]}
  do
  xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" >& /tmp/${user}
  getThis=$(cat /tmp/${user} | awk '{print $1}');
  if [[ ${getThis} != "failed" ]]; then
        downlink=$(xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" | grep -w "value" | awk '{print $2}' | cut -d '"' -f2);
        if [ -e /etc/limit/vmess/${user} ]; then
        plus2=$(cat /etc/limit/vmess/${user});
        if [[ ${#plus2} -gt 0 ]]; then
        plus3=$(( ${downlink} + ${plus2} ));
        echo "${plus3}" > /etc/limit/vmess/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        else
        echo "${downlink}" > /etc/limit/vmess/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        fi
        else
        echo "${downlink}" > /etc/limit/vmess/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        fi
        else
      echo ""
   fi
done
# Check ur Account
for user in ${data[@]}
  do
    if [ -e /etc/vmess/${user} ]; then
      checkLimit=$(cat /etc/vmess/${user});
      if [[ ${#checkLimit} -gt 1 ]]; then
      if [ -e /etc/limit/vmess/${user} ]; then
      Usage=$(cat /etc/limit/vmess/${user});
      if [[ ${Usage} -gt ${checkLimit} ]]; then
      exp=$(grep -w "^#@ $user" "/etc/default/syncron/vmess.json" | cut -d ' ' -f 3 | sort | uniq)
      sed -i "/\b$user\b/d" /etc/vmess/.vmess.db
      sed -i "/^#@ $user $exp/,/^},{/d" /etc/default/syncron/vmess.json
      rm -rf /etc/vmess/$user
      rm -rf /etc/limit/vmess/$user
      rm -rf /tmp/$user
      systemctl restart xray >> /dev/null 2>&1
      else
      echo ""
      fi
      else
      echo ""
      fi
      else
      echo ""
      fi
      else
      echo ""
    fi
  done
done
