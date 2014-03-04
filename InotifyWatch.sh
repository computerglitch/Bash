#!/bin/bash
#########################################################
# This program watches a specified directory and        #
# subdirectories for changes and executes commands      #
# when things change.     				#       
#							#
# This script relies on inotify-tools. Please install:	#
# yum install inotify-tools				#
#							#
# Written by: Robbie Reese                              #
# Changes:                                              # 
# v0.1      - 04/06/2013   - Inital Release             #
# v0.2      - 04/22/2013   - Added Modify Watch         #
# v0.3      - 04/22/2013   - Added Error Checking       #
# v0.4      - 04/29/2013   - Added Email                #
# v0.5      - 04/30/2013   - Changed watch depth        #
#########################################################

#Modify the following variables to your environment. _dirwatched is the top level directory you monitor.
_usertomail="email@place.org"
_scriptpath="/etc/watch/watch.sh"
_dirwatched="/export/SAS/rawdata"
_ourlogfile="/var/log/inotify_changes_study.log"
_chgwatches="CREATE,MODIFY,DELETE,MOVED_TO,MOVED_FROM"

#_watchdepth specifies how many subdirectories below _dirwatched you monitor for changes.
#_monitortop is the directory to watch for new directory creation.
#_monitortop must match _getlisting below
_watchdepth=$( find $_dirwatched -maxdepth 5 -type d )
_monitortop=$( find $_dirwatched -maxdepth 4 -type d )

if [ ! -f $_scriptpath ]
   then
        echo -e "\n"
        echo -e "Error:"
        echo -e "The _scriptpath variable must be set to the full path of this script."
        echo -e "\n"
        exit 1
fi

if [ ! -d $_dirwatched ]
   then
	echo -e "\n"
	echo -e "Error:"
	echo -e "The directory you want to monitor: $_dirwatched doesn't exist!"
	echo -e "\n"
	exit 1
fi

if [ ! -f $_ourlogfile ]
   then
        echo -e "\n"
        echo -e "Error:"
        echo -e "Please create: $_ourlogfile"
        echo -e "\n"
        exit 1
fi

	echo -ne "\e[1;37;40mMonitoring $_dirwatched for changes.\e[0m \n"
	while inotifywait -q -o $_ourlogfile -e $_chgwatches $_watchdepth
		do
		#_getlisting must match _monitortop for a correct comparison	
		_getlisting=$( find $_dirwatched -maxdepth 4 -type d )
		_dateformat=$( date )
      		_formatlogs=$( tail -1 $_ourlogfile | awk -F " " '{ print $1,$3 }' | sed 's/ //g' )
			if [[ $_getlisting != $_monitortop ]]
			then
				echo -ne "\e[0;32mNew directory added: $_formatlogs \e[0m \n"
				echo -e "The following change was made: \n $_formatlogs created $_dateformat" | mailx -s "Changes to $_dirwatched" "$_usertomail"
				$_scriptpath
				exit 0
			else
				echo -e "The following change was made: \n $_formatlogs created $_dateformat" | mailx -s "Changes to $_dirwatched" "$_usertomail"
				echo -ne "\e[0;32mNew file/directory added: $_formatlogs \e[0m \n"
			fi	
		done
exit 0
