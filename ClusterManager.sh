#!/bin/bash
#########################################################
# Script to manage the local tesla cluster              #
#                                                       #
# Written by: Robbie Reese                              #
# Changes:                                              #
# v0.1      - 03/02/2013   - Inital Release             #
# v0.2      - 03/11/2013   - Added reboot               #
#########################################################

_computenodes="0-4"
_network="10.20.0"
_domain="localdomain"
_getnodes=$(dig -tAXFR "$_domain" | grep "compute" | grep "$_network" | cut -d "." -f1)
_nodeshn=( $_getnodes )
_sgeservice="sge_execd"
_sgeexepath="/opt/sge/cluster/common/sgeexecd"

nodes-up () {
	for hosts in $_getnodes
		do set -- $hosts
		_node="$1"
		_updown=`ping -c1 -w1 -q $hosts | grep "1 received" | wc -l`
			if [ "$_updown" == 1 ]
			then
				echo -e "$_node is up"
			else 
				echo -e "\e[1;31;40m$_node is down\e[0m"	
			fi
	done		
}

nodes-sge () {
	for hosts in $_getnodes
		do set -- $hosts
		_node="$1"

		echo "Checking if service $_sgeservice is running on $_node ..."
	        ssh $_node ps -ef | grep -q $_sgeservice
                if [ $? -eq 0 ]; then
                        sleep 3
                        echo "$_sgeservice is running on $_node"
                        sleep 2
                else
                        sleep 3
                        echo -ne "\e[1;31;40m$_sgeservice is not running on $_node.\e[0m \n"
                        echo -ne "\e[1;37;40mStarting $_sgeservice...\e[0m"
                        ssh $_node $_sgeexepath
                        ssh $_node ps -ef | grep -q $_sgeservice
                                if [ $? -eq 0 ]; then
                                        sleep 3
                                        echo "$_sgeservice started on $_node"
                                        sleep 2
                                else
                                        echo "$_sgeservice couldn't be started!"
                                fi
                        sleep 2
                fi
	done
}

nodes-cpu () {
        for hosts in $_getnodes
                do set -- $hosts
                _node="$1"

                echo -ne "Top CPU Process on \e[1;37;40m$_node\e[0m ...\n"
                ssh $_node ps -eo pcpu,pid,user,args | sort -k 1 -r | head -2
        done
}

nodes-mem () {
        for hosts in $_getnodes
                do set -- $hosts
                _node="$1"

                echo -ne "Top CPU Process on \e[1;37;40m$_node\e[0m ...\n"
                ssh $_node ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -r | head -2
        done
}

nodes-reboot () {
	for hosts in $_getnodes
                do set -- $hosts
                _node="$1"
                _updown=`ping -c1 -w1 -q $hosts | grep "1 received" | wc -l`
                        if [ "$_updown" == 1 ]
                        then
                                ssh $_node shutdown -r 1 & > /dev/null 
                        else
                                echo -e "\e[1;31;40m$_node is already down.\e[0m"
                        fi
	done
}

case "$1" in
	nodes-up)
		nodes-up
	;;
	nodes-cpu)
		nodes-cpu
	;;
	nodes-mem)
		nodes-mem
	;;
	nodes-sge)
		nodes-sge
	;;
	[$_computenodes])
		ssh "compute$@"	
	;;
	nodes-reboot)
		nodes-reboot
	;;
	*)
		echo -e ""
		echo -e "Usage:"
		echo -e "-	\e[1;37;40mtesla.sh nodes-up\e[0m  "
		echo -e "        --Checks what compute nodes are up and lists compute nodes that are down.\n"
		echo -e "-	\e[1;37;40mtesla.sh nodes-sge\e[0m " 
	        echo -e "	--Checks if the SGE execution daemon is running on each compute node. If the daemon is not running we try to start it.\n"
		echo -e "-	\e[1;37;40mtesla.sh <nodenumber> <command>\e[0m " 
	        echo -e "	--Run a command on the compute node. Example: tesla 2 hostname\n"
		echo -e "-	\e[1;37;40mtesla.sh nodes-reboot\e[0m  "
	        echo -e "	--Reboot all of the compute nodes after 1 minute.\n"
		echo -e "-       \e[1;37;40mtesla.sh nodes-cpu\e[0m  "
                echo -e "        --List the process consuming the most cpu resources on the compute nodes.\n"
		echo -e "-       \e[1;37;40mtesla.sh nodes-mem\e[0m  "
                echo -e "        --List the process consuming the most memory resources on the compute nodes.\n"
	;;
esac
