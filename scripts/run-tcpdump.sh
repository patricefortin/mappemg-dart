#!/bin/bash

PORT=1984

sudo tcpdump -i any udp and port $PORT

