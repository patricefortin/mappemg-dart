#!/bin/bash

#seq 128 255 | while read n; do send_osc 2222 /color 1 00ff$(printf "%02x" $n); sleep 0.01; done
seq 0 5 255 | while read n; do VALUE=$(printf "%02x" $n); send_osc 2222 /color 1 $VALUE$VALUE$VALUE; sleep 0.01; done
seq 0 5 255 | tac | while read n; do VALUE=$(printf "%02x" $n); send_osc 2222 /color 1 $VALUE$VALUE$VALUE; sleep 0.01; done


