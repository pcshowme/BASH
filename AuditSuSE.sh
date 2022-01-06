#!/bin/bash

#/******************************************************************************
#
#   Bash Script to gather the files needed for a basic SuSE Linux server audit,
#   gather them in to a simple tar archive and FTP them to a central location.
#
VERSION='Script: AuditSuSE.sh -- Version 1.12'
#   Created by Jim Bodden -- 6/12/2013
#   Modified by Jim Bodden on -- 6/12/2013
##   The improvements in this version are commented with ## as opposed to only #
#
##	1. /etc/passwd   
##	2. /etc/sudoers   
##	3. /etc/group      
##	4. /etc/login.defs     
##	5. /etc/pam.d/common-password     
##	6. /etc/pam.d/common-auth       
##	7. /etc/default/useradd   

#/******************************************************************************

FILENAME="AuditFiles_`/bin/hostname`_`date +%F`_`date +%H%M`.tar"
DIRNAME="AuditFiles_`/bin/hostname`_`date +%F`_`date +%H%M`"

mkdir /$DIRNAME
cd /$DIRNAME


cp /etc/passwd /$DIRNAME
cp /etc/sudoers /$DIRNAME
cp /etc/group /$DIRNAME
cp /etc/login.defs /$DIRNAME
cp /etc/pam.d/common-password /$DIRNAME
cp /etc/pam.d/common-auth /$DIRNAME
cp /etc/default/useradd /$DIRNAME

tar -cvf /root/Documents/$FILENAME /$DIRNAME

################################
# Transffer output file to 168.44.244.237
################################
FTP_HOST=168.44.244.237
FTP_LOGIN=AuditLog
FTP_PASSWORD=passwd
ftp -inv $FTP_HOST<<ENDFTP
user $FTP_LOGIN $FTP_PASSWORD
lcd /root/Documents
put $FILENAME
bye
ENDFTP

exit 0
#!/bin/bash

#/******************************************************************************
#
#   Bash Script to gather the files needed for a basic SuSE Linux server audit,
#   gather them in to a simple tar archive and FTP them to a central location.
#
VERSION='Script: AuditSuSE.sh -- Version 1.12'
#   Created by Jim Bodden -- 6/12/2013
#   Modified by Jim Bodden on -- 6/12/2013
##   The improvements in this version are commented with ## as opposed to only #
#
##	1. /etc/passwd   
##	2. /etc/sudoers   
##	3. /etc/group      
##	4. /etc/login.defs     
##	5. /etc/pam.d/common-password     
##	6. /etc/pam.d/common-auth       
##	7. /etc/default/useradd   

#/******************************************************************************

FILENAME="AuditFiles_`/bin/hostname`_`date +%F`_`date +%H%M`.tar"
DIRNAME="AuditFiles_`/bin/hostname`_`date +%F`_`date +%H%M`"

mkdir /$DIRNAME
cd /$DIRNAME


cp /etc/passwd /$DIRNAME
cp /etc/sudoers /$DIRNAME
cp /etc/group /$DIRNAME
cp /etc/login.defs /$DIRNAME
cp /etc/pam.d/common-password /$DIRNAME
cp /etc/pam.d/common-auth /$DIRNAME
cp /etc/default/useradd /$DIRNAME

tar -cvf /root/Documents/$FILENAME /$DIRNAME

################################
# Transffer output file to 168.44.244.237
################################
FTP_HOST=168.44.244.237
FTP_LOGIN=AuditLog
FTP_PASSWORD=passwd
ftp -inv $FTP_HOST<<ENDFTP
user $FTP_LOGIN $FTP_PASSWORD
lcd /root/Documents
put $FILENAME
bye
ENDFTP

exit 0
