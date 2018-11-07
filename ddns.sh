#!/bin/bash

#env
CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
PARAM=$@
cd $CURDIR
source config

#func
log()
{
	echo "[$(date "+%m-%d %H:%M:%S")]$1:$2"
}
havepar()
{
	for arg in $PARAM
	do
		if [ $arg == $1 ]
		then
			echo -n "1"
			return 1
		fi
	done
	echo -n "0"
	return 0
}
LASIP="0.0.0.0"
send_notify()
{
	for notify in $NOTIFY_API
	do
		bash notify/$notify/main.sh "$1"
	done
}
work()
{
	IP=`bash ip/$IP_API/main.sh`
	if [ -z $IP ]
	then
		log ip "Failed to get IP"
		return 1
	fi
	if [ $LASIP == $IP ]
	then
		log ip "IP not change"
		return 0
	fi
	log ip "IP CHANGED:$LASIP->$IP"
	for dnsapi in $DNS_API
	do
		bash dns/$dnsapi/main.sh $PRIMARY_DOMAIN $SUBDOMAIN $IP
	done
	log ip "OK"
	send_notify "IP%20changed:%0A$LASIP->$IP"
	LASIP=$IP
}

#pre

PRIMARY_DOMAIN=`echo $DOMAIN | grep -o "[^.]\{1,\}\\.[^.]\{1,\}$"`
SUBDOMAIN=`echo $DOMAIN | sed "s/.[^.]\{1,\}\\.[^.]\{1,\}$//"`
if [ -z $SUBDOMAIN ]
then
	SUBDOMAIN=$PRIMARY_DOMAIN
fi

#main

if [ `havepar -d` == "1" ]
then
	work
	exit 0
fi
while true :
do
	work
	sleep 60s
done