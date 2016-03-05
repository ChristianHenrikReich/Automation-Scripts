#!/bin/bash
# Script for handling installing of wget

echo "Checking for wget"

if [yum -q list installed packageX &>/dev/null]; then
	echo "removing package"
fi

echo "Installing wget"

