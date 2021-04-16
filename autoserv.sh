<<<<<<< HEAD
#!/bin/bash

#/******************************************************************************
#
#   BASH Shell Script check if service is running properly and restart if necessary
#   In this scenario we are testing for the LUM namcd daemon
#   This script can be run via CRON every 30 +/- minutes as needed
#
#   Script: autoserv.bash -- Version 1.2
#   Created by Jim Bodden -- 8/6/2012
#   Modified on -- 8/19/2012
#
#/******************************************************************************

OUTPUT=$(rcnamcd status)
TEST="running"

echo $OUTPUT | grep $TEST > null
        if [ $? -eq 0 ]
        then
#                echo LUM is running
		exit
        else
#                echo LUM is NOT running
                rcnamcd restart
        fi
=======
#!/bin/bash

#/******************************************************************************
#
#   BASH Shell Script check if service is running properly and restart if necessary
#   In this scenario we are testing for the LUM namcd daemon
#   This script can be run via CRON every 30 +/- minutes as needed
#
#   Script: autoserv.bash -- Version 1.2
#   Created by Jim Bodden -- 8/6/2012
#   Modified on -- 8/19/2012
#
#/******************************************************************************

OUTPUT=$(rcnamcd status)
TEST="running"

echo $OUTPUT | grep $TEST > null
        if [ $? -eq 0 ]
        then
#                echo LUM is running
		exit
        else
#                echo LUM is NOT running
                rcnamcd restart
        fi
>>>>>>> origin/master
