#!/bin/bash

#/******************************************************************************
#
#   Bash Script to troubleshoot SuSE Linux servers after a ABEND/"reboot"
#   This Script displays the pertinent historical and current server information
#   and log's it to a file /tmp/Rebooshoot_ServerName_Date_Time.txt
#   The output is automatically FTP'd to 168.44.244.237 also for direct download
#   This script also updates the /var/log/messages file that it has been run.
#
#   The pertinent information includes;
#   --The hostname, version & OES version if installed
#   --Whether eDirectory core files are present (if OES is installed)
#   --VMware tests
#   --Date/Time of last reboot
#   --How long the server has been up
#   --History of reboot Dates/Times
#   --Hardware clock
#   --System Clock
#   --NTP server(s) used
#   --namcd status
#   --(If OES is installed) NDS information and *time synchronization info
#   --*Displays a listing of the mounted volumes and there usage statistics
#   --* Information about the users last login; Dates, Times, Duration, etc...
#   --* List top utility resource & utilization information
#   --* Runlevel processes configured to start
#   --* Information about all running processes
#   --* RPM Information; version and date and time
#   --* The /var/log/messages entries for the CURRENT DAY ONLY
#   --(Items preceded by an * are logged to the output file only and not displayed to screen)
#
VERSION='Script: RebooShoot.sh -- Version 4.29'
#   Created by Jim Bodden -- 1/8/2013
#   Modified on -- 2/9/2013
##   The improvements in this version are commented with ## as opposed to only #
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

FILENAME1="/tmp/RebooShoot_`/bin/hostname`_`date +%F`_`date +%H%M`.txt"
FILENAME2="RebooShoot_`/bin/hostname`_`date +%F`_`date +%H%M`.txt"
echo |tee $FILENAME1
echo |tee -a $FILENAME1

divline ()	# Divider line for readability
{ echo '...........................................................................' |tee -a $FILENAME1
} # End of DIVIDELINE function 

padding ()	# Spacing for readability
{ echo |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	echo |tee -a $FILENAME1
} # End of PADDING function 

noscrntxt ()  # Data not echoed to screen only output file
{ echo '('These entries are not displayed on the screen but appended to RebooShoot.txt')'
} # End of NOSCRNTXT function

ftpnow ()
{ cd /tmp                               
	ftp -inv $FTPHOST1 << EOF
	user RebooShoot l3tm31n
	put $FILENAME2
	quit
EOF
} # End of FTPNOW function 

ftptest ()
{ FTSTAT=$(nmap $FTPHOST1 -p 21 | grep open)
	if [[ "$FTSTAT" != *open* ]]
	then
		METHOD="closed"
	fi
} # End of FTPTEST function 

fsuccess ()
{ clear
	echo
	echo
	echo '...........................................................................'
	echo
	echo "You can download the RebooShoot.txt output file on your laptop easily"
	echo "FTP from your laptop to 168.44.244.237 as User: RebooShoot - Passwd: l3tm31n"
	echo
	echo "You can also find the file on this server in the /tmp directory."
	echo "The rebooShoot output file is named; $FILENAME2 "
	echo
	echo '...........................................................................'
} # End of FSUCCESS function 

clear

#/******************************************************************************
# Document in /var/log/messages that this script has been run
#/******************************************************************************

# Logger Executed RebooShoot.sh
logger $VERSION

divline
echo $VERSION 'Executed at;' `date` |tee -a $FILENAME1
divline
padding 	# Spacing added after content for readability

#/******************************************************************************
# Document the hostname, version & OES version if installed
#/******************************************************************************

divline
echo 'Server:' $HOSTNAME |tee -a $FILENAME1
divline
echo |tee -a $FILENAME1

if [ -f /etc/novell-release ];
then
	uname -a |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	cat /etc/SuSE-release |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	cat /etc/novell-release |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	if [ $(find /var/opt/novell/eDirectory/data/ -name 'core.*' | wc -l) -gt 0 ]; then
		echo "Found eDirectory core files to be present in /var/opt/novell/eDirectory/data" |tee -a $FILENAME1
		echo "   --  Note eDirectory has Cored  --" |tee -a $FILENAME1
		echo |tee -a $FILENAME1
	else
		echo "Did not find any eDirectory core files to be present" |tee -a $FILENAME1
		echo |tee -a $FILENAME1
	fi
else
	uname -a |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	cat /etc/SuSE-release |tee -a $FILENAME1
	echo Novell OES is not installed on this server |tee -a $FILENAME1
	echo |tee -a $FILENAME1
fi
padding

#/******************************************************************************
# VMware tests...
#/******************************************************************************

divline
VM1=$(lspci | grep VMware)
if [[ "$VM1" == *VMware* ]]
then
	echo "This is a virtual server running on VMware." |tee -a $FILENAME1
else
	echo "This is a standalone physical server." |tee -a $FILENAME1
fi
echo |tee -a $FILENAME1

if [ -e /usr/bin/vmware-config-tools.pl ]; then
	echo "This server is running the VMware tools..." |tee -a $FILENAME1
	VMTVER=$(grep -E 'buildNr.*build' /usr/bin/vmware-config-tools.pl)
	echo "Version: $VMTVER" |tee -a $FILENAME1
else
	echo "This server is NOT running the VMware tools..." |tee -a $FILENAME1
fi
padding

#/******************************************************************************
# when did the last reboot occur & how long has the server been up?
#/******************************************************************************

divline
echo The most recent reboot of this server was at';'  |tee -a $FILENAME1
who -b  |tee -a $FILENAME1
divline
echo  |tee -a $FILENAME1
echo This server has been up for';' |tee -a $FILENAME1
uptime |tee -a $FILENAME1
divline
padding 	# Spacing added after content for readability

#/******************************************************************************
# Display a listing of the past reboots for this server
#/******************************************************************************

divline
echo Here is a historical listing of the past reboots for this server';'  |tee -a $FILENAME1
divline
echo |tee -a $FILENAME1
last | grep reboot |tee -a $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# List the servers internal hardware clock vs system time accuracy
#/******************************************************************************

divline
echo A comparison of this servers clocks yields';'  |tee -a $FILENAME1
divline

echo System time';'  |tee -a $FILENAME1
date |tee -a $FILENAME1
echo |tee -a $FILENAME1
echo Hardware Clock';' |tee -a $FILENAME1
hwclock |tee -a $FILENAME1
echo |tee -a $FILENAME1
echo  If they are the same, there are no problems. |tee -a $FILENAME1
echo However, if they are different the initial reboot timestamps in /var/log/messages will likely be incorrect short period since the server is using the Hardware clock for the initial log entry timestamps.  |tee -a $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# Display the server(s) used for ntp if active on this server
#/******************************************************************************

divline
echo 'ntp server(s);' |tee -a $FILENAME1
divline
grep -v "#" /etc/ntp.conf | grep server |tee -a $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# namcd status
#/******************************************************************************

divline
echo 'namcd status;' |tee -a $FILENAME1
divline
rcnamcd status |tee -a $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# If OES is installed NDS information and time synchronization info
#/******************************************************************************

if [ -f /etc/novell-release ];
then
	divline
	ndsstat
	ndsrepair -T >> $FILENAME1
else
	echo
fi
padding 	# Spacing added after content for readability

#/******************************************************************************
# Displays a listing of the mounted volumes and there usage statistics
#/******************************************************************************

divline
echo 'Information about the mounted volumes and there usage statistics' |tee -a $FILENAME1
divline
df -H |tee -a $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# Display information about the users last logins, times, etc...
# Filters out the users that have never logged in to this server
#/******************************************************************************

divline
echo 'Information about the users last logins, times, etc...' |tee -a $FILENAME1
noscrntxt
divline
lastlog | grep -v Never >> $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# List top utility resource & utilization information
#/******************************************************************************

divline
echo "List top utility resource & utilization information" |tee -a $FILENAME1
noscrntxt
divline
top -b -n 1 >> $FILENAME1
echo |tee -a $FILENAME1

#/******************************************************************************
# Display all of the process's that normally start on this server in runlevel 5
#/******************************************************************************

divline
echo "All of the process's that normally start on this server in runlevel 5" |tee -a $FILENAME1
noscrntxt
divline
chkconfig --level 5 | grep " on" >> $FILENAME1
echo |tee -a $FILENAME1

#/******************************************************************************
# Display all the running process's
#/******************************************************************************

divline
echo 'Information about all the running processes...' |tee -a $FILENAME1
noscrntxt
divline
ps -ef >> $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# Display RPM Information; version and date and time
#/******************************************************************************

divline
echo 'RPM Information; version and date and time ' |tee -a $FILENAME1
noscrntxt
divline
echo |tee -a $FILENAME1
rpm -qa --last >> $FILENAME1
padding 	# Spacing added after content for readability

#/******************************************************************************
# Display the /var/log/messages entries for today only
#/******************************************************************************

divline
echo 'The /var/log/messages entries for Past 10-24 hours (based on ToD) follow;' |tee -a $FILENAME1
noscrntxt
divline
echo |tee -a $FILENAME1
HOUR=`date +%H`

if [ $HOUR -gt 10 ]
then
	cat /var/log/messages | grep "`date --date="today" +%b\ %e`" >> $FILENAME1
else
	cat /var/log/messages | grep "`date --date="yesterday" +%b\ %e`" | grep '1[4-9]'\:'[0-6][0-9]'\:'[0-6][0-9]' >> $FILENAME1
	cat /var/log/messages | grep "`date --date="yesterday" +%b\ %e`" | grep '2[0-3]'\:'[0-6][0-9]'\:'[0-6][0-9]' >> $FILENAME1
	cat /var/log/messages | grep "`date --date="today" +%b\ %e`" >> $FILENAME1
fi
padding 	# Spacing added after content for readability

#/******************************************************************************
# Report end notification
#/******************************************************************************

echo |tee -a $FILENAME1
divline
echo 'This is the end of the report...   PROCESSING...' |tee -a $FILENAME1
divline

#/******************************************************************************
# Copy the output.txt file to /tmp and to 168.44.244.237:~
#/******************************************************************************

METHOD=" "
echo "   PROCESSING..."

if [[ "$HOST" == *hhsc* ]] || [[ "$HOST" == *HHSC* ]]
then
	METHOD="nated"
	FTPHOST1=168.40.160.237
elif [[ "$HOST" == *tdi* ]] || [[ "$HOST" == *TDI* ]]
then
	METHOD="tdifile"
	FTPHOST1=168.44.244.237
elif  ping -q -c1 168.44.244.237
then
	METHOD="direct"
	FTPHOST1=168.44.244.237
else
	METHOD="closed"
fi

if [ -e /usr/bin/nmap ] && [ $METHOD != "tdifile" ]; then
	ftptest
fi

case "$METHOD" in
	direct)
		ftpnow
		fsuccess
	;;

	nated)
		ftpnow
		fsuccess
	;;

	tdifile)
		clear
		echo "To SCP the file from 168.44.244.237 and then FTP from your laptop."
		echo "SSH in to 168.44.244.237 & run 'sudo RebooTDI.sh' the files will be transffered."
		echo "Then FTP from your laptop to 168.44.244.237"
		echo "User: RebooShoot - Passwd: l3tm31n"
		echo "The rebooShoot output file is named; $FILENAME2 "
	;;

	*)
		# catch-all
		clear
		divline
		echo
		echo
		echo "Cannot access the Novell team tools network server 168.44.244.237 via FTP"
		echo "The RebooShoot.txt output file has NOT been FTP'd there."
		echo
		echo "Find the RebooShoot.txt output file on this server in the /tmp directory."
		echo "The rebooShoot output file is named; $FILENAME2 "
		echo
		echo "..........................................................................."
		echo
esac

#/******************************************************************************
# End; gracefully exit
#/******************************************************************************
exit
