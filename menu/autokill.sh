#!/bin/bash
colornow=$(cat /etc/vipssh/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
RB="\033[0;31m"
BB='\e[1;32m'
RED='\033[0;31m'
GREEN='\033[0;32m'
COLOR1="$(cat /etc/vipssh/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/vipssh/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
###########- END COLOR CODE -##########
apiFILE=$(cat /usr/bin/urlpanel)
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
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS"
clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
if systemctl is-active --quiet limitssh.service; then
    sts="${Info}"
else
    sts="${Error}"
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m          MULTILOGIN SSH          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Status MultiLogin : $sts"
echo -e ""
echo -e "[1]  MultiLogin SSH After Limit Delete Account"
echo -e "[2]  MultiLogin SSH After Limit Suspended Account"
echo -e "[3]  Turn Off Account/MultiLogin"
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p "Select From Options [1-4 or ctrl+c to exit] :  " AutoKill
if [ -z "$AutoKill" ]; then
    menussh
fi

if [[ "$AutoKill" == "3" ]]; then
    clear
    systemctl stop limitssh.service >> /dev/null 2>&1
    systemctl disable limitssh.service >> /dev/null 2>&1
    rm /etc/systemd/system/limitssh.service >> /dev/null 2>&1
    rm -rfv /usr/bin/limitsshdelete >> /dev/null 2>&1
    rm -rfv /usr/bin/limitsshlock >> /dev/null 2>&1
    echo -e ""
    echo -e "======================================"
    echo -e ""
    echo -e "       MULTILOGIN SSH TURNED OFF      "
    echo -e ""
    echo -e "======================================"
    read -p "Press Enter to continue..." continue
    menussh
fi

read -p "Multilogin Maximum Number Of Allowed: " max
echo -e ""

case "$AutoKill" in
    1)
        interval="Delete"
        systemctl stop limitssh.service >> /dev/null 2>&1
        systemctl disable limitssh.service >> /dev/null 2>&1
        rm /etc/systemd/system/limitssh.service >> /dev/null 2>&1
        rm -rfv /usr/bin/limitsshdelete >> /dev/null 2>&1
        rm -rfv /usr/bin/limitsshlock >> /dev/null 2>&1
        cat <<EOF > /etc/systemd/system/limitssh.service
[Unit]
Description=Limit IP SSH VPN Service
Documentation=createssh
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/limitsshdelete $max

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /usr/bin/limitsshdelete
#!/bin/bash

while true; do
  sleep 20

  # Set the PATH variable explicitly
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  MYIP=$(wget -qO- ipv4.icanhazip.com)
  clear
  MAX=10
  if [ -e "/var/log/auth.log" ]; then
      OS=1
      LOG="/var/log/auth.log"
  fi
  if [ -e "/var/log/secure" ]; then
      OS=2
      LOG="/var/log/secure"
  fi

  if [ $OS -eq 1 ]; then
      /usr/sbin/service ssh restart > /dev/null 2>&1
  fi
  if [ $OS -eq 2 ]; then
      /usr/sbin/service sshd restart > /dev/null 2>&1
  fi
  /usr/sbin/service dropbear restart > /dev/null 2>&1

  if [[ ${1+x} ]]; then
      MAX=$1
  fi

  # Ambil daftar nama pengguna dan inisialisasi jumlah koneksi menjadi nol
  username1=( $(cat /etc/passwd | grep "/home/" | cut -d":" -f1) )
  i=0
  for user in "${username1[@]}"
  do
      username[$i]=$(echo "$user" | sed "s/'//g")
      jumlah[$i]=0
      i=$((i+1))
  done

  # Ambil data log Dropbear dan hitung koneksi untuk setiap pengguna
  cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
  proc=( $(ps aux | grep -i dropbear | awk '{print $2}') )
  for PID in "${proc[@]}"
  do
      cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
      NUM=$(cat /tmp/log-db-pid.txt | wc -l)
      USER=$(cat /tmp/log-db-pid.txt | awk '{print $10}' | sed "s/'//g")
      IP=$(cat /tmp/log-db-pid.txt | awk '{print $12}')
      if [ $NUM -eq 1 ]; then
          i=0
          for user1 in "${username[@]}"
          do
              if [ "$USER" == "$user1" ]; then
                  jumlah[$i]=$(expr ${jumlah[$i]} + 1)
                  pid[$i]="${pid[$i]} $PID"
              fi
              i=$((i+1))
          done
      fi
  done

  # Ambil data log SSH dan hitung koneksi untuk setiap pengguna
  cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
  data=( $(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}') )
  for PID in "${data[@]}"
  do
      cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt
      NUM=$(cat /tmp/log-db-pid.txt | wc -l)
      USER=$(cat /tmp/log-db-pid.txt | awk '{print $9}')
      IP=$(cat /tmp/log-db-pid.txt | awk '{print $11}')
      if [ $NUM -eq 1 ]; then
          i=0
          for user1 in "${username[@]}"
          do
              if [ "$USER" == "$user1" ]; then
                  jumlah[$i]=$(expr ${jumlah[$i]} + 1)
                  pid[$i]="${pid[$i]} $PID"
              fi
              i=$((i+1))
          done
      fi
  done

  # Mengakhiri sesi pengguna yang melebihi batas maksimum koneksi
  j=0
  for i in ${!username[*]}
  do
      if [ ${jumlah[$i]} -gt $MAX ]; then
          date=$(date +"%Y-%m-%d %X")
          echo "$date - ${username[$i]} - ${jumlah[$i]}"
          echo "$date - ${username[$i]} - ${jumlah[$i]}" >> /root/log-limit.txt

          # Pastikan tidak ada sesi aktif yang terhubung ke pengguna
          for PID in ${pid[$i]}
          do
              kill $PID
          done

          # Delete pengguna dari sistem
          if [ ${jumlah[$i]} -gt $MAX ]; then
              userdel -r -f ${username[$i]}
              rm -rf /var/www/html/ssh/ssh-${username[$i]}.txt
              sed -i "/\b${username[$i]}\b/d" /usr/local/etc/xray/ssh.txt
              sed -i "/\b${username[$i]}\b/d" /etc/ssh/.ssh.db
              sed -i "/\b$date - ${username[$i]} - ${jumlah[$i]}\b/d" /root/log-limit.txt
              echo -n > /var/log/auth.log
          fi

          pid[$i]=""
          j=$((j+1))
      fi
  done

  # Restart layanan SSH dan Dropbear jika ada koneksi yang diakhiri
  if [ $j -gt 0 ]; then
      if [ $OS -eq 1 ]; then
          service ssh restart > /dev/null 2>&1
      fi
      if [ $OS -eq 2 ]; then
          service sshd restart > /dev/null 2>&1
      fi
      service dropbear restart > /dev/null 2>&1
      j=0
  fi
  done
EOF

chmod +x /usr/bin/limitsshdelete >> /dev/null 2>&1
dos2unix /usr/bin/limitsshdelete >> /dev/null 2>&1
shc -f /usr/bin/limitsshdelete >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshdelete >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshdelete.x.c >> /dev/null 2>&1
mv /usr/bin/limitsshdelete.x /usr/bin/limitsshdelete >> /dev/null 2>&1
wget -q -O /usr/bin/pausit "$apiFILE/api/files/encrypt/enc-gg" && chmod +x /usr/bin/pausit && pausit /usr/bin/limitsshdelete >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshdelete~ >> /dev/null 2>&1
rm -rfv /usr/bin/pausit >> /dev/null 2>&1
        ;;
    2)
        interval="Locked"
        systemctl stop limitssh.service >> /dev/null 2>&1
        systemctl disable limitssh.service >> /dev/null 2>&1
        rm /etc/systemd/system/limitssh.service >> /dev/null 2>&1
        rm -rfv /usr/bin/limitsshdelete >> /dev/null 2>&1
        rm -rfv /usr/bin/limitsshlock >> /dev/null 2>&1
        cat <<EOF > /etc/systemd/system/limitssh.service
[Unit]
Description=Limit IP SSH VPN Service
Documentation=ZenSSH
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/limitsshlock $max

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /usr/bin/limitsshlock
#!/bin/bash

while true; do
  sleep 20

  # Set the PATH variable explicitly
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  MYIP=$(wget -qO- ipv4.icanhazip.com)
  clear
  MAX=1
  if [ -e "/var/log/auth.log" ]; then
      OS=1
      LOG="/var/log/auth.log"
  fi
  if [ -e "/var/log/secure" ]; then
      OS=2
      LOG="/var/log/secure"
  fi

  if [ $OS -eq 1 ]; then
      /usr/sbin/service ssh restart > /dev/null 2>&1
  fi
  if [ $OS -eq 2 ]; then
      /usr/sbin/service sshd restart > /dev/null 2>&1
  fi
  /usr/sbin/service dropbear restart > /dev/null 2>&1

  if [[ ${1+x} ]]; then
      MAX=$1
  fi

  # Ambil daftar nama pengguna dan inisialisasi jumlah koneksi menjadi nol
  username1=( $(cat /etc/passwd | grep "/home/" | cut -d":" -f1) )
  i=0
  for user in "${username1[@]}"
  do
      username[$i]=$(echo "$user" | sed "s/'//g")
      jumlah[$i]=0
      i=$((i+1))
  done

  # Ambil data log Dropbear dan hitung koneksi untuk setiap pengguna
  cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
  proc=( $(ps aux | grep -i dropbear | awk '{print $2}') )
  for PID in "${proc[@]}"
  do
      cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
      NUM=$(cat /tmp/log-db-pid.txt | wc -l)
      USER=$(cat /tmp/log-db-pid.txt | awk '{print $10}' | sed "s/'//g")
      IP=$(cat /tmp/log-db-pid.txt | awk '{print $12}')
      if [ $NUM -eq 1 ]; then
          i=0
          for user1 in "${username[@]}"
          do
              if [ "$USER" == "$user1" ]; then
                  jumlah[$i]=$(expr ${jumlah[$i]} + 1)
                  pid[$i]="${pid[$i]} $PID"
              fi
              i=$((i+1))
          done
      fi
  done

  # Ambil data log SSH dan hitung koneksi untuk setiap pengguna
  cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
  data=( $(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}') )
  for PID in "${data[@]}"
  do
      cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt
      NUM=$(cat /tmp/log-db-pid.txt | wc -l)
      USER=$(cat /tmp/log-db-pid.txt | awk '{print $9}')
      IP=$(cat /tmp/log-db-pid.txt | awk '{print $11}')
      if [ $NUM -eq 1 ]; then
          i=0
          for user1 in "${username[@]}"
          do
              if [ "$USER" == "$user1" ]; then
                  jumlah[$i]=$(expr ${jumlah[$i]} + 1)
                  pid[$i]="${pid[$i]} $PID"
              fi
              i=$((i+1))
          done
      fi
  done

  # Mengakhiri sesi pengguna yang melebihi batas maksimum koneksi
  j=0
  for i in ${!username[*]}
  do
      if [ ${jumlah[$i]} -gt $MAX ]; then
          date=$(date +"%Y-%m-%d %X")
          echo "$date - ${username[$i]} - ${jumlah[$i]}"
          echo "$date - ${username[$i]} - ${jumlah[$i]}" >> /root/log-limit.txt

          # Pastikan tidak ada sesi aktif yang terhubung ke pengguna
          for PID in ${pid[$i]}
          do
              kill $PID
          done

          # Lock pengguna dari sistem
          if [ ${jumlah[$i]} -gt $MAX ]; then
              passwd -l ${username[$i]}
              echo -n > /var/log/auth.log
         curl -X POST -H "Content-Type: application/json" \
            -d "{\"usernames\": [\"${username[$i]}\"]}" \
            https://panel.zenssh.com/api/permission/update/suspend
          fi

          pid[$i]=""
          j=$((j+1))
      fi
  done

  # Restart layanan SSH dan Dropbear jika ada koneksi yang diakhiri
  if [ $j -gt 0 ]; then
      if [ $OS -eq 1 ]; then
          service ssh restart > /dev/null 2>&1
      fi
      if [ $OS -eq 2 ]; then
          service sshd restart > /dev/null 2>&1
      fi
      service dropbear restart > /dev/null 2>&1
      j=0
  fi
  done
EOF

chmod +x /usr/bin/limitsshlock >> /dev/null 2>&1
dos2unix /usr/bin/limitsshlock >> /dev/null 2>&1
shc -f /usr/bin/limitsshlock >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshlock >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshlock.x.c >> /dev/null 2>&1
mv /usr/bin/limitsshlock.x /usr/bin/limitsshlock >> /dev/null 2>&1
wget -q -O /usr/bin/pausit "$apiFILE/api/files/encrypt/enc-gg" && chmod +x /usr/bin/pausit && pausit /usr/bin/limitsshlock >> /dev/null 2>&1
rm -rfv /usr/bin/limitsshlock~ >> /dev/null 2>&1
rm -rfv /usr/bin/pausit >> /dev/null 2>&1
        ;;
    *)
        echo -e "Invalid Option. Exiting..."
        exit
        ;;
esac

clear
echo -e ""
echo -e "======================================"
echo -e ""
echo -e "      Allowed MultiLogin : $max"
echo -e "      Max Login User     : $interval"
echo -e ""
echo -e "======================================"
systemctl daemon-reload
systemctl enable limitssh.service >> /dev/null 2>&1
systemctl start limitssh.service >> /dev/null 2>&1
systemctl restart limitssh.service >> /dev/null 2>&1

read -p "Press Enter to continue..." continue
menussh
