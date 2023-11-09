#!/bin/bash
sudo cp hosts.roblox.enabled /etc/hosts
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
