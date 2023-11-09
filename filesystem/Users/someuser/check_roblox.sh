#!/bin/bash
RESULT=`cat /etc/hosts`
if echo "$RESULT" | grep 'www.roblox.com'; then
  echo "Roblox is currently disabled"
else
  echo "Roblox is currently enabled"
fi

