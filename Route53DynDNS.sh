o#!/bin/bash
#########################################################
# This script updates amazon Route 53 records with      #
# your dynamic IP address. This script relies upon      #
# cli53 and ipcalc.  cli53 can be downloaded from:      #
#                                                       #
# https://github.com/barnybug/cli53.git                 #
#                                                       #
# All loggin is done via logger to:                     #
# CentOS: /var/log/messages                             #
# Debian: /var/log/syslog                               #
#                                                       #
# Written by: Robbie Reese                              #
# Changes:                                              #
# v0.1      - 01/25/2014   - Inital Release             #
#########################################################
_cli53="/usr/bin/cli53"
_GetExternalIP=$(/usr/bin/curl --silent curlmyip.com)
_ttl="300"
_Domain="computerglitch.net"
_Host="imgsrvr"

#Verify we can access cli53
if [[ ! -f $_cli53 ]]; then
    echo "DynDNS ERROR: Can't locate cli53!"
    exit 1
fi
#Verify we have created a ~/.boto file with aws credentials
if [[ ! -f ~/.boto ]]; then
    echo "DynDNS ERROR: Create a .boto file with your AWS credentials in it. Refer to the cli53 Installation instructions."
    exit 1
fi
#Verify _GetExternalIP contanis information
if [[ -z "$_GetExternalIP" ]]; then
    /usr/bin/logger -p alert "DynDNS ERROR: dyndns.sh GetExternalIP variable is empty! IP not updated!"
    exit 1
#Verify _GetExternalIP contains a valid IP address
elif [[ ! -z "$_GetExternalIP" ]]; then
    _VerifyIP=$(/bin/ipcalc -s -c -4 $_GetExternalIP)
    if [[ $? == 1 ]]; then
        /usr/bin/logger -p alert "DynDNS ERROR: dyndns.sh was unable to get a valid IP address! IP not updated!"
        exit 1
    else
        $_cli53 rrcreate --replace --ttl $_ttl $_Domain $_Host A $_GetExternalIP
        /usr/bin/logger -p alert "DynDNS successfully updated with $_GetExternalIP"
        exit 0
    fi
fi

