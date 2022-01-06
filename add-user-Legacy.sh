#Bash script for Adding User Accounts

#!/bin/bash

if [ $(id -u) -ne 0 ]; then
        echo "Only root may add a user to the system"
        exit 1
fi

declare -a list=( TOOLS ASU DADS DARS DFPS DIR-A DSHS HHSC-A HHSC-E HPC OAG-AL OAG-CS RRC SOS TCEQ TDCJ TDI TDLR TEA TFC THECB TPWD TSLAC TWC TWDB TXDCS TXDMV TXDOT TXO )
echo "Please enter the agency ID:"
read x
        if [[ ${list[*]} =~ $x ]]; then
        echo "Adding $x Agency approved users"
     else
        echo "Not a valid agency ID"
        echo "Valid agency ID's are:"
        echo "${list[*]}"
        echo "Please try again"
        exit 1
        fi

#Add Xerox TxDIR groups
echo "Checking for necessary user groups..."
groupadd -g 40000 xrxadmin #Xerox OS admins
groupadd -g 42000 xrxmw #Middleware admins (all products)
groupadd -g 44000 xrxbur #Backup and Recovery Admins (BUR-all products)
groupadd -g 44100 burmon #Backup and Recovery Monitors (BUR Netbackup)
groupadd -g 46000 xrxdba #DBA's
groupadd -g 48000 xrxaim #IAM - ID and Access Management
groupadd -g 50000 nonadmin #Other Xerox accounts
groupadd -g 52000 xrxsan        #Xerox SAN admins

#Add SOT Agency groups
groupadd -g 36000 sotdba #Agency DBA's
groupadd -g 38000 sotadmin #Agency admins

#Add user account by reading from input file

   while read agency last_name first_name username userid groupid gecos;
        do
        if [[ "$agency" == "$x" ]]; then
                useradd -u $userid -g $groupid -d /home/$username -m -c "$first_name $last_name $gecos" $username
                [ $? -eq 0 ] && echo "Account $username has been added to system!" || echo "Failed to add account: $username"
                echo "$username:$username$agency" | chpasswd
                chage -d 0 $username
        fi
        done < agency_linux_list.txt
exit 0
#Bash script for Adding User Accounts

#!/bin/bash

if [ $(id -u) -ne 0 ]; then
        echo "Only root may add a user to the system"
        exit 1
fi

declare -a list=( TOOLS ASU DADS DARS DFPS DIR-A DSHS HHSC-A HHSC-E HPC OAG-AL OAG-CS RRC SOS TCEQ TDCJ TDI TDLR TEA TFC THECB TPWD TSLAC TWC TWDB TXDCS TXDMV TXDOT TXO )
echo "Please enter the agency ID:"
read x
        if [[ ${list[*]} =~ $x ]]; then
        echo "Adding $x Agency approved users"
     else
        echo "Not a valid agency ID"
        echo "Valid agency ID's are:"
        echo "${list[*]}"
        echo "Please try again"
        exit 1
        fi

#Add Xerox TxDIR groups
echo "Checking for necessary user groups..."
groupadd -g 40000 xrxadmin #Xerox OS admins
groupadd -g 42000 xrxmw #Middleware admins (all products)
groupadd -g 44000 xrxbur #Backup and Recovery Admins (BUR-all products)
groupadd -g 44100 burmon #Backup and Recovery Monitors (BUR Netbackup)
groupadd -g 46000 xrxdba #DBA's
groupadd -g 48000 xrxaim #IAM - ID and Access Management
groupadd -g 50000 nonadmin #Other Xerox accounts
groupadd -g 52000 xrxsan        #Xerox SAN admins

#Add SOT Agency groups
groupadd -g 36000 sotdba #Agency DBA's
groupadd -g 38000 sotadmin #Agency admins

#Add user account by reading from input file

   while read agency last_name first_name username userid groupid gecos;
        do
        if [[ "$agency" == "$x" ]]; then
                useradd -u $userid -g $groupid -d /home/$username -m -c "$first_name $last_name $gecos" $username
                [ $? -eq 0 ] && echo "Account $username has been added to system!" || echo "Failed to add account: $username"
                echo "$username:$username$agency" | chpasswd
                chage -d 0 $username
        fi
        done < agency_linux_list.txt
exit 0
