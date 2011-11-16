#!/bin/bash

sed -i '
    1,/^nameserver/i\
domain internal\
nameserver 192.168.16.91
' /etc/resolv.conf
