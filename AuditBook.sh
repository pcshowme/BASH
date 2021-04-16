<<<<<<< HEAD
#! /bin/bash    
      
#/******************************************************************************
#
# bash scrip to audit multi-distro Linux distro's for password compliance
#
#	All Distro's and versions; /etc/shadow
#	All Disro's and versions; /etc/login.defs 
#	sles 11 common-auth; pam_tally.so
#	sles 11 common-password; pam_unix_passwd.so pam_cracklib.so
#	sles 10 common-auth; pam_tally.so
#	sles 10 common-password; pam_unix_passwd.so pam_passwdqc.so
#	sles 9 (nothing available to test on)
#	redhat 5&6 password-auth; pam_unix.so pam_passwdqc.so
#	redhat 3&4 (nothing available to test on)
#
# Output is displayed on the screen as well in the form 
# of a CSV file; /tmp/AuditBook_hostname_date.csv
#
#   Created by Jim Bodden -- 12/26/2013
#   Modified by Jim Bodden -- 12/28/2013
#
#/******************************************************************************

#/**************************************************
# 	Declaraitions, functions & setup...
#/**************************************************

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

versiontest(){
	if [ -f /etc/SuSE-release ] ; then
		if grep -q -i "VERSION = 11" /etc/SuSE-release
			then
			VERN="S11"
			echo "Running SuSE Version 11" |tee -a $FILENAME1
		elif grep -q -i "VERSION = 10" /etc/SuSE-release
			then
			VERN="S10"
			echo "Running SuSE Version 10" |tee -a $FILENAME1
		else
			VERN="S9"
			echo "Running SuSE Version 9" |tee -a $FILENAME1
		fi
	elif [ -f /etc/redhat-release ] ; then
		if grep -q -i "release 6" /etc/redhat-release
			then
			VERN="R6"
			echo "Running Redhat Release 6.x" |tee -a $FILENAME1
		elif grep -q -i "release 5" /etc/redhat-release
			then
			VERN="R5"
			echo "Running Redhat Release 5.x" |tee -a $FILENAME1
		elif grep -q -i "release 4" /etc/redhat-release
			then
			VERN="R4"
			echo "Running Redhat Release 5.x" |tee -a $FILENAME1
		else grep -q -i "release 3" /etc/redhat-release
			VERN="R3"
			echo "Running Redhat Release 3.x" |tee -a $FILENAME1
		fi
	else
		VERN="UNK"
		echo "Running non-standard Distro, Version unknown" |tee -a $FILENAME1
	fi
}

FILENAME1="/tmp/AuditBook_"$(hostname)_$(date '+%F')".csv"
echo " " |tee $FILENAME1 2>&1
echo "AuditBook for server: $(hostname)" |tee -a $FILENAME1
versiontest
echo "Output collected "$(date '+%F') |tee -a $FILENAME1
echo " " |tee -a $FILENAME1

#/**************************************************
# 	/etc/Shadow user specific settings
#/**************************************************

echo "UserID,MaxPassChg,MinPasswdChg" |tee -a $FILENAME1
while IFS=: read USER PW LPCH MINCH MAXCH WARN INACTIVE EXPIRE          
do          
echo -e "$USER,$MAXCH,$MINCH" |tee -a $FILENAME1
done < /etc/shadow
echo " " |tee -a $FILENAME1

echo "---------------" |tee -a $FILENAME1

#/**************************************************
# 	/etc/login.defs settings for Password's
#/**************************************************

PASSMAXDAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs | grep -o '[0-9]*')
PASSMINDAYS=$(grep "^PASS_MIN_DAYS" /etc/login.defs | grep -o '[0-9]*')
PASSMINLEN=$(grep "^PASS_MIN_LEN" /etc/login.defs | grep -o '[0-9]*')
echo "/etc/login.defs,PASS_MAX_DAYS,$PASSMAXDAYS" |tee -a $FILENAME1
echo "/etc/login.defs,PASS_MAX_DAYS,$PASSMINDAYS" |tee -a $FILENAME1
echo "/etc/login.defs,PASS_MIN_LEN,$PASSMINLEN" |tee -a $FILENAME1

echo "---------------" |tee -a $FILENAME1

#/**************************************************
# 	/etc/pam.d password specific settings
#	Several options are the same but they are broke into version groups for easy customization
#/**************************************************

if [ $VERN == "S11" ] ; then
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "S10" ] ; then
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "S9" ] ; then 		# I have no Version 9 servers to test this on
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "R6" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R5" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R4" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R3" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
else
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
fi

exit	
=======
#! /bin/bash    
      
#/******************************************************************************
#
# bash scrip to audit multi-distro Linux distro's for password compliance
#
#	All Distro's and versions; /etc/shadow
#	All Disro's and versions; /etc/login.defs 
#	sles 11 common-auth; pam_tally.so
#	sles 11 common-password; pam_unix_passwd.so pam_cracklib.so
#	sles 10 common-auth; pam_tally.so
#	sles 10 common-password; pam_unix_passwd.so pam_passwdqc.so
#	sles 9 (nothing available to test on)
#	redhat 5&6 password-auth; pam_unix.so pam_passwdqc.so
#	redhat 3&4 (nothing available to test on)
#
# Output is displayed on the screen as well in the form 
# of a CSV file; /tmp/AuditBook_hostname_date.csv
#
#   Created by Jim Bodden -- 12/26/2013
#   Modified by Jim Bodden -- 12/28/2013
#
#/******************************************************************************

#/**************************************************
# 	Declaraitions, functions & setup...
#/**************************************************

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

versiontest(){
	if [ -f /etc/SuSE-release ] ; then
		if grep -q -i "VERSION = 11" /etc/SuSE-release
			then
			VERN="S11"
			echo "Running SuSE Version 11" |tee -a $FILENAME1
		elif grep -q -i "VERSION = 10" /etc/SuSE-release
			then
			VERN="S10"
			echo "Running SuSE Version 10" |tee -a $FILENAME1
		else
			VERN="S9"
			echo "Running SuSE Version 9" |tee -a $FILENAME1
		fi
	elif [ -f /etc/redhat-release ] ; then
		if grep -q -i "release 6" /etc/redhat-release
			then
			VERN="R6"
			echo "Running Redhat Release 6.x" |tee -a $FILENAME1
		elif grep -q -i "release 5" /etc/redhat-release
			then
			VERN="R5"
			echo "Running Redhat Release 5.x" |tee -a $FILENAME1
		elif grep -q -i "release 4" /etc/redhat-release
			then
			VERN="R4"
			echo "Running Redhat Release 5.x" |tee -a $FILENAME1
		else grep -q -i "release 3" /etc/redhat-release
			VERN="R3"
			echo "Running Redhat Release 3.x" |tee -a $FILENAME1
		fi
	else
		VERN="UNK"
		echo "Running non-standard Distro, Version unknown" |tee -a $FILENAME1
	fi
}

FILENAME1="/tmp/AuditBook_"$(hostname)_$(date '+%F')".csv"
echo " " |tee $FILENAME1 2>&1
echo "AuditBook for server: $(hostname)" |tee -a $FILENAME1
versiontest
echo "Output collected "$(date '+%F') |tee -a $FILENAME1
echo " " |tee -a $FILENAME1

#/**************************************************
# 	/etc/Shadow user specific settings
#/**************************************************

echo "UserID,MaxPassChg,MinPasswdChg" |tee -a $FILENAME1
while IFS=: read USER PW LPCH MINCH MAXCH WARN INACTIVE EXPIRE          
do          
echo -e "$USER,$MAXCH,$MINCH" |tee -a $FILENAME1
done < /etc/shadow
echo " " |tee -a $FILENAME1

echo "---------------" |tee -a $FILENAME1

#/**************************************************
# 	/etc/login.defs settings for Password's
#/**************************************************

PASSMAXDAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs | grep -o '[0-9]*')
PASSMINDAYS=$(grep "^PASS_MIN_DAYS" /etc/login.defs | grep -o '[0-9]*')
PASSMINLEN=$(grep "^PASS_MIN_LEN" /etc/login.defs | grep -o '[0-9]*')
echo "/etc/login.defs,PASS_MAX_DAYS,$PASSMAXDAYS" |tee -a $FILENAME1
echo "/etc/login.defs,PASS_MAX_DAYS,$PASSMINDAYS" |tee -a $FILENAME1
echo "/etc/login.defs,PASS_MIN_LEN,$PASSMINLEN" |tee -a $FILENAME1

echo "---------------" |tee -a $FILENAME1

#/**************************************************
# 	/etc/pam.d password specific settings
#	Several options are the same but they are broke into version groups for easy customization
#/**************************************************

if [ $VERN == "S11" ] ; then
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "S10" ] ; then
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "S9" ] ; then 		# I have no Version 9 servers to test this on
	echo "/etc/pam.d/common-password"
	echo $(grep "^password" /etc/pam.d/common-password) |tee -a $FILENAME1
	echo "/etc/pam.d/common-auth"
	echo $(grep "pam_tally.so" /etc/pam.d/common-auth) |tee -a $FILENAME1
elif [ $VERN == "R6" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R5" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R4" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
elif [ $VERN == "R3" ] ; then
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
else
	echo "/etc/pam.d/password-auth"
	echo $(grep "^password" /etc/pam.d/password-auth) |tee -a $FILENAME1
fi

exit	
>>>>>>> origin/master
