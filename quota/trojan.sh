#!/bin/bash
  while true; do
  sleep 30
  data=($(cat /etc/default/syncron/trojan.json | grep '^#&' | cut -d ' ' -f 2 | sort | uniq))
  if [[ ! -e /etc/limit/trojan ]]; then
  mkdir -p /etc/limit/trojan
  fi
  for user in ${data[@]}
  do
  xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" >& /tmp/${user}
  getThis=$(cat /tmp/${user} | awk '{print $1}');
  if [[ ${getThis} != "failed" ]]; then
        downlink=$(xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" | grep -w "value" | awk '{print $2}' | cut -d '"' -f2);
        if [ -e /etc/limit/trojan/${user} ]; then
        plus2=$(cat /etc/limit/trojan/${user});
        if [[ ${#plus2} -gt 0 ]]; then
        plus3=$(( ${downlink} + ${plus2} ));
        echo "${plus3}" > /etc/limit/trojan/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        else
        echo "${downlink}" > /etc/limit/trojan/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        fi
        else
        echo "${downlink}" > /etc/limit/trojan/"${user}"
        xray api stats --server=127.0.0.1:10000 -name "user>>>${user}>>>traffic>>>downlink" -reset > /dev/null 2>&1
        fi
        else
      echo ""
   fi
done
# Check ur Account
for user in ${data[@]}
  do
    if [ -e /etc/trojan/${user} ]; then
      checkLimit=$(cat /etc/trojan/${user});
      if [[ ${#checkLimit} -gt 1 ]]; then
      if [ -e /etc/limit/trojan/${user} ]; then
      Usage=$(cat /etc/limit/trojan/${user});
      if [[ ${Usage} -gt ${checkLimit} ]]; then
      exp=$(grep -w "^#& $user" "/etc/default/syncron/trojan.json" | cut -d ' ' -f 3 | sort | uniq)
      sed -i "/\b$user\b/d" /etc/trojan/.trojan.db
      sed -i "/^#& $user $exp/,/^},{/d" /etc/default/syncron/trojan.json
      rm -rf /etc/trojan/$user
      rm -rf /etc/limit/trojan/$user
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
