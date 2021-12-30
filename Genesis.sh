#!/bin/bash

#/******************************************************************************
#
#   Bash Script Genesis.sh to create and standardize my Login environment.
#   
#   This script; essentially terraforms my server login environment for me, my requirments and prefferences
#   Just my shell, not everyones ;-) 
#	Verifies access first, if OES access, also creates a local account.
#   Creates the directory /home/jbodden/.ssh if it does not exist.
#	Creates and populates the file /home/jbodden/.ssh/authorized_keys if it does not exist.
#
VERSION='Script: Genesis.sh -- Version 1.41'
#   Created by Jim Bodden -- 6/23/2014
#   Modified on -- 8/08/2014
#
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

FILENAME1="/tmp/Genesis_`/bin/hostname`_`date +%F`_.tmp"
GRP=`cat /etc/group | grep "\:40000\:" | cut -d: -f1`

keys ()	# Creates, populates and sets security for authorized_keys file
{ clear
	# 20140219 -- apinmslx01 (197); adinzwno01 (237); adinzwno02 (250)  ssh-key w/pp
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuLO3z3UxPbmH19zz+1LZscbKpS0Xj5jwiZ6ddo8NgW9JijEIMm/74+alLEvycg4WoIHOi8iMACvj/I05fld7iWmir3fJ861oSk59gtwN3kiG64Q68n3ypqpWJxk/xIUftJqreD0/s6/V08wyvhKF92PipOkfnF+IS7AGOsde2h3ByjrjLmXZBLDjqAWzqtVdUSWY9NqGMG0RksDNTadrhlrjQOLCu6L0VKyTs0Z6G7iqiCDLPdc+y3Ww6tPzdg4yh28x/z3TAcELc6MBdsgnz80Vij2pFotV3BCoZZczKRnrZBl8cGosw1IeOoHp+k4Ywl9QnzfKipaPPncC5Ty1nQ== 20140219" > /home/jbodden/.ssh/authorized_keys
	# 20140721 -- apinmswn06 (253); apinzwwn01(226); adinzwwn019227)  ssh-key w/pp
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBL8jVofbeDTTNRCGmX3LuZe/SG0Xsbwt0LjCIZ+ZzJOGta+4qAD5NAnpX4XGBtiLyoK6vuk1CKFAq4NvxnEa5iC9672vs4GVeFfqAHfr6ati1qIw6fod8i3jg2M7HuP+HvAAzOoxR0PY/PAr2Nr7h1M5E2FeEj4rFNPrR/nvcOX5LXe0nKDH3VlLaXULhsgrVXKbt7a7rQ6k9rFtXajno88iHUbX3/pKAAAYRi47tL2cgYVXlZLsCwxOlxe9QmzUXUf2Ax/ZATYkenaTqRtByqAfAkIKt72Oz/mtNPwFfATZPVaT+uS11aM+GEmR9na/m/hQdws1LMuvigwcUFLtmN rsa-key-20140721" >> /home/jbodden/.ssh/authorized_keys
	# 20140216 -- AUS5LW00943038 (My Xerox Laptop)
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAq1qmGSWeLRuoRQS168/FaC1c6X0F0DpIy9CQPLRa7xq1VNOvSYKV5748kBqyl74mB+uw6+Gup6mPrhY6qOWKl6VV0e7nWqOMDMGxDZCVfcMm3qXwBMNdFSBwc6XdHq4PsvV3rnSf4jxqx58JIWzCANxrJlDhq0k6vDmQa8HNVrFmEBfwl7em5bxKFoo0fN0bZdWzzTTWVHPZZ8wVoGb0Ig2I1Lq9sLTm5jYadQQ8E6ybvZwr8plmXyWTNuYGkFo1mj1MrA46E+6QLW1BBW1orUXoCn/6K6zp0Zs31NJ5iwi/OL8yTxxsG6GeFzLwlGQHaNzMvTJgtYMNpgLi6LZJow== rsa-key-20140216"  >> /home/jbodden/.ssh/authorized_keys 
	chmod 600 /home/jbodden/.ssh/authorized_keys
} # End of keys function 

uidgen ()	# determins an available UID inthe 401xx range
{ clear
	declare -i UID1 UID2 N X
	N=0; X=0
	cat /etc/passwd | grep "\:401[0-9][0-9]" | cut -d: -f3 | sort > /tmp/uid.tmp
	UIDARY=($(</tmp/uid.tmp))
	X=${UIDARY[N]}
	while [ ${UIDARY[N]} -eq $X ]
	do
	N=N+1; X=X+1
	done
	UID2=$X
	echo "New UID2=$X"
} # End of uidgen function 

#/******************************************************************************
# # Test to see if Local account exists, create local account if necessary
#/******************************************************************************

UNAME1=$(cut -d: -f1 /etc/passwd | grep jbodden)
if [[ "$UNAME1" == jbodden ]]; then
	LOCUSR=1
else
	LOCUSR=0
fi


#/******************************************************************************
# # Test for OES then create local account if necessary
#/******************************************************************************

UID1=`cat /etc/passwd | grep "\:40104\:" | cut -d: -f3`
if [ -f /etc/novell-release ] && [ $LOCUSR==0 ]; then
	ACCESS="OES"			
	if [[ "UID1" == 40104 ]]; then
		uidgen
	else
		UID2=$UID1
	fi	
		useradd -u $UID2 -g 40000 -d /home/jbodden -m -c "897/I/20538908/XRX/Bodden,Jim/ULN-SA" jbodden
		echo "jbodden:3edcmju7" | chpasswd
fi

#/******************************************************************************
# Test/prepare ssh infastructure then re-key or create key if necessary
#/******************************************************************************

USR1=$(cut -d: -f1 /etc/passwd | grep jbodden)
if [[ "$USR1" == *jbodden* ]]
then
	if [ ! -d /home/jbodden/.ssh ]; then
		mkdir /home/jbodden/.ssh
		chown jbodden:$GRP /home/jbodden/.ssh
		chmod 700 /home/jbodden/.ssh
		keys
		KEYSTAT="Created-Key"
	fi
else
	keys
	KEYSTAT="Re-Keyed"
fi	

#/******************************************************************************
# Test and report status
#/******************************************************************************
USR2=$(cut -d: -f1 /etc/passwd | grep jbodden)
echo "$USR2 $KEYSTAT $ACCESS"
exit


