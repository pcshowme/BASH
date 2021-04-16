<<<<<<< HEAD
#!/bin/bash

#/**************************************************
#
#	Linux Server BASH script
#	(Written for SuSE 10.x & 11.x)
#
#	Script: Syslog functionality check -- Version 1.27
#	Created by the Jim Bodden -- 5/09/2013
#	Last Modified by Jim Bodden on -- 5/10/2013
#
#/**************************************************

#/**************************************************
#	Declarations, functions & setup...
#/**************************************************

SLRS="no"		# SysLog ReStart needed variable

proctest ()		# Test syslog daemon status
{ OUTPUT=$(/etc/init.d/syslog status)
  TEST="running"
  echo $OUTPUT | grep $TEST > null
  if [ $? -eq 0 ]
  then 
        # syslog is running
        SLRS="no"
  else
        # echo LUM is NOT running
        SLRS="yes"
  fi
} # End of PROCTEST function

logit ()		# Set baseline timestamp for logging and comparison verification
{ TIMESTAMP=`date`
  logger "syslog FVC -- $TIMESTAMP"		# FVC = "Functionality Verification Check"
} # End of LOGIT function

compit ()		# COMPARE the end of the /var/log/messages file to see if the FVC is present
{ COMP=`grep "$TIMESTAMP" /var/log/messages`
  if [[ "$COMP" == *FVC* ]]
  then
		# The syslog functions are running properly.
		SLRS="no"
  else
		# The syslog daemon is either not running or not running correctly -- syslog restart needed.
		SLRS="yes"
  fi
} # End of COMPIT function

startit()
{ if [ "$SLRS" = "yes" ] ; then
        /etc/init.d/syslog restart
fi
}

#/**************************************************
#	syslog FVC application start
#/**************************************************

proctest
logit
compit
startit

exit
=======
#!/bin/bash

#/**************************************************
#
#	Linux Server BASH script
#	(Written for SuSE 10.x & 11.x)
#
#	Script: Syslog functionality check -- Version 1.27
#	Created by the Jim Bodden -- 5/09/2013
#	Last Modified by Jim Bodden on -- 5/10/2013
#
#/**************************************************

#/**************************************************
#	Declarations, functions & setup...
#/**************************************************

SLRS="no"		# SysLog ReStart needed variable

proctest ()		# Test syslog daemon status
{ OUTPUT=$(/etc/init.d/syslog status)
  TEST="running"
  echo $OUTPUT | grep $TEST > null
  if [ $? -eq 0 ]
  then 
        # syslog is running
        SLRS="no"
  else
        # echo LUM is NOT running
        SLRS="yes"
  fi
} # End of PROCTEST function

logit ()		# Set baseline timestamp for logging and comparison verification
{ TIMESTAMP=`date`
  logger "syslog FVC -- $TIMESTAMP"		# FVC = "Functionality Verification Check"
} # End of LOGIT function

compit ()		# COMPARE the end of the /var/log/messages file to see if the FVC is present
{ COMP=`grep "$TIMESTAMP" /var/log/messages`
  if [[ "$COMP" == *FVC* ]]
  then
		# The syslog functions are running properly.
		SLRS="no"
  else
		# The syslog daemon is either not running or not running correctly -- syslog restart needed.
		SLRS="yes"
  fi
} # End of COMPIT function

startit()
{ if [ "$SLRS" = "yes" ] ; then
        /etc/init.d/syslog restart
fi
}

#/**************************************************
#	syslog FVC application start
#/**************************************************

proctest
logit
compit
startit

exit
>>>>>>> origin/master
