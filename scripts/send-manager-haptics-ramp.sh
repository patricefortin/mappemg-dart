#!/bin/bash

SLEEP_TIME=0.01
LOCAL_PORT=1984
AMPLITUDE_FROM=0.1
AMPLITUDE_TO=1
AMPLITUDE_INCREMENT=0.01

seq $AMPLITUDE_FROM $AMPLITUDE_INCREMENT $AMPLITUDE_TO | while read amplitude; do 
  cmd="send_osc $LOCAL_PORT /channel/haptics 1 $amplitude"
  echo "[+] Sending $cmd"
  $cmd
  sleep $SLEEP_TIME
done


