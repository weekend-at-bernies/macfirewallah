#!/bin/bash
sudo cp hosts.org /etc/hosts
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
