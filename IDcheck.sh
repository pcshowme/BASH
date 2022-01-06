#!/bin/bash
# IDcheck.sh -- Created by Jim Bodden 12/09/2014 -- Modified on: 3/20/2015
VERSION='IDcheck.sh--Version-1.29'
#
# Goal: Create a listing of -- Hostnames, User, ID, Type, Last-Login, Attempts, Locked-Status, Utilized, Expires, Keys?
# This is the first version of this program, it will be utilized fairly regularly, however will be upgraded in funcionality.
# Fields; AGENCY <vlookup)	SERVER	USER	ID	AUTH TYPE	LAST LOGIN	FAILED ATTEMPTS	LOCKED CHANGE USED
# Tested WINBIND on TWC4SVTST03 204.67.172.27 -- Tested NIS on racprd03 163.234.16.157

#*****************************
# Functions
#-----------------------------	
f_nmonth () # Function to convert Month strings to numbers ( i.e Jan = 01 )
{
	# Array of Months (Input $TMONTH / Output $NMONTH)
	MONTHS=( "Jan:01" "Feb:02" "Mar:03" "Apr:04" "May:05" "Jun:06" "Jul:07" "Aug:08" "Sep:09" "Oct:10" "Nov:11" "Dec:12" )
	for TMONTH in "${MONTHS[@]}" ; do
        KEY="${TMONTH%%:*}"
        VALUE="${TMONTH##*:}"
        if [[ $1 == $KEY ]]; then NMONTH=$VALUE; fi
	done
} # End of f_nmonth function

#*****************************
# Setup 
#-----------------------------
declare -i X Z BADLOGS
X=0
declare -a ULIST=( jbodden bferguson dmcdonald dwilton jwood tsawyer adish achakra grantz parkerj mjesionowski russellb srn savithas yroach mmillhou tftadmin root)
OLDIFS=$IFS; IFS=$','
declare -a UNAME=( "Jim.Bodden" "Bill.Ferguson" "Diane.Mcdonald" "Dwayne.Wilton" "Joseph.Wood" "Ty.Sawyer" "Adish.Kandalgaonkar" "Animesh.Chakraborty" "Jason.Grantz" "John.Parker" "Marcin.Jesionowski" "Russell.Becker" "Srini.Nagapuri" "Savitha.Srinivasulu" "Yvonne.Roach" "Matthew.Millhouse" tftadmin root)
IFS=$OLDIFS
CMDSHELL="$(echo $SHELL | awk -F'/' '{print $NF}')"
SERVER="$(hostname | cut -d. -f1)"
2>/dev/null rm -f /tmp/IDtest.tmp; 2>/dev/null rm -f /tmp/IDtest.csv; touch /tmp/IDtest.tmp; touch IDtest.csv

#*****************************
# Testing for Supported Authentication Methods...
#-----------------------------
NIS=" "; if [[ "$(2>/dev/null ypwhich | grep -i -v 'ypwhich')" ]]; then NIS="NIS"; fi
WAD=" "; if [[ "$(2>/dev/null wbinfo -t | grep -w succeeded)" == "succeeded" ]]; then WAD="WinBind"; fi
LUM=" "; if [[ "$(2>/dev/null rcnamcd status)" ]]; then LUM="eDirectory"; fi 
echo "$VERSION,$SERVER,Authentication Methods,Local,$NIS,$WAD,$LUM" #> /tmp/IDtest.tmp

#*****************************
# Processing User's (ULIST) for account information 
#-----------------------------
for USR in "${ULIST[@]}"
do
	LOC=0; NIS=0; WAD=0; OES=0; UGLOB=0; TYPE="n/a",LOGDATE1="n/a",BADLOGS=0,STATUS="n/a",USED="n/a",EXPIRES="n/a"
	
#*****************************
# Testing for Local Account Info
#-----------------------------	
	if [[ "$(2>/dev/null grep -w $USR /etc/passwd)" ]]; 
	then
		TYPE="Local"
		UGLOB=1
#*****************************
##### Testing if the account was ever used
#-----------------------------	
		if [[ "$(2>/dev/null chage -l $USR | grep forced)" ]]; 
		then
			USED="No"
		else
			USED="Yes"
		fi
#*****************************
##### Testing for Local Account LAST LOGIN date  -- PROBLEM is ROOT has less fields, need to return part of line begining at date or something...
#-----------------------------
		if [[ "$(2>/dev/null last -F -n1 $USR | sed 's/wtmp.*//')" ]];
		then
# old		2>/dev/null LOGDATE=$(2>/dev/null last -F -n1 $USR | sed 's/wtmp.*//' | tr -s " " | cut -d" " -f5,6,8); LOGDATE1="$(2>/dev/null date -d"$LOGDATE" +%m/%d/%Y)"
			 LOGDATE=$(last -F -1 jbodden | 2>/dev/null grep -o "[SMTWF][heroua][duinet].*$"); LOGDATE1="$(echo $LOGDATE | cut -d" " -f2,3,5)"; TMONTH="$(echo $LOGDATE1 | cut -d" " -f1)"; LASTDAY="$(echo $LOGDATE1 | cut -d" " -f2)"; LASTYEAR="$(echo $LOGDATE1 | cut -d" " -f3)"
			 f_nmonth $TMONTH $NMONTH; LOGDATE1="$(echo $NMONTH/$LASTDAY/$LASTYEAR)"
		else
			LOGDATE1="Unk"
		fi

#*****************************
##### Testing for Local Account Incorrect Login Info 
#-----------------------------	
		BADLOGS="$(faillog -a | grep $USR | awk '{ print $2 }')"
		if [ $BADLOGS -gt 0 ]; then Z=0; else BADLOGS=0; fi
		if [[ $UGLOB -eq 1 ]]
		then
			if [[ "$(passwd -S $USR | grep -w locked)" ]]
			then 
				STATUS="LOCKED"
			elif [[ "$(passwd -S $USR | grep -w LK)" ]]
			then 
				STATUS="LOCKED"
			else
				STATUS="Enabled"
			fi
		else
			STATUS="n/a"
		fi

#*****************************
##### Find Local Account Password experation/change date
#-----------------------------
		EXPDATE="$(chage -l $USR | grep 'Password Expires' | awk '{ print $3" " $4" "$5 }')"
		TMONTH="$(echo $EXPDATE | awk '{ print $1 }')"; 
		if [[ $TMONTH != "Never" ]] 
		then
			EXPDAY="$(echo $EXPDATE | awk '{ print $2 }' | tr -d ',')" 
			EXPYR="$(echo $EXPDATE | awk '{ print $3 }')"
			f_nmonth $TMONTH $NMONTH
			EXPIRES="$(echo $NMONTH/$EXPDAY/$EXPYR)"
		else
			EXPIRES="Never"
		fi
	else # Finish testing for Local Account Info but founf no Local ID
		TYPE="NO-ID"; EXPIRES="n/a"; STATUS="n/a"; USED="n/a"
	fi

#*****************************
# Testing for NIS Account
#-----------------------------	
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null ypwhich | grep -i -v 'ypwhich')" ]]
		then
			if [[ "$(2>/dev/null ypcat passwd | grep $USR)" ]]; 
			then
				TYPE="NIS"
				LOGDATE1="Unk"
				UGLOB=1
			else
				TYPE="NO-ID"
			fi
		fi
	fi
		
#*****************************
# Testing for winbind AD Account
#-----------------------------
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null wbinfo -t | grep -w succeeded)" == "succeeded" ]];
		then
			if [[ "$(2>/dev/null wbinfo -u | grep $USR)" ]];
			then
				TYPE="WinBind"
				LOGDATE1="Unk"
				UGLOB=1
			else
				TYPE="NO-ID "
			fi
		fi
	fi
	
#*****************************
# Testing for OES eDirectory Account???
#-----------------------------			
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null id $USR)" ]];
		then
			TYPE="OES"
			LOGDATE1="Unk"
			OES=1; UGLOB=1
		else  
			TYPE="NO or n/s ID"
			LOGDATE1="n/a"
		fi
	fi


#*****************************
# Create Output CSV File
#-----------------------------
	echo "$SERVER,${UNAME[$X]},$USR,$TYPE,$LOGDATE1,$BADLOGS,$STATUS,$USED,$EXPIRES" #>> /tmp/IDtest.tmp
	X=$X+1
done
echo "Finished"
exit 0
#!/bin/bash
# IDcheck.sh -- Created by Jim Bodden 12/09/2014 -- Modified on: 3/20/2015
VERSION='IDcheck.sh--Version-1.29'
#
# Goal: Create a listing of -- Hostnames, User, ID, Type, Last-Login, Attempts, Locked-Status, Utilized, Expires, Keys?
# This is the first version of this program, it will be utilized fairly regularly, however will be upgraded in funcionality.
# Fields; AGENCY <vlookup)	SERVER	USER	ID	AUTH TYPE	LAST LOGIN	FAILED ATTEMPTS	LOCKED CHANGE USED
# Tested WINBIND on TWC4SVTST03 204.67.172.27 -- Tested NIS on racprd03 163.234.16.157

#*****************************
# Functions
#-----------------------------	
f_nmonth () # Function to convert Month strings to numbers ( i.e Jan = 01 )
{
	# Array of Months (Input $TMONTH / Output $NMONTH)
	MONTHS=( "Jan:01" "Feb:02" "Mar:03" "Apr:04" "May:05" "Jun:06" "Jul:07" "Aug:08" "Sep:09" "Oct:10" "Nov:11" "Dec:12" )
	for TMONTH in "${MONTHS[@]}" ; do
        KEY="${TMONTH%%:*}"
        VALUE="${TMONTH##*:}"
        if [[ $1 == $KEY ]]; then NMONTH=$VALUE; fi
	done
} # End of f_nmonth function

#*****************************
# Setup 
#-----------------------------
declare -i X Z BADLOGS
X=0
declare -a ULIST=( jbodden bferguson dmcdonald dwilton jwood tsawyer adish achakra grantz parkerj mjesionowski russellb srn savithas yroach mmillhou tftadmin root)
OLDIFS=$IFS; IFS=$','
declare -a UNAME=( "Jim.Bodden" "Bill.Ferguson" "Diane.Mcdonald" "Dwayne.Wilton" "Joseph.Wood" "Ty.Sawyer" "Adish.Kandalgaonkar" "Animesh.Chakraborty" "Jason.Grantz" "John.Parker" "Marcin.Jesionowski" "Russell.Becker" "Srini.Nagapuri" "Savitha.Srinivasulu" "Yvonne.Roach" "Matthew.Millhouse" tftadmin root)
IFS=$OLDIFS
CMDSHELL="$(echo $SHELL | awk -F'/' '{print $NF}')"
SERVER="$(hostname | cut -d. -f1)"
2>/dev/null rm -f /tmp/IDtest.tmp; 2>/dev/null rm -f /tmp/IDtest.csv; touch /tmp/IDtest.tmp; touch IDtest.csv

#*****************************
# Testing for Supported Authentication Methods...
#-----------------------------
NIS=" "; if [[ "$(2>/dev/null ypwhich | grep -i -v 'ypwhich')" ]]; then NIS="NIS"; fi
WAD=" "; if [[ "$(2>/dev/null wbinfo -t | grep -w succeeded)" == "succeeded" ]]; then WAD="WinBind"; fi
LUM=" "; if [[ "$(2>/dev/null rcnamcd status)" ]]; then LUM="eDirectory"; fi 
echo "$VERSION,$SERVER,Authentication Methods,Local,$NIS,$WAD,$LUM" #> /tmp/IDtest.tmp

#*****************************
# Processing User's (ULIST) for account information 
#-----------------------------
for USR in "${ULIST[@]}"
do
	LOC=0; NIS=0; WAD=0; OES=0; UGLOB=0; TYPE="n/a",LOGDATE1="n/a",BADLOGS=0,STATUS="n/a",USED="n/a",EXPIRES="n/a"
	
#*****************************
# Testing for Local Account Info
#-----------------------------	
	if [[ "$(2>/dev/null grep -w $USR /etc/passwd)" ]]; 
	then
		TYPE="Local"
		UGLOB=1
#*****************************
##### Testing if the account was ever used
#-----------------------------	
		if [[ "$(2>/dev/null chage -l $USR | grep forced)" ]]; 
		then
			USED="No"
		else
			USED="Yes"
		fi
#*****************************
##### Testing for Local Account LAST LOGIN date  -- PROBLEM is ROOT has less fields, need to return part of line begining at date or something...
#-----------------------------
		if [[ "$(2>/dev/null last -F -n1 $USR | sed 's/wtmp.*//')" ]];
		then
# old		2>/dev/null LOGDATE=$(2>/dev/null last -F -n1 $USR | sed 's/wtmp.*//' | tr -s " " | cut -d" " -f5,6,8); LOGDATE1="$(2>/dev/null date -d"$LOGDATE" +%m/%d/%Y)"
			 LOGDATE=$(last -F -1 jbodden | 2>/dev/null grep -o "[SMTWF][heroua][duinet].*$"); LOGDATE1="$(echo $LOGDATE | cut -d" " -f2,3,5)"; TMONTH="$(echo $LOGDATE1 | cut -d" " -f1)"; LASTDAY="$(echo $LOGDATE1 | cut -d" " -f2)"; LASTYEAR="$(echo $LOGDATE1 | cut -d" " -f3)"
			 f_nmonth $TMONTH $NMONTH; LOGDATE1="$(echo $NMONTH/$LASTDAY/$LASTYEAR)"
		else
			LOGDATE1="Unk"
		fi

#*****************************
##### Testing for Local Account Incorrect Login Info 
#-----------------------------	
		BADLOGS="$(faillog -a | grep $USR | awk '{ print $2 }')"
		if [ $BADLOGS -gt 0 ]; then Z=0; else BADLOGS=0; fi
		if [[ $UGLOB -eq 1 ]]
		then
			if [[ "$(passwd -S $USR | grep -w locked)" ]]
			then 
				STATUS="LOCKED"
			elif [[ "$(passwd -S $USR | grep -w LK)" ]]
			then 
				STATUS="LOCKED"
			else
				STATUS="Enabled"
			fi
		else
			STATUS="n/a"
		fi

#*****************************
##### Find Local Account Password experation/change date
#-----------------------------
		EXPDATE="$(chage -l $USR | grep 'Password Expires' | awk '{ print $3" " $4" "$5 }')"
		TMONTH="$(echo $EXPDATE | awk '{ print $1 }')"; 
		if [[ $TMONTH != "Never" ]] 
		then
			EXPDAY="$(echo $EXPDATE | awk '{ print $2 }' | tr -d ',')" 
			EXPYR="$(echo $EXPDATE | awk '{ print $3 }')"
			f_nmonth $TMONTH $NMONTH
			EXPIRES="$(echo $NMONTH/$EXPDAY/$EXPYR)"
		else
			EXPIRES="Never"
		fi
	else # Finish testing for Local Account Info but founf no Local ID
		TYPE="NO-ID"; EXPIRES="n/a"; STATUS="n/a"; USED="n/a"
	fi

#*****************************
# Testing for NIS Account
#-----------------------------	
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null ypwhich | grep -i -v 'ypwhich')" ]]
		then
			if [[ "$(2>/dev/null ypcat passwd | grep $USR)" ]]; 
			then
				TYPE="NIS"
				LOGDATE1="Unk"
				UGLOB=1
			else
				TYPE="NO-ID"
			fi
		fi
	fi
		
#*****************************
# Testing for winbind AD Account
#-----------------------------
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null wbinfo -t | grep -w succeeded)" == "succeeded" ]];
		then
			if [[ "$(2>/dev/null wbinfo -u | grep $USR)" ]];
			then
				TYPE="WinBind"
				LOGDATE1="Unk"
				UGLOB=1
			else
				TYPE="NO-ID "
			fi
		fi
	fi
	
#*****************************
# Testing for OES eDirectory Account???
#-----------------------------			
	if [[ $UGLOB -eq 0 ]]
	then
		if [[ "$(2>/dev/null id $USR)" ]];
		then
			TYPE="OES"
			LOGDATE1="Unk"
			OES=1; UGLOB=1
		else  
			TYPE="NO or n/s ID"
			LOGDATE1="n/a"
		fi
	fi


#*****************************
# Create Output CSV File
#-----------------------------
	echo "$SERVER,${UNAME[$X]},$USR,$TYPE,$LOGDATE1,$BADLOGS,$STATUS,$USED,$EXPIRES" #>> /tmp/IDtest.tmp
	X=$X+1
done
echo "Finished"
exit 0
