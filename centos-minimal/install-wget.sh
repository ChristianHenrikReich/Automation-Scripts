#!/bin/bash
# Script for handling installing of wget

echo "Checking for wget"

if [ ! -f /usr/bin/wget ]; then
	yum -y install wget
else
	echo "Found, no action taken"
fi

