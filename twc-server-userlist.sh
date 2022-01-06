#!/bin/bash
#
# Linux information gathering; TWC Server/Userlist
VERSION='twc-server-userlist.sh--Version-1.28'
# Created; 10/14/2015 by Jim Bodden
# Modified; 11/03/2015 by Jim Bodden
# 
# - Read in shadow, create array groups; USR, STANDARD, EXEMPT and REVIEW
# - Change all STANDARD 90 day Accounts to 60 days, REVIEW = USR - (STANDARD + EXEMPT)
# - send back a log file grouping those acounts changes, the standard exempted accounts and those accounts left needing review.
# - the acounts needing manual review should be short, the majority will land in to 90 day or standard exemption groups.

#
# - Output file design layout
# --- HOSTNAME - TYPE - ID - UIDN - INTERVAL - FUTURE
#
#

SERVER="$(hostname | cut -d. -f1)"
N=0; FILENAME1="/tmp/twc-server-userlist.csv"; FILENAME2="/tmp/twc-server-userlist2.csv"
2>/dev/null rm -f $FILENAME1; 2>/dev/null rm -f $FILENAME2

echo "bin daemon ftp games gdm lp mail man news nobody ntp postfix root sshd suse-ncc uucp wwwrun addm_txdcs" > /tmp/system-accounts.tmp

#*****************************
# Read /etc/passwd and /etc/shadow files into array @A_USR
#-----------------------------
while read PSWD
do
	ID=$(echo $PSWD | awk -F':' '{print $1}')
	SHDW=$(cat /etc/shadow | grep -w $ID)
	A_USR[$N]="$PSWD:$SHDW"
	((N++))
done < /etc/passwd
A_USR_LEN=${#A_USR[@]}

#*****************************
# Evaluate records for $UIDN > 1000, Catagorize, (modify interval) & create output file...
#-----------------------------

N=0
echo "HOSTNAME,TYPE,ID,UIDN,INTERVAL,FUTURE" > $FILENAME2
while [[ $N -lt "$A_USR_LEN" ]]
do
	ID=$(echo ${A_USR[N]} | awk -F':' '{print $1}')
	UIDN=$(echo ${A_USR[N]} | awk -F':' '{print $3}')
	MAX=$(echo ${A_USR[N]} | awk -F':' '{print $12}')
	if [[ $UIDN -gt 999 ]] 
	then 
		((STANDARD_CNT++))
		echo "$SERVER,STANDARD,$ID,$UIDN,$MAX,60" >> $FILENAME2
		# This account WILL be changed when the following line is un-commented...
		# chage -M 60 $ID 
	else
		((SYSTEM_CNT++))
		echo "$SERVER,SYSTEM,$ID,$UIDN,$MAX,$MAX" >> $FILENAME2
		# This account will NOT be changed. 
	fi
	((N++))
done

#*****************************
# Display closing summary information
#-----------------------------

echo "There are $A_USR_LEN Local accounts on this sever $SERVER."
echo "$STANDARD_CNT of those are standard accounts with User ID #'s equal to 1000 or above."
echo "$SYSTEM_CNT of those are system accounts with user ID #'s below 1000."
echo " "
cat /$FILENAME2 | sort -t, -k4 -n | tee $FILENAME1

exit 0
#--------------------------------------------------------------------
#!/bin/bash
#
# Linux information gathering; TWC Server/Userlist
VERSION='twc-server-userlist.sh--Version-1.28'
# Created; 10/14/2015 by Jim Bodden
# Modified; 11/03/2015 by Jim Bodden
# 
# - Read in shadow, create array groups; USR, STANDARD, EXEMPT and REVIEW
# - Change all STANDARD 90 day Accounts to 60 days, REVIEW = USR - (STANDARD + EXEMPT)
# - send back a log file grouping those acounts changes, the standard exempted accounts and those accounts left needing review.
# - the acounts needing manual review should be short, the majority will land in to 90 day or standard exemption groups.

#
# - Output file design layout
# --- HOSTNAME - TYPE - ID - UIDN - INTERVAL - FUTURE
#
#

SERVER="$(hostname | cut -d. -f1)"
N=0; FILENAME1="/tmp/twc-server-userlist.csv"; FILENAME2="/tmp/twc-server-userlist2.csv"
2>/dev/null rm -f $FILENAME1; 2>/dev/null rm -f $FILENAME2

echo "bin daemon ftp games gdm lp mail man news nobody ntp postfix root sshd suse-ncc uucp wwwrun addm_txdcs" > /tmp/system-accounts.tmp

#*****************************
# Read /etc/passwd and /etc/shadow files into array @A_USR
#-----------------------------
while read PSWD
do
	ID=$(echo $PSWD | awk -F':' '{print $1}')
	SHDW=$(cat /etc/shadow | grep -w $ID)
	A_USR[$N]="$PSWD:$SHDW"
	((N++))
done < /etc/passwd
A_USR_LEN=${#A_USR[@]}

#*****************************
# Evaluate records for $UIDN > 1000, Catagorize, (modify interval) & create output file...
#-----------------------------

N=0
echo "HOSTNAME,TYPE,ID,UIDN,INTERVAL,FUTURE" > $FILENAME2
while [[ $N -lt "$A_USR_LEN" ]]
do
	ID=$(echo ${A_USR[N]} | awk -F':' '{print $1}')
	UIDN=$(echo ${A_USR[N]} | awk -F':' '{print $3}')
	MAX=$(echo ${A_USR[N]} | awk -F':' '{print $12}')
	if [[ $UIDN -gt 999 ]] 
	then 
		((STANDARD_CNT++))
		echo "$SERVER,STANDARD,$ID,$UIDN,$MAX,60" >> $FILENAME2
		# This account WILL be changed when the following line is un-commented...
		# chage -M 60 $ID 
	else
		((SYSTEM_CNT++))
		echo "$SERVER,SYSTEM,$ID,$UIDN,$MAX,$MAX" >> $FILENAME2
		# This account will NOT be changed. 
	fi
	((N++))
done

#*****************************
# Display closing summary information
#-----------------------------

echo "There are $A_USR_LEN Local accounts on this sever $SERVER."
echo "$STANDARD_CNT of those are standard accounts with User ID #'s equal to 1000 or above."
echo "$SYSTEM_CNT of those are system accounts with user ID #'s below 1000."
echo " "
cat /$FILENAME2 | sort -t, -k4 -n | tee $FILENAME1

exit 0
#--------------------------------------------------------------------
