#!/bin/bash
RESULT=`sudo pfctl -s info`
if echo "$RESULT" | grep 'Status: Enabled'; then
  echo "Firewall is currently enabled"
else
  echo "Firewall is currently disabled"
fi

