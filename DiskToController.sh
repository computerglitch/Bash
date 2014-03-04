#!/bin/bash
#########################################################
# This script attempts to locate the serial number 	#
# of the disk and the controller it is connected to.    #
# This script relies upon smartctl & sas2ircu.          #
# This script can locate SEAGATE HITACHI & OCZ DRIVES   #
#							#
# Written by: Robbie Reese				#
# Changes:            					# 
# v0.1      - 10/08/2012   - Inital Release     	#
# v0.2	    - 10/12/2012   - Added Enclosure/Slot Info  #
#########################################################
# PROMPT FOR DISK INPUT
#echo -n "Enter the disk you wish to locate (ex. sdg): "
#        read -e DISK
#
# GET A LIST OF DISKS
#DISK=$*
#echo $DISK
#exit 1

DISK=("$@")

	if [ -b /dev/$@ ]
	   then
		echo
	   else
		echo "Usage: ./nfs0_disk <blockdevice>"
		echo "Example: ./nfs0_disk sdc"
		exit 1
	fi

echo -ne "\e[1;37;40m/dev/$DISK \e[0m" 

SEAGATE=`smartctl -i /dev/$DISK | grep "SEAGATE" | cut -c 1-15`
HITACHI=`smartctl -i /dev/$DISK | grep "HITACHI" | cut -c 1-15`
OCZ_VER=`smartctl -i /dev/$DISK | grep "OCZ-VERTEX2" | cut -c 1-29`
RAID_AR=`cat /proc/mdstat | grep $DISK | cut -c 1-2`

	if [[ $SEAGATE == "Device: SEAGATE" ]];
	   then
		echo
		echo -ne "Disk Type is SEAGATE.\n"
                SERIAL_NUM=`smartctl -i /dev/$DISK | grep "Serial number" | sed "s/Serial number: //" | cut -c 1-8`
		echo -ne "Serial Number is: $SERIAL_NUM\n\n"
	elif [[ $HITACHI == "Device: HITACHI" ]];
	   then
	 	echo
                echo -ne "Disk Type is HITACHI.\n"
                SERIAL_NUM=`smartctl -i /dev/$DISK | grep "Serial number" | sed "s/Serial number:         //"`
                echo -ne "Serial Number is: $SERIAL_NUM\n\n"
	elif [[ $OCZ_VER == "Device Model:     OCZ-VERTEX2" ]];
           then
		echo
                echo -ne "Disk Type is OCZ-VERTEX2.\n"
                SERIAL_NUM=`smartctl -i /dev/$DISK | grep "Serial Number" | sed "s/Serial Number:    //" | sed "s/\-//"`
                echo -ne "Serial Number is: $SERIAL_NUM\n\n"
	fi
	if [[ $RAID_AR == "md" ]];
	   then
		ARRAY=`cat /proc/mdstat | grep $DISK | cut -c 1-4`
		echo -ne "\e[1;31;40mThis disk is part of Software Raid Array: $ARRAY \e[0m \n\n"
	   else
		echo -ne "This disk is not part of a Software Raid\n\n" 
	fi

	echo -ne 'Searching Controllers ####        (25%)\r'
	CONTROLLER_0=`sas2ircu 0 display | grep "$SERIAL_NUM" | sed "s/  Serial No                               : //"`
	echo -ne 'Searching Controllers ########    (50%)\r'
	CONTROLLER_1=`sas2ircu 1 display | grep "$SERIAL_NUM" | sed "s/  Serial No                               : //"`
	echo -ne 'Searching Controllers #########   (75%)\r'
	CONTROLLER_2=`sas2ircu 2 display | grep "$SERIAL_NUM" | sed "s/  Serial No                               : //"`
	echo -ne 'Searching Controllers ##########  (85%)\r'
	CONTROLLER_3=`sas2ircu 3 display | grep "$SERIAL_NUM" | sed "s/  Serial No                               : //"`

	if [[ $CONTROLLER_0 == $SERIAL_NUM ]];
	   then
		echo -ne 'Searching Controllers ########### (95%)\r'
		ENC_SLOT=`sas2ircu 0 display | grep -B 8 $SERIAL_NUM | head -2 | sed "s/^[ \t]*//"`
		echo -ne 'Searching Controllers ############(100%)\r'
                echo -ne '\n\n'
                echo -ne "/dev/$DISK is located on Controller 0\n";
		echo -ne "$ENC_SLOT\n\n"
                exit 1
	elif [[ $CONTROLLER_1 == $SERIAL_NUM ]];
           then
		echo -ne 'Searching Controllers ########### (95%)\r'
                ENC_SLOT=`sas2ircu 1 display | grep -B 8 $SERIAL_NUM | head -2 | sed "s/^[ \t]*//"`
                echo -ne 'Searching Controllers ############(100%)\r'
                echo -ne '\n\n'
                echo -ne "/dev/$DISK is located on Controller 1\n";
		echo -ne "$ENC_SLOT\n\n"
                exit 1
        elif [[ $CONTROLLER_2 == $SERIAL_NUM ]];
           then
		echo -ne 'Searching Controllers ########### (95%)\r'
                ENC_SLOT=`sas2ircu 2 display | grep -B 8 $SERIAL_NUM | head -2 | sed "s/^[ \t]*//"`
                echo -ne 'Searching Controllers ############(100%)\r'
                echo -ne '\n\n'
                echo -ne "/dev/$DISK is located on Controller 2\n";
		echo -ne "$ENC_SLOT\n\n"
                exit 1
	elif [[ $CONTROLLER_3 == $SERIAL_NUM ]];
           then
		echo -ne 'Searching Controllers ########### (95%)\r'
                ENC_SLOT=`sas2ircu 3 display | grep -B 8 $SERIAL_NUM | head -2 | sed "s/^[ \t]*//"`
                echo -ne 'Searching Controllers ############(100%)\r'
                echo -ne '\n\n'
                echo -ne "/dev/$DISK is located on Controller 3\n";
		echo -ne "$ENC_SLOT\n\n"
                exit 1


	fi
exit 1
