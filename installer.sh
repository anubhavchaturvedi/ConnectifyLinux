#!/bin/bash

if [ $(whoami) != "root" ];
then
	echo "Root access is required.";
	echo "Command Usage : sudo installer.sh";
	exit 1;
fi


echo "Checking if the wireless driver is supported ....";

wireless_driver=`lspci -k | grep -A 3 -i network | grep -oP "(ath5k|ath9k|ath9k_htc|b43|b43legacy|brcmsmac|carl9170|libertas_tf|mac80211_hwsim|mwl8k|p54pci|p54spi|p54usb|rt61pci|rt73usb|rt2400pci|rt2500pci|rt2500usb|rt2800pci|rt2800usb|wil6210|wl12xx|zd1211rw)"`;

echo "Driver Found : $wireless_driver"; 
if [ "$wireless_driver" == "" ];
then
	echo "Unsupported Driver.";
	echo "Aborting.";
	exit 1;
fi

echo "Driver Supported ....";


echo "Checking presence of required packages ....";
flag=0
command -v hostapd >/dev/null 2>&1 || { echo >&2 "Error : Hostapd is not installed. Please use sudo apt-get install hostapd."; flag=$(($flag+1)); };
command -v dnsmasq >/dev/null 2>&1 || { echo >&2 "Error : Hostapd is not installed. Please use sudo apt-get install dnsmasq."; flag=$(($flag+2)); };

if [ $flag != 0 ];
then
	echo "Would you like to install the required packages? Internet connection is required. [Y/n]  ";
	read confirmation;
	if [ $confirmation == 'y' || $confirmation == 'Y' ];
	then
		if [ $flag == 1 ];
		then
			apt-get install hostapd;
		elif [ $flag == 2 ];
		then
			apt-get install dnsmasq;
		else
			apt-get install hostapd dnsmasq;
		fi
	else
		echo "Aborting ... ";
		exit 1;
	fi
fi


echo "start process";

echo "Configuring dnsmasq : /etc/dnsmasq.conf";
cp ./dnsmasq.conf /etc/dnsmasq.conf
cp ./hostapd-basic.conf /etc/hostapd/hostapd.conf

cp ./connectifyLinux.sh /usr/bin/connectifyLinux
chmod 755 /usr/bin/connectifyLinux




