#!/bin/bash
# Script for handling installing of wget

echo "Checking for wget"

if [ ! -f /usr/bin/wget ]; then
	yum -y install wget
else
	echo "Found, no action taken"
fi

echo "Fetching Microsoft Linux Integration Services"
wget -N https://github.com/ChristianHenrikReich/automation-scripts/raw/master/centos-minimal/lis4-0-11.tar.gz

echo "Unpacking Microsoft Linux Integration Services"
tar xvzf lis4-0-11.tar.gz

echo "Installing Microsoft Linux Integration Services"
cd lis4.0.11
./install.sh

echo "Please reboot, to make the changes take effect"

