<<<<<<< HEAD
#!/bin/bash
#
# Linux information gathering; TWC Server/Userlist
VERSION='twc-server-userlist.sh--Version-1.03'
# Created; 10/14/2015 by Jim Bodden
# Modified; 10/29/2015 by Jim Bodden
# 
# - Read in shadow, create array groups; USR, STANDARD, EXEMPT and REVIEW
# - Change all STANDARD 90 day Accounts to 60 days, REVIEW = USR - (STANDARD + EXEMPT)
# - send back a log file grouping those acounts changes, the standard exempted accounts and those accounts left needing review.
# - the acounts needing manual review should be short, the majority will land in to 90 day or standard exemption groups.

SERVER="$(hostname | cut -d. -f1)"; echo $SERVER
N=0; I=0

echo "bin daemon ftp games gdm lp mail man news nobody ntp postfix root sshd suse-ncc uucp wwwrun addm_txdcs" > /tmp/system-accounts.tmp

while read LINE
do
	A_USR[$N]="$LINE"
	((N++))
done < /etc/shadow
A_USR_LEN=${#A_USR[@]}

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_USR_LEN" ]]
do
	ID=$(echo ${A_USR[I]} | awk -F':' '{print $1}')
	MAX=$(echo ${A_USR[I]} | awk -F':' '{print $5}')
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	if [[ $(cat /tmp/system-accounts.tmp | grep -iw "$ID") ]]; then A_SYSTEM[K]=$ID; ((K++))
	else 
		if [[ $(echo $MAX | grep -w "90") ]]; then A_STANDARD[N]=$ID; ((N++)); else A_NONSTRD[J]=$ID; ((J++)); fi
	fi
	echo "$I -- $ID -- $MAX"
	((I++))
done
A_STANDARD_LEN=${#A_STANDARD[@]}
A_NONSTRD_LEN=${#A_NONSTRD[@]}
A_SYSTEM_LEN=${#A_SYSTEM[@]}

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_STANDARD_LEN" ]]
do
	echo "$I -- ${A_STANDARD[I]} is a Standard Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_NONSTRD_LEN" ]]
do
	echo "$I -- ${A_NONSTRD[I]} is a Non-Standard Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_SYSTEM_LEN" ]]
do
	echo "$I -- ${A_SYSTEM[I]} is a System Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

echo "There are $A_USR_LEN Local accounts on this sever $SERVER."
echo "$A_STANDARD_LEN of those are user accounts are standard accounts with a 90 day password change interval."
echo "$A_NONSTRD_LEN of those are user accounts that have non-standard password change intervals other than 90 days."
echo "$A_SYSTEM_LEN of those are system accounts that may have non-standard password change intervals other than 90 days."
exit 0
#--------------------------------------------------------------------
=======
#!/bin/bash
#
# Linux information gathering; TWC Server/Userlist
VERSION='twc-server-userlist.sh--Version-1.03'
# Created; 10/14/2015 by Jim Bodden
# Modified; 10/29/2015 by Jim Bodden
# 
# - Read in shadow, create array groups; USR, STANDARD, EXEMPT and REVIEW
# - Change all STANDARD 90 day Accounts to 60 days, REVIEW = USR - (STANDARD + EXEMPT)
# - send back a log file grouping those acounts changes, the standard exempted accounts and those accounts left needing review.
# - the acounts needing manual review should be short, the majority will land in to 90 day or standard exemption groups.

SERVER="$(hostname | cut -d. -f1)"; echo $SERVER
N=0; I=0

echo "bin daemon ftp games gdm lp mail man news nobody ntp postfix root sshd suse-ncc uucp wwwrun addm_txdcs" > /tmp/system-accounts.tmp

while read LINE
do
	A_USR[$N]="$LINE"
	((N++))
done < /etc/shadow
A_USR_LEN=${#A_USR[@]}

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_USR_LEN" ]]
do
	ID=$(echo ${A_USR[I]} | awk -F':' '{print $1}')
	MAX=$(echo ${A_USR[I]} | awk -F':' '{print $5}')
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	if [[ $(cat /tmp/system-accounts.tmp | grep -iw "$ID") ]]; then A_SYSTEM[K]=$ID; ((K++))
	else 
		if [[ $(echo $MAX | grep -w "90") ]]; then A_STANDARD[N]=$ID; ((N++)); else A_NONSTRD[J]=$ID; ((J++)); fi
	fi
	echo "$I -- $ID -- $MAX"
	((I++))
done
A_STANDARD_LEN=${#A_STANDARD[@]}
A_NONSTRD_LEN=${#A_NONSTRD[@]}
A_SYSTEM_LEN=${#A_SYSTEM[@]}

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_STANDARD_LEN" ]]
do
	echo "$I -- ${A_STANDARD[I]} is a Standard Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_NONSTRD_LEN" ]]
do
	echo "$I -- ${A_NONSTRD[I]} is a Non-Standard Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

N=0; I=0; J=0; K=0
while [[ $I -lt "$A_SYSTEM_LEN" ]]
do
	echo "$I -- ${A_SYSTEM[I]} is a System Account"
#	read -p "$Press Enter"; # pause for troubleshooting purposes...
	((I++))
done

echo "There are $A_USR_LEN Local accounts on this sever $SERVER."
echo "$A_STANDARD_LEN of those are user accounts are standard accounts with a 90 day password change interval."
echo "$A_NONSTRD_LEN of those are user accounts that have non-standard password change intervals other than 90 days."
echo "$A_SYSTEM_LEN of those are system accounts that may have non-standard password change intervals other than 90 days."
exit 0
#--------------------------------------------------------------------
>>>>>>> origin/master
