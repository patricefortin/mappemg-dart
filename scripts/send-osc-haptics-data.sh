#!/bin/bash

LOCAL_PORT=2222
SLEEP_TIME=0.01

cat ../data-vibration-test.csv | cut -f1 -d'.' | tail -n 2000 | while read amplitude; do 
  cmd="send_osc $LOCAL_PORT /haptics 1 $amplitude"
  echo "[+] Sending $cmd"
  $cmd
  sleep $SLEEP_TIME
done


