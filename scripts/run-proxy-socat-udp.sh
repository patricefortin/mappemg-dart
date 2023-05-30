#!/bin/bash

SELECTED_TARGET_NAME="TARGET_HOST_S8_FELIPE"

TARGET_HOST_S8=10.57.230.216 # my samsung s8
TARGET_HOST_NEXUS=10.57.225.65 # nexus
#TARGET_HOST_S8_FELIPE=10.57.231.225 # Felipe samsung s8
#TARGET_HOST_S8_FELIPE=10.57.231.152 # Felipe samsung s8
TARGET_HOST_S8_FELIPE=10.57.230.127 # Felipe samsung s8
TARGET_HOST_S8_FELIPE_MOBILE=192.168.43.62 # Felipe samsung s8
TARGET_HOST_IPHONE_FELIPE=10.41.231.79 # Felipe iPhone

TARGET_HOST_HOME_S8=192.168.18.2 # Home setup - Nokia wifi - my samsung s8
TARGET_HOST_HOME_S8_FELIPE=192.168.18.10 # Home setup - Nokia wifi - my samsung s8

TARGET_HOST=${!SELECTED_TARGET_NAME}

LOCAL_PORT=2222
TARGET_PORT=2222

Help()
{
   # Display Help
   echo "$0 <address> [-p port]"
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "-h     Print this Help."
   echo "-p     Which port to proxy"
   echo "-t     Which address target to send to"
   echo
}

while getopts ":hp:t:" option; do
   case $option in
      h) # display Help
        Help
        exit;;
      p) # port
        LOCAL_PORT=${OPTARG}
        TARGET_PORT=${OPTARG};;
      t) # address
        TARGET_HOST=${OPTARG};;
   esac
done

echo "[*] Sending to $TARGET_HOST:$TARGET_PORT ($TARGET_NAME)"
echo "[*] Try: send_osc $LOCAL_PORT /haptics 1 100"

socat -d udp4-recvfrom:$LOCAL_PORT,fork udp4-sendto:$TARGET_HOST:$TARGET_PORT
