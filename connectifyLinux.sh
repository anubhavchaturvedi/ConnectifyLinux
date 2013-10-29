#!/bin/bash

FROM_IF=$1
TO_IF=$2

if [ "$FROM_IF" == "" ]
then
        FROM_IF="eth0"
fi
if [ "$TO_IF" == "" ]
then
        TO_IF="wlan0"
fi

if [ $(whoami) != "root" ];
then
	echo "You need to be a root user in order to execute this command.";
	echo "Command Usage : sudo connectify <from interface> <to interface>";
	exit 1;
elif [ $FROM_IF == $TO_IF ];
then
	echo "Both the interfaces selected are same."
	echo "Command Usage : sudo connectify <from interface> <to interface>"
	exit 1;
fi


echo "Starting the WiFi ..... ";
rfkill unblock wlan;
sleep 5;


#Initial wifi interface configuration
ifconfig $TO_IF up 192.168.1.1 netmask 255.255.255.0
sleep 2
 
###########Start dnsmasq, modify if required##########
if [ -z "$(ps -e | grep dnsmasq)" ]
then
 dnsmasq
fi
###########
 
#Enable NAT
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $FROM_IF -j MASQUERADE
iptables --append FORWARD --in-interface $TO_IF -j ACCEPT
 
#Thanks to lorenzo
#Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
sysctl -w net.ipv4.ip_forward=1
 
#start hostapd
echo "STARTING HOSTAPD"
hostapd /etc/hostapd/hostapd.conf
killall dnsmasq
echo "killall dnsmasq executed"
rfkill block wlan;
