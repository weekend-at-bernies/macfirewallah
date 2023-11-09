#!/bin/bash
sudo cp hosts.roblox.disabled /etc/hosts
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
