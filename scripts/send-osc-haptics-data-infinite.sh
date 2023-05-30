#!/bin/bash

SCRIPT="../send-osc-haptics-data.sh"

echo "[*] Running $SCRIPT in infinite loop"

yes | while read i; do
  ./send-osc-haptics-data.sh
  echo "[*] End of script, let's do it again"
done


