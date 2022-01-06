#!/bin/bash

#/******************************************************************************
#
#   Bash Script to document disk space on Linux servers for billing purposes.
#   
#
VERSION='Script: linuxstoragecalc.sh -- Version 0.3'
#   Created by Matthew Millhouse -- 7/19/2012
#   Modified by Jim Bodden -- 5/14/2014
##	The improvements in this version are commented with ## as opposed to only #
##	Rounding of of storage results to 2 decimal places
##	Coding and structual changes
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

echo -e "Hostname:\t\t "`/bin/hostname -a` > /tmp/ru_output/`/bin/hostname`_`date +%F`

FILENAME1="`/tmp/ru_output/`/bin/hostname`_`date +%F`.csv"
FILENAME2="`/bin/hostname`_`date +%F`.csv"
DIR="/tmp/ru_output"
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
#!/bin/bash

#/******************************************************************************
#
#   Bash Script to document disk space on Linux servers for billing purposes.
#   
#
VERSION='Script: linuxstoragecalc.sh -- Version 0.3'
#   Created by Matthew Millhouse -- 7/19/2012
#   Modified by Jim Bodden -- 5/14/2014
##	The improvements in this version are commented with ## as opposed to only #
##	Rounding of of storage results to 2 decimal places
##	Coding and structual changes
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

echo -e "Hostname:\t\t "`/bin/hostname -a` > /tmp/ru_output/`/bin/hostname`_`date +%F`

FILENAME1="`/tmp/ru_output/`/bin/hostname`_`date +%F`.csv"
FILENAME2="`/bin/hostname`_`date +%F`.csv"
DIR="/tmp/ru_output"
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
