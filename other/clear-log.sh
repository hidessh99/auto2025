#!/bin/bash

while true; do
  sleep 30
  echo -n > /var/log/xray/access.log

  data=($(find /var/log/ -name '*.log'))
  for log in "${data[@]}"; do
    if [[ "$log" != "/var/log/auth.log" ]]; then
      echo "$log clear"
      echo >$log
    fi
  done

  data=($(find /var/log/ -name '*.err'))
  for log in "${data[@]}"; do
    echo "$log clear"
    echo >$log
  done

  data=($(find /var/log/ -name 'mail.*'))
  for log in "${data[@]}"; do
    echo "$log clear"
    echo >$log
  done

  echo >/var/log/syslog
  echo >/var/log/btmp
  echo >/var/log/messages
  echo >/var/log/debug
done
