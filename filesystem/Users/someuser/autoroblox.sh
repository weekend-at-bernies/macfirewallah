#!/bin/bash
#
# This is the roblox on/off script.
# You set the hour when you want to enable roblox (TIMEOFF_H).
# Then set the hour and minute when you want to disable it (TIMEON_H/M).
# The "launch daemon" /Library/LaunchDaemons/sdx.simple.exampleofPLIST.plist will
# run this script (as root) every 15 minutes, determining whether to enable/disable.
#
DEBUG=1
DRYRUN=0
# ROBLOX IS ALLOWED FROM THIS TIME:
# WARNING: don't use the '0X' form to specify single digit time.    
# Ie. to specify 8am, DON'T write "08". Instead write: "8".
TIMEOFF_H=10

HOSTS_ROBLOX_ENABLED="/Users/imranali/hosts.roblox.enabled"
HOSTS_ROBLOX_DISABLED="/Users/imranali/hosts.roblox.disabled"

WHOAMI=`whoami`
if [[ "$WHOAMI" != "root" ]] ; then
  echo "Error: can only be run as root"
  exit
fi

CURR_HOSTS=`cat /etc/hosts`
if echo "$CURR_HOSTS" | grep 'www.roblox.com'; then
  ROBLOX_ENABLED=0
else
  ROBLOX_ENABLED=1
fi
DNS_FLUSH=0

# Day: Mon Tue Wed Thu Fri Sat Sun
D=$(date +%a)

if [[ "$D" == "Fri" ]] ; then 
  # When to disable Roblox on Fridays
  TIMEON_H=22
  TIMEON_M=30
elif [[ "$D" == "Sat" ]] ; then
  # When to disable Roblox on Saturdays
  TIMEON_H=22                                        
  TIMEON_M=30
elif [[ "$D" == "Sun" ]] ; then
  # When to disable Roblox on Sundays
  TIMEON_H=18                                        
  TIMEON_M=00
else
  # AND OTHER DAYS
  TIMEON_H=10
  TIMEON_M=05
fi

# Hour
H=$(date +%H)
# Minute
M=$(date +%M)
CURRENTDATE=`date +"%c"`
if (( $TIMEOFF_H <= 10#$H && 10#$H < $TIMEON_H )); then 
  if [[ "$DEBUG" == "1" ]] ; then
    echo "${CURRENTDATE}: roblox should be enabled"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    exit
  fi
  if [[ "$ROBLOX_ENABLED" == "0" ]] ; then
    cp $HOSTS_ROBLOX_ENABLED /etc/hosts
    DNS_FLUSH=1
  fi
elif (( 10#$H == $TIMEON_H )); then
  if (( 10#$M < $TIMEON_M )); then
    if [[ "$DEBUG" == "1" ]] ; then
      echo "${CURRENTDATE}: roblox should be enabled"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      exit
    fi
    if [[ "$ROBLOX_ENABLED" == "0" ]] ; then
      cp $HOSTS_ROBLOX_ENABLED /etc/hosts
      DNS_FLUSH=1
    fi
  else
    if [[ "$DEBUG" == "1" ]] ; then
      echo "${CURRENTDATE}: roblox should be disabled"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      exit
    fi
    if [[ "$ROBLOX_ENABLED" == "1" ]] ; then
      cp $HOSTS_ROBLOX_DISABLED /etc/hosts
      DNS_FLUSH=1
    fi
  fi
else
  if [[ "$DEBUG" == "1" ]] ; then
    echo "${CURRENTDATE}: roblox should be disabled"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    exit
  fi
  if [[ "$ROBLOX_ENABLED" == "1" ]] ; then
    cp $HOSTS_ROBLOX_DISABLED /etc/hosts
    DNS_FLUSH=1
  fi
fi
# https://superuser.com/questions/346518/how-do-i-refresh-the-hosts-file-on-os-x
if [[ "$DNS_FLUSH" == "1" ]] ; then
  /usr/bin/dscacheutil -flushcache; /usr/bin/killall -HUP mDNSResponder
fi
