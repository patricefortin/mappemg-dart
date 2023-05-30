#!/bin/bash

PORT=2221

echo "[+] Listening on port $PORT for application connection"
nc -l $PORT -v -k

