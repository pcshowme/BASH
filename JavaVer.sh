<<<<<<< HEAD
#!/bin/bash

#/******************************************************************************
#
#   Bash Script to determin Java locations and versions
#   and log's it to a file /root/Documents/JavaVer_ServerName_Date.txt
#   This script also updates the /var/log/messages file that it has been run.
#
#
VERSION='Script: JavaVer.sh -- Version 2.31'
#   Created by Jim Bodden -- 1/15/2013
#   Modified on -- 1/15/2013
#
#/******************************************************************************
FILENAME1="/root/Documents/JavaINST"
FILENAME2="/root/Documents/JavaTEMP2"
FILENAME3="/root/Documents/JavaTEMP3"
FILENAME4="/root/Documents/JavaTEMP4"
FILENAME5="/root/Documents/ServerID.txt"
FILENAME6="/root/Documents/JavaVer_`/bin/hostname`_`date +%F`.txt"

echo
echo
echo
clear
echo
echo Detecting Java installations and versions...

#/******************************************************************************
# Discover Java locations on this server
#/******************************************************************************

find / -name 'java' | grep "bin/java" |tee -a $FILENAME1 
sed -e 's/$/ -version/' -i $FILENAME1

clear
echo
echo
echo
echo

#/******************************************************************************
# Document in /var/log/messages that this script has been run
#/******************************************************************************

# Logger Executed JavaVer.sh
##### logger $VERSION
echo '...........................................................................' |tee -a $FILENAME5
echo $VERSION 'Executed at;' `date` |tee $FILENAME5
echo '...........................................................................' |tee -a $FILENAME5
echo |tee -a $FILENAME5
echo |tee -a $FILENAME5

#/******************************************************************************
# Document the hostname, version & OES version if installed
#/******************************************************************************

echo '...........................................................................' |tee -a $FILENAME5
echo 'Server:' $HOSTNAME |tee -a $FILENAME5
echo '...........................................................................' |tee -a $FILENAME5
echo |tee -a $FILENAME5

if [ -f /etc/novell-release ];
then
   cat /etc/SuSE-release |tee -a $FILENAME5
   echo |tee -a $FILENAME5
   cat /etc/novell-release |tee -a $FILENAME5
   echo |tee -a $FILENAME5
else
   cat /etc/SuSE-release |tee -a $FILENAME5
   echo Novell OES is not installed on this server |tee -a $FILENAME5
   echo |tee -a $FILENAME5
fi

#/******************************************************************************
# Document Java installations and versions on this server
#/******************************************************************************

cat $FILENAME1 | while read line; do 
	echo $line |tee -a $FILENAME2
    eval $line 
    eval $line 2>> $FILENAME2
done

cat JavaTEMP | grep "version" $FILENAME2 > $FILENAME3
sed  'N;s/.*/&\n /' $FILENAME3 > $FILENAME4
cat $FILENAME5 $FILENAME4 > $FILENAME6
rm $FILENAME1 $FILENAME2 $FILENAME3 $FILENAME4 $FILENAME5
exit
=======
#!/bin/bash

#/******************************************************************************
#
#   Bash Script to determin Java locations and versions
#   and log's it to a file /root/Documents/JavaVer_ServerName_Date.txt
#   This script also updates the /var/log/messages file that it has been run.
#
#
VERSION='Script: JavaVer.sh -- Version 2.31'
#   Created by Jim Bodden -- 1/15/2013
#   Modified on -- 1/15/2013
#
#/******************************************************************************
FILENAME1="/root/Documents/JavaINST"
FILENAME2="/root/Documents/JavaTEMP2"
FILENAME3="/root/Documents/JavaTEMP3"
FILENAME4="/root/Documents/JavaTEMP4"
FILENAME5="/root/Documents/ServerID.txt"
FILENAME6="/root/Documents/JavaVer_`/bin/hostname`_`date +%F`.txt"

echo
echo
echo
clear
echo
echo Detecting Java installations and versions...

#/******************************************************************************
# Discover Java locations on this server
#/******************************************************************************

find / -name 'java' | grep "bin/java" |tee -a $FILENAME1 
sed -e 's/$/ -version/' -i $FILENAME1

clear
echo
echo
echo
echo

#/******************************************************************************
# Document in /var/log/messages that this script has been run
#/******************************************************************************

# Logger Executed JavaVer.sh
##### logger $VERSION
echo '...........................................................................' |tee -a $FILENAME5
echo $VERSION 'Executed at;' `date` |tee $FILENAME5
echo '...........................................................................' |tee -a $FILENAME5
echo |tee -a $FILENAME5
echo |tee -a $FILENAME5

#/******************************************************************************
# Document the hostname, version & OES version if installed
#/******************************************************************************

echo '...........................................................................' |tee -a $FILENAME5
echo 'Server:' $HOSTNAME |tee -a $FILENAME5
echo '...........................................................................' |tee -a $FILENAME5
echo |tee -a $FILENAME5

if [ -f /etc/novell-release ];
then
   cat /etc/SuSE-release |tee -a $FILENAME5
   echo |tee -a $FILENAME5
   cat /etc/novell-release |tee -a $FILENAME5
   echo |tee -a $FILENAME5
else
   cat /etc/SuSE-release |tee -a $FILENAME5
   echo Novell OES is not installed on this server |tee -a $FILENAME5
   echo |tee -a $FILENAME5
fi

#/******************************************************************************
# Document Java installations and versions on this server
#/******************************************************************************

cat $FILENAME1 | while read line; do 
	echo $line |tee -a $FILENAME2
    eval $line 
    eval $line 2>> $FILENAME2
done

cat JavaTEMP | grep "version" $FILENAME2 > $FILENAME3
sed  'N;s/.*/&\n /' $FILENAME3 > $FILENAME4
cat $FILENAME5 $FILENAME4 > $FILENAME6
rm $FILENAME1 $FILENAME2 $FILENAME3 $FILENAME4 $FILENAME5
exit
>>>>>>> origin/master
