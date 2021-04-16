#!/bin/sh

#/******************************************************************************
#
#	BackSync.sh
#	Created to backup home computer system Jim-H-PC-D1 to server SG1 via rsync
#	Created: 1/19/2014
#	Modified: 1/22/2014
#
#/******************************************************************************

sleep 5
echo "Backing up _DATA-VAULT to SG1 ***** ***** *****" >> /var/log/rsync.$(date +%Y%m%d).log
rsync -avz --log-file="/var/log/rsync.$(date +%Y%m%d).log" /cygdrive/C/Users/Jim/Documents/_DATA-VAULT root@192.168.1.25:/home/backups/Jim-H-PC-D1/
echo "Backing up Pictures to SG1 ***** ***** *****" >> /var/log/rsync.$(date +%Y%m%d).log
rsync -avz --log-file="/var/log/rsync.$(date +%Y%m%d).log" /cygdrive/c/Users/Jim/Pictures root@192.168.1.25:/home/backups/Jim-H-PC-D1/
echo "Backing up Videos to SG1 ***** ***** *****" >> /var/log/rsync.$(date +%Y%m%d).log
rsync -avz --log-file="/var/log/rsync.$(date +%Y%m%d).log" /cygdrive/c/Users/Jim/Videos root@192.168.1.25:/home/backups/Jim-H-PC-D1/
echo "Backing up Music to SG1 ***** ***** *****" >> /var/log/rsync.$(date +%Y%m%d).log
rsync -avz --log-file="/var/log/rsync.$(date +%Y%m%d).log" /cygdrive/c/Users/Jim/Music root@192.168.1.25:/home/backups/Jim-H-PC-D1/
sleep 5 
exit
