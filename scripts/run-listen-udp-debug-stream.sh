#!/bin/bash

cd "$(dirname "$0")"

PORT=2223
FILE=../debug-stream-out.txt

socat -d udp4-listen:$PORT,fork,reuseaddr stdout | tee $FILE


