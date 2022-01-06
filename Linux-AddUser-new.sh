#!/bin/bash

#/******************************************************************************
#
#   Bash Script Linux-AddUser.sh to validate/create login ID's and validate/create ssh keys.
#   
#   The pertinent information includes;
#   - Can be run on BigFix or a stand alone server
#	- Identify the authentication method(s); Local, OES, NIS, Kerberos 
#   - There are 3 associated data files; agency.dat, access-linux.dat & user-linux.dat
#	-- Deternins the agency this server is at based on the hostname
#	-- Determins if the server is using NIS authentications and if so exits
#	-- Determins whom in the Linux group is authorized to have access at this agency
#	- Act on the viable ID's to verify and create proper key infrastructure
#
VERSION='Script: Linux-AddUser.sh -- Version 1.23'
#   Created by Jim Bodden -- 8/16/2014
#   Modified on -- 8/17/2014
#
##		The improvements in this version are commented with ## as opposed to only #
##		- This section not for use until after the first release date.
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

FILENAME1="/tmp/Linux-AddUaser_`/bin/hostname`_`date +%F`_`date +%H%M`.txt"
FILENAME2="Linux-AddUaser_`/bin/hostname`_`date +%F`_`date +%H%M`.tmp"
echo |tee $FILENAME1
echo |tee -a $FILENAME1

crtuser ()	# Create Local User
{ 
	useradd -u $USERID -g $GRPID -d /home/$UNAME -m -c "$first_name $last_name $gecos" $UNAME
	[ $? -eq 0 ] && echo "Account $username has been added to system!" || echo "Failed to add account: $username"
	echo "$username:$username$agency" | chpasswd
	chage -d 0 $username
} # End of PADDING function 

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
# Determin Agency from hostnme using agency.dat
#/------------------------------------------------------------------------------
SERVER=`hostname`; AGENCY=`grep $SERVER /tmp/agency.dat | cut -d, -f2`
echo "This agency is $AGENCY"
echo " "

#/******************************************************************************
# Determin if the server is using NIS authentication
#/------------------------------------------------------------------------------
2>/dev/null 1>/dev/null ypwhich
if [ $? -eq 0 ]; then
    echo "This server is using NIS authentication, exiting...";exit
fi
echo "This server is NOT using NIS authentication, begining next phase..."
echo " "

#/******************************************************************************
# Determin who is authorized for access from access-linux.dat
#/------------------------------------------------------------------------------
OIFS=$IFS
IFS=,
ACCESS1=`grep -i $AGENCY /tmp/access-linux.dat`
echo $ACCESS1
declare -a AUTH1=($ACCESS1);
for ((i=1; i<${#AUTH1[@]}; ++i));
do
    echo "Authorized $i: ${AUTH1[$i]}";
done
IFS=$OLDIFS
echo " "

#/******************************************************************************
# Validate/Create authorized users for access from user-linux.dat
#/------------------------------------------------------------------------------
# Validate/Create Group
#
SGROUP=$(cat /etc/group | grep -w "40000" | cut -d: -f1)
if [ -n $SGROUP ]; then
	echo "matched";
else
	echo "no match";
	groupadd -g 40000 xrxadmin #Xerox OS admins
	SGROUP="xrxadmin"
fi

OIFS=$IFS
INPUT=/tmp/user-linux.dat
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read LNAME FNAME TEAM TGROUP UNAME USERID GRPNAME GRPID GECOS
do
	if echo "$ACCESS1" | grep -q "$FNAME"; then
		echo "User Name : $UNAME"
#		echo "User ID : $USERID"
#		echo "Group Name : $GRPNAME"
#		echo "Group ID : $GRPID"
#		echo "Gecos : $GECOS"



		UVALID=$(cut -d: -f1 /etc/passwd | grep $UNAME)
		if [[ "$UVALID" == *jbodden* ]]; then
			if [ ! -d /home/$UNAME/.ssh ]; then
				mkdir /home/$UNAME/.ssh
				chown $UNAME:$GRP /home/jbodden/.ssh
				chmod 700 /home/$UNAME/.ssh
				keys
				KEYSTAT="Created-Key"
			elif
				keys
				KEYSTAT="Re-Keyed"
			fi
		elif

			#Create user



	fi
done < $INPUT
IFS=$OLDIFS
echo " "

exit
#!/bin/bash

#/******************************************************************************
#
#   Bash Script Linux-AddUser.sh to validate/create login ID's and validate/create ssh keys.
#   
#   The pertinent information includes;
#   - Can be run on BigFix or a stand alone server
#	- Identify the authentication method(s); Local, OES, NIS, Kerberos 
#   - There are 3 associated data files; agency.dat, access-linux.dat & user-linux.dat
#	-- Deternins the agency this server is at based on the hostname
#	-- Determins if the server is using NIS authentications and if so exits
#	-- Determins whom in the Linux group is authorized to have access at this agency
#	- Act on the viable ID's to verify and create proper key infrastructure
#
VERSION='Script: Linux-AddUser.sh -- Version 1.23'
#   Created by Jim Bodden -- 8/16/2014
#   Modified on -- 8/17/2014
#
##		The improvements in this version are commented with ## as opposed to only #
##		- This section not for use until after the first release date.
#/******************************************************************************

#/******************************************************************************
# Declaraitions, functions & setup...
#/******************************************************************************

FILENAME1="/tmp/Linux-AddUaser_`/bin/hostname`_`date +%F`_`date +%H%M`.txt"
FILENAME2="Linux-AddUaser_`/bin/hostname`_`date +%F`_`date +%H%M`.tmp"
echo |tee $FILENAME1
echo |tee -a $FILENAME1

crtuser ()	# Create Local User
{ 
	useradd -u $USERID -g $GRPID -d /home/$UNAME -m -c "$first_name $last_name $gecos" $UNAME
	[ $? -eq 0 ] && echo "Account $username has been added to system!" || echo "Failed to add account: $username"
	echo "$username:$username$agency" | chpasswd
	chage -d 0 $username
} # End of PADDING function 

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
# Determin Agency from hostnme using agency.dat
#/------------------------------------------------------------------------------
SERVER=`hostname`; AGENCY=`grep $SERVER /tmp/agency.dat | cut -d, -f2`
echo "This agency is $AGENCY"
echo " "

#/******************************************************************************
# Determin if the server is using NIS authentication
#/------------------------------------------------------------------------------
2>/dev/null 1>/dev/null ypwhich
if [ $? -eq 0 ]; then
    echo "This server is using NIS authentication, exiting...";exit
fi
echo "This server is NOT using NIS authentication, begining next phase..."
echo " "

#/******************************************************************************
# Determin who is authorized for access from access-linux.dat
#/------------------------------------------------------------------------------
OIFS=$IFS
IFS=,
ACCESS1=`grep -i $AGENCY /tmp/access-linux.dat`
echo $ACCESS1
declare -a AUTH1=($ACCESS1);
for ((i=1; i<${#AUTH1[@]}; ++i));
do
    echo "Authorized $i: ${AUTH1[$i]}";
done
IFS=$OLDIFS
echo " "

#/******************************************************************************
# Validate/Create authorized users for access from user-linux.dat
#/------------------------------------------------------------------------------
# Validate/Create Group
#
SGROUP=$(cat /etc/group | grep -w "40000" | cut -d: -f1)
if [ -n $SGROUP ]; then
	echo "matched";
else
	echo "no match";
	groupadd -g 40000 xrxadmin #Xerox OS admins
	SGROUP="xrxadmin"
fi

OIFS=$IFS
INPUT=/tmp/user-linux.dat
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read LNAME FNAME TEAM TGROUP UNAME USERID GRPNAME GRPID GECOS
do
	if echo "$ACCESS1" | grep -q "$FNAME"; then
		echo "User Name : $UNAME"
#		echo "User ID : $USERID"
#		echo "Group Name : $GRPNAME"
#		echo "Group ID : $GRPID"
#		echo "Gecos : $GECOS"



		UVALID=$(cut -d: -f1 /etc/passwd | grep $UNAME)
		if [[ "$UVALID" == *jbodden* ]]; then
			if [ ! -d /home/$UNAME/.ssh ]; then
				mkdir /home/$UNAME/.ssh
				chown $UNAME:$GRP /home/jbodden/.ssh
				chmod 700 /home/$UNAME/.ssh
				keys
				KEYSTAT="Created-Key"
			elif
				keys
				KEYSTAT="Re-Keyed"
			fi
		elif

			#Create user



	fi
done < $INPUT
IFS=$OLDIFS
echo " "

exit
