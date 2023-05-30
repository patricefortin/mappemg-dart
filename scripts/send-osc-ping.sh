#!/bin/bash

SLEEP_TIME=0.01
LOCAL_PORT=2222
COUNT=10

seq $COUNT | while read i; do 
  cmd="send_osc $LOCAL_PORT /ping 1 $i"
  echo "[+] Sending $cmd"
  $cmd
  sleep $SLEEP_TIME
done
