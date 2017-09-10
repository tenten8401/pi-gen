#!/bin/bash

RND=$(( RANDOM % 8999 + 1000 ))
sed -i -e "s/RPiKit-AP/RPiKit$RND-AP/g" /etc/hostapd/hostapd.conf

sed -i '/randomize.sh/d' /etc/rc.local

rm $0

reboot
