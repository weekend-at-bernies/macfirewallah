#!/bin/bash
#
# This is the total internet firewall on/off script.
# You set the hour when you want it to turn off (TIMEOFF_H).
# Then set the hour and minute when you want it to turn on (TIMEON_H/M).
# The "launch daemon" /Library/LaunchDaemons/sdm.simple.exampleofPLIST.plist will
# run this script (as root) every 15 minutes, determining whether to turn firewall on/off.
#
DEBUG=1
DRYRUN=0
TIMEOFF_H=06

WHOAMI=`whoami`
if [[ "$WHOAMI" != "root" ]] ; then
  echo "Error: can only be run as root"
  exit
fi

FW_STATUS_STR=`/sbin/pfctl -s info`
if echo "$FW_STATUS_STR" | grep 'Status: Enabled'; then
  FW_ENABLED=1
else
  FW_ENABLED=0
fi

# Day: Mon Tue Wed Thu Fri Sat Sun
D=$(date +%a)

if [[ "$D" == "Fri" || "$D" == "Sat" ]] ; then 
  #echo "$D"
  # THIS IS WHEN YOU WANT FIREWALL TO COME ON FRI/SAT
  TIMEON_H=22
  TIMEON_M=00
else
  # AND OTHER DAYS
  TIMEON_H=22
  TIMEON_M=00
fi

# Hour
H=$(date +%H)
# Minute
M=$(date +%M)
CURRENTDATE=`date +"%c"`
if (( $TIMEOFF_H <= 10#$H && 10#$H < $TIMEON_H )); then 
  # For example, between 0600 and 2300, disable firewall:
  if [[ "$DEBUG" == "1" ]] ; then
    echo "${CURRENTDATE}: firewall should be disabled"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    exit
  fi
  if [[ "$FW_ENABLED" == "1" ]] ; then
    /sbin/pfctl -d    
  fi
elif (( 10#$H == $TIMEON_H )); then
  if (( 10#$M < $TIMEON_M )); then
    if [[ "$DEBUG" == "1" ]] ; then
      echo "${CURRENTDATE}: firewall should be disabled"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      exit
    fi
    if [[ "$FW_ENABLED" == "1" ]] ; then
      /sbin/pfctl -d
    fi
  else
    if [[ "$DEBUG" == "1" ]] ; then
      echo "${CURRENTDATE}: firewall should be enabled"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      exit
    fi
    if [[ "$FW_ENABLED" == "0" ]] ; then
      /sbin/pfctl -f /Users/imranali/myfirewall.conf
      /sbin/pfctl -e
    fi
  fi
else
  if [[ "$DEBUG" == "1" ]] ; then
    echo "${CURRENTDATE}: firewall should be enabled"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    exit
  fi
  if [[ "$FW_ENABLED" == "0" ]] ; then
    /sbin/pfctl -f /Users/imranali/myfirewall.conf
    /sbin/pfctl -e
  fi
fi

