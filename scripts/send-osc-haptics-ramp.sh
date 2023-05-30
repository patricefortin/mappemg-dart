#!/bin/bash

SLEEP_TIME=0.01
LOCAL_PORT=2222
AMPLITUDE_FROM=1
AMPLITUDE_TO=150
AMPLITUDE_INCREMENT=4

seq $AMPLITUDE_FROM $AMPLITUDE_INCREMENT $AMPLITUDE_TO | while read amplitude; do 
  cmd="send_osc $LOCAL_PORT /haptics 1 $amplitude"
  echo "[+] Sending $cmd"
  $cmd
  sleep $SLEEP_TIME
done


seq $AMPLITUDE_FROM $AMPLITUDE_INCREMENT $AMPLITUDE_TO | tac | while read amplitude; do 
  cmd="send_osc $LOCAL_PORT /haptics 1 $amplitude"
  echo "[+] Sending $cmd"
  $cmd
  sleep $SLEEP_TIME
done


