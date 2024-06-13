#!/bin/bash
#
# This is the domains enable/disable script.
# You set the hour when you want to enable domains (ENABLETIME_H).
# Then set the hour and minute when you want to disable disable (DISABLETIME_H/M).
# The "launch daemon" /Library/LaunchDaemons/sdx.simple.exampleofPLIST.plist will
# run this script (as root) every 15 minutes (default), determining whether to 
# enable/disable your domains based on the current time.
#
DO_NOTHING=0
DEBUG=1
DRYRUN=1
# Domains are enabled from this time:
ENABLETIME_H=10
# WARNING: don't use the '0X' form to specify single digit time.    
# Ie. to specify 8am, DON'T write "08". Instead write: "8".

if [[ "$DO_NOTHING" == "1" ]] ; then
  exit
fi

# Add domains here:
domains=(
  "www.tiktok.com"
  "www.roblox.com"
  "www.instagram.com"
  "www.youtube.com/shorts"
  "discordapp.com"
  "discord.com"
#  "www.money.com"
)

# Don't specify file like this "./myfile.foo".
# Path has to be absolute.
# WARNING: coz this runs as root, $USER will resolve to "root"
ORG_HOSTS_FILE="/Users/imranali/hosts.org"
NEW_HOSTS_FILE="/Users/imranali/hosts.new"

echo "##" > $NEW_HOSTS_FILE
echo "# THIS IS A MODIFIED HOSTS FILE" >> $NEW_HOSTS_FILE
echo "# Host Database" >> $NEW_HOSTS_FILE
echo "#" >> $NEW_HOSTS_FILE 
echo "# localhost is used to configure the loopback interface" >> $NEW_HOSTS_FILE 
echo "# when the system is booting.  Do not change this entry." >> $NEW_HOSTS_FILE
echo "##" >> $NEW_HOSTS_FILE

i=2
for domain in "${domains[@]}"
do

#  FIXME: make sure i < 254!
#  echo "127.0.0.$i       $domain" >> $NEW_HOSTS_FILE

  echo "127.0.0.2       $domain" >> $NEW_HOSTS_FILE
  ((i++))
done

echo "127.0.0.1       localhost" >> $NEW_HOSTS_FILE
echo "255.255.255.255 broadcasthost" >> $NEW_HOSTS_FILE
echo "::1             localhost" >> $NEW_HOSTS_FILE


WHOAMI=`whoami`
if [[ "$WHOAMI" != "root" ]] ; then
  echo "Error: can only be run as root"
  exit
fi




CURR_HOSTS=`cat /etc/hosts`
if echo "$CURR_HOSTS" | grep 'THIS IS A MODIFIED HOSTS FILE'; then
  DOMAINS_CURRENTLY_ENABLED=0
else
  DOMAINS_CURRENTLY_ENABLED=1
fi
DNS_FLUSH=0

# Day: Mon Tue Wed Thu Fri Sat Sun
D=$(date +%a)

if [[ "$D" == "Fri" ]] ; then 
  # Specify when to disable domains on Fridays
  DISABLETIME_H=23
  DISABLETIME_M=00
elif [[ "$D" == "Sat" ]] ; then
  # Specify when to disable domains on Saturdays
  DISABLETIME_H=23                                        
  DISABLETIME_M=00
elif [[ "$D" == "Sun" ]] ; then
  # Specify when to disable domains on Sundays
  DISABLETIME_H=23                                        
  DISABLETIME_M=00
else
  # Specify when to disable domains on all other days
  DISABLETIME_H=23
  DISABLETIME_M=00
fi

# Hour
H=$(date +%H)
# Minute
M=$(date +%M)
CURRENTDATE=`date +"%c"`
if (( $ENABLETIME_H <= 10#$H && 10#$H < $DISABLETIME_H )); then 
  if [[ "$DEBUG" == "1" ]] ; then
    if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
      echo "${CURRENTDATE}: target domains are currently enabled"
    else
      echo "${CURRENTDATE}: target domains are currently disabled"
    fi
    echo "${CURRENTDATE}: target domains should be enabled at this time"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    echo "${CURRENTDATE}: dry run only! no action will be performed..."
    exit
  fi
  if [[ "$DOMAINS_CURRENTLY_ENABLED" == "0" ]] ; then
    cp $OLD_HOSTS_FILE /etc/hosts
    DNS_FLUSH=1
  fi
elif (( 10#$H == $DISABLETIME_H )); then
  if (( 10#$M < $DISABLETIME_M )); then
    if [[ "$DEBUG" == "1" ]] ; then
      if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
        echo "${CURRENTDATE}: target domains are currently enabled"
      else
        echo "${CURRENTDATE}: target domains are currently disabled"
      fi
      echo "${CURRENTDATE}: target domains should be enabled at this time"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      echo "${CURRENTDATE}: dry run only! no action will be performed..."
      exit
    fi
    if [[ "$DOMAINS_CURRENTLY_ENABLED" == "0" ]] ; then
      cp $OLD_HOSTS_FILE /etc/hosts
      DNS_FLUSH=1
    fi
  else
    if [[ "$DEBUG" == "1" ]] ; then
      if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
        echo "${CURRENTDATE}: target domains are currently enabled"
      else
        echo "${CURRENTDATE}: target domains are currently disabled"
      fi
      echo "${CURRENTDATE}: target domains should be disabled at this time"
    fi
    if [[ "$DRYRUN" == "1" ]] ; then
      echo "${CURRENTDATE}: dry run only! no action will be performed..."
      exit
    fi
    if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
      cp $NEW_HOSTS_FILE /etc/hosts
      DNS_FLUSH=1
    fi
  fi
else
  if [[ "$DEBUG" == "1" ]] ; then
    if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
      echo "${CURRENTDATE}: target domains are currently enabled"
    else
      echo "${CURRENTDATE}: target domains are currently disabled"
    fi
    echo "${CURRENTDATE}: target domains should be disabled at this time"
  fi
  if [[ "$DRYRUN" == "1" ]] ; then
    echo "${CURRENTDATE}: dry run only! no action will be performed..."
    exit
  fi
  if [[ "$DOMAINS_CURRENTLY_ENABLED" == "1" ]] ; then
    cp $NEW_HOSTS_FILE /etc/hosts
    DNS_FLUSH=1
  fi
fi
# https://superuser.com/questions/346518/how-do-i-refresh-the-hosts-file-on-os-x
if [[ "$DNS_FLUSH" == "1" ]] ; then
  /usr/bin/dscacheutil -flushcache; /usr/bin/killall -HUP mDNSResponder
fi
