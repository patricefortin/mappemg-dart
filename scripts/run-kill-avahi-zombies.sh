#!/bin/bash

kill $(ps -ef | grep avahi-publish | grep -v grep | awk '{print $2}')


