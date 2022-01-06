#!/bin/bash

# This is a Novell Linux group user creation script 
# Modified on 10/23/2013

# See if this version of bash supports arrays.
WHOTEST[0]='test' || (echo 'Failure: arrays not supported in this version of bash.' && exit 2)

# Verify that have root priveleges
if [ $(id -u) -ne 0 ]; then
	echo "Only root may add a user to the system"
	exit 1
fi

# Define the users to be created - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
WHOLIST=(
'Bodden Jim ULN Novell jbodden 40104 xrxadmin 897/I/20538908/XRX/Bodden,Jim/ULN-SA'
'Ferguson Bill ULN Novell bferguson 40106 xrxadmin 897/I/20488806/XRX/Ferguson,Bill/ULN-SA'
'Jesionowski Marcin ULN Novell mjesionowski 40107 xrxadmin 897/I/20519921/XRX/Jesionowski,Marcin/ULN-SA'
'Matheny Douglas ULN Novell dmatheny 40108 xrxadmin 897/I/20487463/XRX/Matheny,Douglas/ULN-SA'
'McDonald Diane ULN Novell dmcdonald 40109 xrxadmin 897/I/11008024/XRX/McDonald,Diane/ULN-SA'
'Sawyer Tyson ULN Novell tsawyer 40110 xrxadmin 897/I/20559699/XRX/Sawyer,Tyson/ULN-SA'
'Wilton Dwayne ULN Novell dwilton 40111 xrxadmin 897/I/20488162/XRX/Wilton,Dwayne/ULN-SA'
'Wood Joseph ULN Novell jwood 40112 xrxadmin 897/I/20524788/XRX/Wood,Joseph/ULN-SA'
		)
# End of users to be created listing - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# Determin the number of users
COUNT=${#WHOLIST[@]}

#Add Xerox xrxadmin group
GROUPID="40000"
GROUP="xrxadmin"
groupadd -g $GROUPID $GROUP #Xerox OS admins
[ $? -eq 0 ] && echo "Group $GROUP has been added to system!" || echo "Group not added as it already exists"
                                                                                
# Create the user accounts
for((I=0;I<=($COUNT-1);++I)) do
	LNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f1)
	FNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f2)
	TEAM=$(echo ${WHOLIST[I]} | cut -d' ' -f3)
	OS=$(echo ${WHOLIST[I]} | cut -d' ' -f4)
	USERNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f5)
	USERID=$(echo ${WHOLIST[I]} | cut -d' ' -f6)
	GROUP=$(echo ${WHOLIST[I]} | cut -d' ' -f7)
	GECOS=$(echo ${WHOLIST[I]} | cut -d' ' -f8)
	
	if grep -q "$USERNAME" "/etc/passwd" ; then 
		echo "User $USERNAME exists already, skipping..."
	else
		useradd -u $USERID -g $GROUPID -d /home/$USERNAME -m -c "$FNAME $LNAME $GECOS" $USERNAME
		[ $? -eq 0 ] && echo "Account $USERNAME has been added to system!" || echo "Failed to add account: $USERNAME"
		echo "$USERNAME:$USERNAME$GROUP" | chpasswd
		chage -d 0 $USERNAME
	fi
done

exit 0

#!/bin/bash

# This is a Novell Linux group user creation script 
# Modified on 10/23/2013

# See if this version of bash supports arrays.
WHOTEST[0]='test' || (echo 'Failure: arrays not supported in this version of bash.' && exit 2)

# Verify that have root priveleges
if [ $(id -u) -ne 0 ]; then
	echo "Only root may add a user to the system"
	exit 1
fi

# Define the users to be created - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
WHOLIST=(
'Bodden Jim ULN Novell jbodden 40104 xrxadmin 897/I/20538908/XRX/Bodden,Jim/ULN-SA'
'Ferguson Bill ULN Novell bferguson 40106 xrxadmin 897/I/20488806/XRX/Ferguson,Bill/ULN-SA'
'Jesionowski Marcin ULN Novell mjesionowski 40107 xrxadmin 897/I/20519921/XRX/Jesionowski,Marcin/ULN-SA'
'Matheny Douglas ULN Novell dmatheny 40108 xrxadmin 897/I/20487463/XRX/Matheny,Douglas/ULN-SA'
'McDonald Diane ULN Novell dmcdonald 40109 xrxadmin 897/I/11008024/XRX/McDonald,Diane/ULN-SA'
'Sawyer Tyson ULN Novell tsawyer 40110 xrxadmin 897/I/20559699/XRX/Sawyer,Tyson/ULN-SA'
'Wilton Dwayne ULN Novell dwilton 40111 xrxadmin 897/I/20488162/XRX/Wilton,Dwayne/ULN-SA'
'Wood Joseph ULN Novell jwood 40112 xrxadmin 897/I/20524788/XRX/Wood,Joseph/ULN-SA'
		)
# End of users to be created listing - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# Determin the number of users
COUNT=${#WHOLIST[@]}

#Add Xerox xrxadmin group
GROUPID="40000"
GROUP="xrxadmin"
groupadd -g $GROUPID $GROUP #Xerox OS admins
[ $? -eq 0 ] && echo "Group $GROUP has been added to system!" || echo "Group not added as it already exists"
                                                                                
# Create the user accounts
for((I=0;I<=($COUNT-1);++I)) do
	LNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f1)
	FNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f2)
	TEAM=$(echo ${WHOLIST[I]} | cut -d' ' -f3)
	OS=$(echo ${WHOLIST[I]} | cut -d' ' -f4)
	USERNAME=$(echo ${WHOLIST[I]} | cut -d' ' -f5)
	USERID=$(echo ${WHOLIST[I]} | cut -d' ' -f6)
	GROUP=$(echo ${WHOLIST[I]} | cut -d' ' -f7)
	GECOS=$(echo ${WHOLIST[I]} | cut -d' ' -f8)
	
	if grep -q "$USERNAME" "/etc/passwd" ; then 
		echo "User $USERNAME exists already, skipping..."
	else
		useradd -u $USERID -g $GROUPID -d /home/$USERNAME -m -c "$FNAME $LNAME $GECOS" $USERNAME
		[ $? -eq 0 ] && echo "Account $USERNAME has been added to system!" || echo "Failed to add account: $USERNAME"
		echo "$USERNAME:$USERNAME$GROUP" | chpasswd
		chage -d 0 $USERNAME
	fi
done

exit 0

