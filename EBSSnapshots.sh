#!/bin/bash

#Setup our AWS access keys
export AWS_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXX
if [ $# = 0 ] ; then
    echo -ne "\nSyntax:";
    echo
    echo -ne "ebs-snapshots.sh <clean_www> <clean_maildata> <clean_mailcfg> <create_maildata> <create_www> <create_mailcfg>\n\n"
    exit
fi;
#Functions to create snapshots - replace xxxxxxxx with the volume id
create_maildata_snapshot() {
ec2-create-snapshot vol-xxxxxxxx -d "/maildata snapshot"
}

create_mailcfg_snapshot() {
ec2-create-snapshot vol-xxxxxxxx -d "/var/opt snapshot"
}

create_www_snapshot() {
ec2-create-snapshot vol-xxxxxxxx -d "/www snapshot"
}

clean_www_snapshots () {
#Get the www snapshots along with the latest www snapshot
all_www_snapshots=$(ec2-describe-snapshots | egrep "/www" | awk '{ print $2 }')
latest_www_snapshot=$(ec2-describe-snapshots | egrep "/www" | sort -k 5 | tail -1 | awk '{ print $2 }')

#Create an array of the latest www snapshots and exclude the latest snapshot
declare -a snapshot_array=(`printf "${all_www_snapshots}" | egrep -v "${latest_www_snapshot}"`)
for snapshot in ${snapshot_array[@]}; do
    ec2-delete-snapshot ${snapshot};
done
}

clean_maildata_snapshots () {
#Get the maildata snapshots along with the latest maildata snapshot
all_maildata_snapshots=$(ec2-describe-snapshots | egrep "/maildata" | awk '{ print $2 }')
latest_maildata_snapshot=$(ec2-describe-snapshots | egrep "/maildata" | sort -k 5 | tail -1 | awk '{ print $2 }')

#Create an array of the latest www snapshots and exclude the latest snapshot
declare -a snapshot_array=(`printf "${all_maildata_snapshots}" | egrep -v "${latest_maildata_snapshot}"`)
for snapshot in ${snapshot_array[@]}; do
    ec2-delete-snapshot ${snapshot};
done
}

clean_mailcfg_snapshots () {
#Get the maildcfg snapshots along with the latest mailcfg snapshot
all_mailcfg_snapshots=$(ec2-describe-snapshots | egrep "/var/opt" | awk '{ print $2 }')
latest_mailcfg_snapshot=$(ec2-describe-snapshots | egrep "/var/opt" | sort -k 5 | tail -1 | awk '{ print $2 }')

#Create an array of the latest www snapshots and exclude the latest snapshot
declare -a snapshot_array=(`printf "${all_mailcfg_snapshots}" | egrep -v "${latest_mailcfg_snapshot}"`)
for snapshot in ${snapshot_array[@]}; do
    ec2-delete-snapshot ${snapshot};
done
}

case "$1" in
    clean_www)
        clean_www_snapshots
    ;;
    clean_maildata)
        clean_maildata_snapshots
    ;;
    clean_mailcfg)
        clean_mailcfg_snapshots
    ;;
    create_maildata)
        create_maildata_snapshot
    ;;
    create_mailcfg)
        create_mailcfg_snapshot
    ;;
    create_www)
        create_www_snapshot
    ;;
esac
