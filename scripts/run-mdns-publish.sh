#!/bin/bash 

PORT=2222

avahi-publish --service my-service _medianode._udp $PORT
