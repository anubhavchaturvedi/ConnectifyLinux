#!/bin/bash

from_if=$1
to_if=$2
if [ "$from_if" == "" ]
then
        from_if="wlan0"
fi
if [ "$to_if" == "" ]
then
        to_if="eth0"
fi

#Initial wifi interface configuration
ifconfig $from_if up 192.168.1.1 netmask 255.255.255.0
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
iptables --table nat --append POSTROUTING --out-interface $to_if -j MASQUERADE
iptables --append FORWARD --in-interface $from_if -j ACCEPT
 
#Thanks to lorenzo
#Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
sysctl -w net.ipv4.ip_forward=1
 
#start hostapd
echo "STARTING HOSTAPD"
hostapd /home/anubhav/hostapd-test.conf
killall dnsmasq
echo "killall dnsmasq executed"
