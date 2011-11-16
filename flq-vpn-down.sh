#!/bin/bash

sed -i '/nameserver 192.168.16.91\|domain internal/d' /etc/resolv.conf
