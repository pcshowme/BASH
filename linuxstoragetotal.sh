<<<<<<< HEAD
#!/bin/bash
#
# Linux Storage Billing Script for total space, shooting for simple, quick and accurate
VERSION='linuxstoragetotal.sh--Version-3.39'
# Created; 5/15/2015 by Jim Bodden  (based on linuxstoragecalc.sh Created; 5/15/2014)
# Modified; 12/02/2015 by Jim Bodden
# 
#
#*****************************  NOTES  *****************************
## Due to the way storage is computed with certain tools & OS's this sizes may differ slightly.
## 6/24/2015 -- This script has gone through several modifications in the past as new conditions were encountered.
## 6/24/2015 -- The v2.59 code is now being streamlined to efficiently consolidate the modifications layered on in the past.
## 6/25/2015 -- Added the f_mptest function with additional multipath testing
## 6/29/2015 -- Added support for SANTYPE, SANMOD, ASN & LDEV on HITACHI
## 7/18/2015 -- Adding tests & filtering for RAID1 per DIR as of Friday meeting -- f_mirror.
## 12/02/2015 -- Added routine to create /tmp/LSTmanual.lst-tmp to assist with manual validations
#*******************************************************************

f_diskinfo () # Gather Disk Names and Sizes Information ( This is performed for ALL Types...)
{ #echo f_diskinfo
	#*****************************
	# Populate arrays with FDISK info
	#-----------------------------
	ARRAY_DISKNAME=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk -F':' '{print $1}' | awk -F'/' '{print $NF}') )  ## DISK NAMES
	ARRAY_DISKNAMEPATH=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk -F':' '{print $1}' | awk -F' ' '{print $2}') )  ## DISK NAMES w/ paths
	ARRAY_DISKSIZE=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk '{print $5}') )        ## DISK BYTE SIZE
	DISKNAME_ARRAY_LENGTH=${#ARRAY_DISKNAME[@]}; DISKSIZE_ARRAY_LENGTH=${#ARRAY_DISKSIZE[@]}
	#*****************************
	# Calculate FDISK Attached sum -- $FDASUM and create /tmp/fdskdrive.lst-tmp
	#-----------------------------
	N=0; FDASUM=0; MPERR=0
	while [ $N -lt "$DISKSIZE_ARRAY_LENGTH" ]
	do 
	echo ${ARRAY_DISKNAME[$N]} ${ARRAY_DISKSIZE[$N]} >> /tmp/fdskdrive.lst-tmp
	if [[ $SAN -eq 1 && -e /sbin/HiScsiBinaryLinux ]]; then HiScsiBinaryLinux ${ARRAY_DISKNAMEPATH[$N]} > /tmp/${ARRAY_DISKNAME[$N]}.lst-tmp ;fi  ## For SAN Tesing
	let FDASUM+=${ARRAY_DISKSIZE[$N]}
	N=$((N+1))
	done
	TOTALSTORAGE=$FDASUM
} # End of f_diskinfo function

f_mprtnum ()
{ #echo f_mprtnum
	#*****************************
	# Calculate the number of multipath routes to each SAN LUN (i.e. 4 'drives' to 1 LUN)
	#-----------------------------
	if [[ -f /sbin/multipath && $(2>/dev/null /sbin/multipath -ll | grep -i 'size' | wc -l) -ne 0 ]]
	then
		MPUTIL=1
		/sbin/multipath -ll > /tmp/mp-ll.lst-tmp
		/sbin/multipath -ll | egrep -iv 'prio|size|mpath|robin' | grep -v '^$' > /tmp/mptotaldrives.lst-tmp
		/sbin/multipath -ll | egrep -iv 'prio|size' > /tmp/mprtdrives.lst-tmp
		MPENABLE=$(/sbin/multipath -ll | egrep -i 'robin' | egrep -i 'enabled' | wc -l) 
		MPACTIVE=$(/sbin/multipath -ll | egrep -i 'robin' | egrep -i 'active' | wc -l)
		MSANDRIVES=$(cat /tmp/mptotaldrives.lst-tmp | egrep -iv 'prio|size|mpath' | wc -l); MLUNS=$(multipath -ll | grep -i mpath | wc -l)
		if [[ $MPENABLE -gt 0 ]]; then MSANDRIVES=$((MSANDRIVES/2)); fi	
		if [[ $MPACTIVE -gt 0 ]]; then ROUTES=$((MSANDRIVES / MPACTIVE)); fi
		/sbin/multipath -ll | grep -i mpath | tr -d '()' | tr ',' ' ' | sort --field-separator=' ' -k1,1 -u | awk '{print $1" "$2}' > /tmp/mpathtemp.lst-tmp;  ## Create sort mpath table
		awk -F" " '{sub(/[3]/,"",$2)}1' OFS=" " /tmp/mpathtemp.lst-tmp > /tmp/mpathtable.lst-tmp
		TOTALDRIVES=$DISKNAME_ARRAY_LENGTH
#		echo "MPENABLE $MPENABLE MPACTIVE $MPACTIVE MSANDRIVES $MSANDRIVES ROUTES $ROUTES TOTALDRIVES $TOTALDRIVES"; read
	else
		MPUTIL=0
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 		
	fi
} # End of f_mprtnum function

f_legacy () # 
{ #echo f_legacy 
	#*****************************
	# Calculate Storage as reported prior to July 2015
	#-----------------------------

	# Calculate Total Storage
	#-----------------------------
	# Filter out device mapper and software RAID to eliminate duplication
	if [[ "$OUT2" == 1 ]]
	then
		TOTALSTORAGE=$(/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" |  egrep -iv "/dev/dm-" | awk '{total = total + $5} END {print total/1000/1000/1000}')
	else
		TOTALSTORAGE=$(/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" |  egrep -iv "/dev/dm-" | awk '{total = total + $5} END {print total}')
	fi

	# Calculate Allocated Storage   
	#-----------------------------
	if [[ "$OUT2" == 1 ]]
	then
		ALLOCATEDSTORAGE=$(/bin/df -lP | egrep -iv '/media/nss' | egrep -iv '/media/CDROM' | awk '{total += $2} END {print total/1000/1000}')
	else
		ALLOCATEDSTORAGE=$(/bin/df -lP | egrep -iv '/media/nss' | egrep -iv '/media/CDROM' | awk '{total += $2} END {print total*1000}')
	fi
	if [[ $SAN -eq 1 && $ROUTES -gt 0 ]]; then TOTALSTORAGE=$((TOTALSTORAGE/ROUTES)); fi
	LTS=$(printf '%.0f' $TOTALSTORAGE); LAS=$(printf '%.0f' $ALLOCATEDSTORAGE)
	TSG=$((LTS/1024/1024/1024))
	TSA=$((LAS/1024/1024/1024))
	echo "TOTALSTORAGE,$LTS,$TSG" |tee /tmp/LSTreport.lst-tmp
	echo "ALLOCATEDSTORAGE,$LAS,$TSA" |tee -a /tmp/LSTreport.lst-tmp
	exit 0
} # End of f_legacy function

f_extstore () # External/Shared Storage Identifier
{ #echo f_extstore
	#*****************************
	# Determine if this server is using external/shared storage mapped links
	#-----------------------------
	if [[ $(df -Pk|column -t | grep -iv filesystem | grep -iv tmpfs | grep -iv /dev/ | grep -iwv udev | grep -iv _admin) ]]; 
	then 
		EXTSTORE="YES" 
		df -Pk|column -t | grep -iv filesystem | grep -iv tmpfs | grep -iv /dev/ | grep -iwv udev | grep -iv nss | grep -iv admin > /tmp/ExtLinks1.lst-tmp
		awk '{print $1"," $2*1024}' /tmp/ExtLinks1.lst-tmp > /tmp/ExtLinks2.lst-tmp
		EXTTOTAL=$(cat /tmp/ExtLinks2.lst-tmp | awk -F',' '{sum+=$2} END {print sum}')
	else
	EXTSTORE="NO"
	EXTTOTAL=0
	echo "No External/Shared storage" > /tmp/ExtLinks2.lst-tmp
fi
}  ## End of f_extstore function

f_hiscsi () # Gather third party utility HiScsiBinaryLinux information into disk named temp files
{ #echo f_hiscsi
	while read LINE     ## HiScsiBinaryLinux Parsing
	do
		HDRV=$(echo $LINE | awk '{print $4}')
		if [[ -f /tmp/$HDRV.lst-tmp ]]
		then
			SANTYPE=$(cat /tmp/$HDRV.lst-tmp | grep "Manufacturer" | awk -F'= ' '{ print $2}'); if [ $SANTYPE = DGC ]; then SANTYPE="EMC"; fi
			if [[ $SANTYPE = *HITACHI* ]] 
			then 
				SANMOD=$(cat /tmp/$HDRV.lst-tmp | grep "Model Type" | awk -F'= ' '{ print $2}')
				LDEV=$(cat /tmp/$HDRV.lst-tmp | grep "Logical Unit Number" | awk -F'= ' '{ print $2}')
				ASN=$(cat /tmp/$HDRV.lst-tmp | grep "Storage Box Number" | awk -F'= ' '{ print $2}')
			elif [[ $SANTYPE=*EMC* ]]
			then
				SANMOD=$(cat /tmp/$HDRV.lst-tmp | grep "Storage Box Model" | awk -F'= ' '{ print $2}' | tr ' ' - | awk -F'-' '{print $NF}')
				LDEV="N/A"
				ASN=$(cat /tmp/$HDRV.lst-tmp | grep "Device Unit Serial Number" | awk -F'= ' '{ print $2}')				
			else
				SANMOD=$SANTYPE; LDEV="N/A"; ASN="N/A"
			fi
			[[ -z "$SANTYPE" ]] && SANTYPE="Unk"; [[ -z "$SANMOD" ]] && SANMOD="Unk"; [[ -z "$LDEV" ]] && LDEV="Unk"; [[ -z "$ASN" ]] && ASN="Unk"; 
			echo "$SANTYPE $SANMOD $LDEV $ASN $LINE" >> /tmp/santable2.lst-tmp
		else
			SANFO="HiScsiBinaryLinux Utility Here Missing"
			echo "$SANFO $LINE" >> /tmp/santable2.lst-tmp 
		fi
	done < /tmp/santable1.lst-tmp
} # End of f_hiscsi function

f_mptest () # Additional multipath testing to verify it it is working correctly
{ #echo f_mptest
	if [[ SAN -eq 1 ]]
	then
		if [[ -f /tmp/LOCSTORE.lst-tmp ]]
		then
			while read LINE
			do
				LOCDRVTEST=$(echo $LINE | awk -F',' '{print $1}') 
				if [[ -e /tmp/$LOCDRVTEST.lst-tmp ]]
				then 
					SMODEL1=$(cat /tmp/$LOCDRVTEST.lst-tmp | grep 'Model Type' | awk -F'= ' '{print $2}')
					SMODEL2=$(cat /tmp/$LOCDRVTEST.lst-tmp | grep 'Storage Box Model' | awk -F'= ' '{print $2}')
					MOD1=$(echo $SMODEL1 | egrep --quiet '5100|hsv200|1814|2145|VRAID|OPEN-V' | wc -c)
					MOD2=$(echo $SMODEL2 | egrep --quiet 'EMC|Hitachi' | wc -c)
					if [[ $MOD1 -gt 0 ]] || [[ $MOD2 -gt 0 ]] 
					then 
						MPERR=1
						echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
						echo "MP ERR Local Drive $LOCDRVTEST is SAN" >> /tmp/MPissue.lst-tmp
					fi
				fi
			done < /tmp/LOCSTORE.lst-tmp	
		fi
		# lsscsi testing to verify that there are no SAN drives listed as local drives.
		# the SAN model must be listed below or this will generate a false positive.
		if [[ SAN -eq 1 ]] 
		then
			if [ -f /usr/bin/lsscsi ]; 
			then 
				LOCDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iwv 'cd|dvd|5100|hsv200|1814|2145|VRAID|OPEN-V|DGC' | wc -l) ## (Drives to filter out CD,SAN Model, etc...))
				SANDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iw '5100|hsv200|1814|2145|VRAID|OPEN-V|DGC' | wc -l) ## (SAN Model for Hitachi,HP,IBM,EMC, etc...)
				if [ $(2>/dev/null cat /tmp/LOCSTORE.lst-tmp | wc -l) -ne $LOCDISKNUM ]
				then
					MPERR=1
					echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
					echo "Apprears to have more multipath drives reported than are available or SAN-model script coding" >> /tmp/MPissue.lst-tmp
				fi
			fi
		fi
	fi	
	if [[ ! -f /etc/multipath.conf ]]
	then
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "No /etc/multipath.conf file present" >> /tmp/MPissue.lst-tmp
	fi
	if grep --quiet -i "mpath" /tmp/mp-ll.lst-tmp
	then
		FRIENDLY=1
	else
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "Not using friendly names" >> /tmp/MPissue.lst-tmp
	fi
	if [[ $(multipath -ll | wc -l) -eq 0 && $(cat /proc/scsi/scsi | egrep -i 'EMC|DGC|Hitachi' | wc -l) -gt 0 ]]
	then 
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "multipath -ll empty" >> /tmp/MPissue.lst-tmp
	fi
	if grep --quiet -i "\[failed\]\[faulty\]" /tmp/mp-ll.lst-tmp
	then 
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "multipath -ll contains [failed][faulty] errors" >> /tmp/MPissue.lst-tmp
	fi
	if [[ -f /tmp/MPissue.lst-tmp ]]; then cat /tmp/MPissue.lst-tmp >> /tmp/SANoutput.lst-tmp; fi 
}  ## end of f_mptest function

f_mirror () # Tests & filtering for RAID1/Mirroring
{ #echo f_mirror
	#*****************************
	# Filers out configurations that couldn't/wouldn't have mirroring; i.e. VMware, less than two local disks, etc...
	# If MIRROR=0 then there is no RAID1, if 1 there is RAID1, if 2 meets the basic conditions but no /proc/mdstat RAID1
	#-----------------------------
	VM1=$(lspci | grep VMware)
	if [[ "$VM1" == *VMware* ]]
	then
		MIRROR=0
	else
		if [[ $LOCALDRIVES -lt 2 ]] 
		then
			MIRROR=0
		else
			REM=$(( $LOCALDRIVES % 2 ))
			if [ $REM -eq 0 ]
			then
				echo "There are an even number of Local drivers -- RAID0 tests go here..."
				if grep --quiet -i "raid1" /proc/mdstat
				then
					MIRROR=1
				else
					MIRROR=2
				fi
			else
				MIRROR=0
			fi
		fi
	fi
} # End of f_mirror function

#*****************************#*****************************#*****************************#*****************************#
#*****************************#*****************************#*****************************#*****************************#
# Start of Main Program Logic
#-----------------------------#-----------------------------#-----------------------------#-----------------------------#

if [[ $(id -u) -ne 0 ]] ; then echo "linuxstoragetotal.sh must be run as root" ; exit 1 ; fi
SAN=0; MPUTIL=0
SERVER="$(hostname | cut -d. -f1)"2>/dev/null rm -f /tmp/*.lst-tmp  ## Delete ALL prior tempfiles from this script
SERVER="$(hostname | cut -d. -f1)"
CMDSHELL=$(ps h -p $$ | awk '{print $5}' | awk -F'/' '{print $3}')  ##  What COMMAND SHELL is running (bash, korn, etc...)
if [[ "$(lspci | egrep -i "fibre channel" | wc -l)" -gt 0  ]]   ## determine if this server has HBA's & SAN attached storage 
then
	if [[ -f /sbin/lsscsi ]]
	then
		SANDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iw '5100|hsv200|1814|2145|VRAID|OPEN-V|EMC|DGC' | wc -l)
	else
		SANDISKNUM=$(egrep -i '5100|hsv200|1814|2145|VRAID|OPEN-V|EMC|DGC' /proc/scsi/scsi | wc -l)
	fi
	if [[ $SANDISKNUM -gt 0 ]]; then SAN=1; else SAN=0; fi 
fi
f_diskinfo
if [[ $SAN -eq 1 ]]; then f_mprtnum; fi
if [[ $1 == [lL] ]]; then f_legacy; fi

#*****************************
# Deternime Local & SAN storage
#-----------------------------

if [[ $SAN -eq 0 ]]  ## LOCAL STORAGE ONLY, GET TOTAL OF ALL ATTACHED DRIVES
then
	let N=0
	while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
	do 
		echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
		N=$((N+1))		
	done
	LOCALSTORAGE=$TOTALSTORAGE
	SANSTORAGE=0
	echo "No SAN Attached Storage" > /tmp/SANoutput.lst-tmp
else  ## SAN ATTACHED STORAGE IS PRESENT, POSSIBLY LOCAL AS WELL
	if [[ $MPUTIL -eq 1 ]]  ## IF SAN ATTACHED BUILD SANTABLE
	then
		if [[ -f /tmp/fdskdrive.lst-tmp && -f /tmp/mpathtable.lst-tmp ]]
		then
			while read LINE
			do
				MPATHTEMP=$LINE
				MDRIVE=$(echo $MPATHTEMP | awk -F' ' '{ print $1 }')
				SDRIVES=$(/sbin/multipath -ll | egrep -iv 'prio|size' | grep -iwA$ROUTES $MDRIVE | grep -o 'sd[a-z]\|sd[a-z][a-z]' | tr '\n' ' ')
				SDRIVE=$(echo $SDRIVES | awk -F' ' '{ print $1 }')
				MSIZE=$(grep $SDRIVE /tmp/fdskdrive.lst-tmp | awk -F' ' '{ print $2 }')
				echo "$MSIZE $MPATHTEMP $SDRIVES" | grep "mpath" >> /tmp/santable1.lst-tmp
			done < /tmp/mpathtable.lst-tmp
			
			
			if [[ -f /tmp/santable1.lst-tmp ]] 
			then   
				f_hiscsi  ## HISCSI INFORMATION
				awk '{print $6"," $7"," $5"," $1"," $2"," $4"," $3}' /tmp/santable2.lst-tmp > /tmp/SANoutput.lst-tmp
		
				let N=0; let LOCSUM=0  ## IDENTIFY, ISOLATE AND TOTAL ANY LOCAL STORAGE
				while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
				do
					if grep -iwq ${ARRAY_DISKNAME[$N]} /tmp/santable1.lst-tmp	## -i=Ignore Case, -w=Whole Word, q=Quiet Mode
					then
						1>/dev/null echo SAN Attached storage
					else
						echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
						let LOCSUM+=${ARRAY_DISKSIZE[$N]}
					fi
				N=$((N+1))		
				done
			fi			
		fi	
		LOCALSTORAGE=$LOCSUM
			
	else  ## SAN ATTACHED WITH MULTIPATH ISSUES...
		let N=0
		while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
		do 
			echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
			N=$((N+1))		
		done
		LOCALSTORAGE=$TOTALSTORAGE		
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp
		echo "SAN Present - No Multipath configuration" >> /tmp/SANoutput.lst-tmp
	fi		
fi
if [[ $SAN -eq 1 && $TOTALSTORAGE -gt 0 && ROUTES -gt 0 ]]; then SANSTORAGE=$(((TOTALSTORAGE - LOCALSTORAGE)/ROUTES)); TOTALSTORAGE=$((SANSTORAGE + LOCALSTORAGE)); fi
f_extstore
f_mirror
if [[ $SAN -eq 1 ]]; then f_mptest; fi
if [[ -f /tmp/LOCSTORE.lst-tmp ]]; then LOCALDRIVES=$(cat /tmp/LOCSTORE.lst-tmp | wc -l); else LOCALDRIVES=0; echo "No Local Storage" > /tmp/LOCSTORE.lst-tmp; fi
if [[ $MIRROR -eq 1 ]]; then echo "This server is using RAID1 Mirroring" >> /tmp/LOCSTORE.lst-tmp; elif [[ $MIRROR -eq 1 ]]; then echo "This server meets the qualifications but does not appear to be using RAID1 Mirroring" >> /tmp/LOCSTORE.lst-tmp; fi
if [[ $SAN -eq 1 ]]; then SANDRIVES=$((TOTALDRIVES-LOCALDRIVES)); fi		
if [[ $SAN -eq 1 && $ROUTES -gt 0 ]]; then LUNS=$MPACTIVE; fi

#*****************************
# "Manual" validatiuon -- Show the work (/tmp/LSTmanual.lst-tmp)
#-----------------------------
# Use /tmp/fdskdrive.lst-tmp, /tmp/LOCSTORE.lst-tmp, $FDASUM, $LOCSUM & $ROUTES
if [[ $ROUTES -gt 0 ]]
then
	echo "Since there is External SAN storage connected to $SERVER using $ROUTES Multipath routes" > /tmp/LSTmanual.lst-tmp
	echo "the formula used to calculate the total storage was; Total Local Storage + (Total SAN Storage / MP Routes used)"  >> /tmp/LSTmanual.lst-tmp
	echo "FDISK lists all the drives connected to this server as;"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/fdskdrive.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "Below is the breakdown of how this was calculated:"  >> /tmp/LSTmanual.lst-tmp
	echo "----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: LOCAL STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/LOCSTORE.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL Local Storage = $LOCSUM"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: SAN STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/santable1.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL SAN Storage = $SANSTORAGE"  >> /tmp/LSTmanual.lst-tmp
	echo "----- -----"
	echo "The TOTAL STORAGE on this server equals;"  >> /tmp/LSTmanual.lst-tmp
	TMSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	echo "TOTAL STORAGE $TOTALSTORAGE = Local Storage $LOCSUM + (SAN Storage $SANSTORAGE / MP Routes $ROUTES)"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "The TOTAL STORAGE in GB's is: $TMSTORAGE"  >> /tmp/LSTmanual.lst-tmp
else
	echo "This server $SERVER has only Local storage connected" > /tmp/LSTmanual.lst-tmp
	echo "the formula used to calculate the total storage was; Total Local Storage = TOTAL STORAGE)"  >> /tmp/LSTmanual.lst-tmp
	echo "FDISK lists all the drives connected to this server as;"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/fdskdrive.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "Below is the breakdown of how this was calculated:"  >> /tmp/LSTmanual.lst-tmp
	echo "----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: LOCAL STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/LOCSTORE.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL Local Storage = $LOCSUM"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	TMSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	echo "The TOTAL STORAGE in GB's is: $TMSTORAGE"  >> /tmp/LSTmanual.lst-tmp
fi

#*****************************
# Print Report to screen and disk (/tmp/LSTreport.lst-tmp)
#-----------------------------
#Total Local & SAN Attached Storage
#Total External/Shared Storage
#Breakdown and Mapping
#Local Disks -- Disk, LocalDisk, Size
#SAN LUN's -- Disk, LUID, Size
#External Links -- Host:path, Size
SERVER="$(hostname | awk -F'.' '{print $1}')"
if [[ $1 == [gG] ]]     # Opitional GB Conversion 
then 
	TOTALSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	LOCALSTORAGE=$((LOCALSTORAGE/1024/1024/1024))
	SANSTORAGE=$((SANSTORAGE/1024/1024/1024))
	EXTTOTAL=$((EXTTOTAL/1024/1024/1024))
fi
if [[ $MPERR -eq 1 ]]; then TOTALSTORAGE="MP-issue"; echo " --- multipath -ll output follows ---" >> /tmp/SANoutput.lst-tmp; cat /tmp/mp-ll.lst-tmp >> /tmp/SANoutput.lst-tmp; fi
echo " "; echo " " 
echo "$SERVER,$CMDSHELL,$VERSION" |tee /tmp/LSTreport.lst-tmp
echo "LocalStorage-Only,$LOCALSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "SANattached-Only,$SANSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "Local-SANattached,$TOTALSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "External/Shared,$EXTTOTAL" |tee -a /tmp/LSTreport.lst-tmp
echo "--- Itemized mapping results follow ---" |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized Local Storage" |tee -a /tmp/LSTreport.lst-tmp
echo "LOCAL_DRIVES $LOCALDRIVES" |tee -a /tmp/LSTreport.lst-tmp
if grep --quiet -i "LocalDisk" /tmp/LOCSTORE.lst-tmp; then echo "Drive | Description | Size" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/LOCSTORE.lst-tmp |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized SAN Attached storage and mappings" |tee -a /tmp/LSTreport.lst-tmp
if [[ $SAN -eq 1 ]]; then echo "SAN_DRIVES $SANDRIVES | ROUTES $ROUTES | LUN's $LUNS" |tee -a /tmp/LSTreport.lst-tmp; fi
if [[ $SAN -eq 1 ]]; then echo "Drive | LUID | SIZE | Manufacturer | Model | ASN | LDEV" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/SANoutput.lst-tmp |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized External/Shared storage and mappings" |tee -a /tmp/LSTreport.lst-tmp
if [[ $EXTSTORE = "YES" ]]; then echo "Storage Mapping | Size" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/ExtLinks2.lst-tmp |tee -a /tmp/LSTreport.lst-tmp

exit 0
=======
#!/bin/bash
#
# Linux Storage Billing Script for total space, shooting for simple, quick and accurate
VERSION='linuxstoragetotal.sh--Version-3.39'
# Created; 5/15/2015 by Jim Bodden  (based on linuxstoragecalc.sh Created; 5/15/2014)
# Modified; 12/02/2015 by Jim Bodden
# 
#
#*****************************  NOTES  *****************************
## Due to the way storage is computed with certain tools & OS's this sizes may differ slightly.
## 6/24/2015 -- This script has gone through several modifications in the past as new conditions were encountered.
## 6/24/2015 -- The v2.59 code is now being streamlined to efficiently consolidate the modifications layered on in the past.
## 6/25/2015 -- Added the f_mptest function with additional multipath testing
## 6/29/2015 -- Added support for SANTYPE, SANMOD, ASN & LDEV on HITACHI
## 7/18/2015 -- Adding tests & filtering for RAID1 per DIR as of Friday meeting -- f_mirror.
## 12/02/2015 -- Added routine to create /tmp/LSTmanual.lst-tmp to assist with manual validations
#*******************************************************************

f_diskinfo () # Gather Disk Names and Sizes Information ( This is performed for ALL Types...)
{ #echo f_diskinfo
	#*****************************
	# Populate arrays with FDISK info
	#-----------------------------
	ARRAY_DISKNAME=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk -F':' '{print $1}' | awk -F'/' '{print $NF}') )  ## DISK NAMES
	ARRAY_DISKNAMEPATH=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk -F':' '{print $1}' | awk -F' ' '{print $2}') )  ## DISK NAMES w/ paths
	ARRAY_DISKSIZE=( $(2>/dev/null /sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "mapper" | egrep -v /dev/dm- | awk '{print $5}') )        ## DISK BYTE SIZE
	DISKNAME_ARRAY_LENGTH=${#ARRAY_DISKNAME[@]}; DISKSIZE_ARRAY_LENGTH=${#ARRAY_DISKSIZE[@]}
	#*****************************
	# Calculate FDISK Attached sum -- $FDASUM and create /tmp/fdskdrive.lst-tmp
	#-----------------------------
	N=0; FDASUM=0; MPERR=0
	while [ $N -lt "$DISKSIZE_ARRAY_LENGTH" ]
	do 
	echo ${ARRAY_DISKNAME[$N]} ${ARRAY_DISKSIZE[$N]} >> /tmp/fdskdrive.lst-tmp
	if [[ $SAN -eq 1 && -e /sbin/HiScsiBinaryLinux ]]; then HiScsiBinaryLinux ${ARRAY_DISKNAMEPATH[$N]} > /tmp/${ARRAY_DISKNAME[$N]}.lst-tmp ;fi  ## For SAN Tesing
	let FDASUM+=${ARRAY_DISKSIZE[$N]}
	N=$((N+1))
	done
	TOTALSTORAGE=$FDASUM
} # End of f_diskinfo function

f_mprtnum ()
{ #echo f_mprtnum
	#*****************************
	# Calculate the number of multipath routes to each SAN LUN (i.e. 4 'drives' to 1 LUN)
	#-----------------------------
	if [[ -f /sbin/multipath && $(2>/dev/null /sbin/multipath -ll | grep -i 'size' | wc -l) -ne 0 ]]
	then
		MPUTIL=1
		/sbin/multipath -ll > /tmp/mp-ll.lst-tmp
		/sbin/multipath -ll | egrep -iv 'prio|size|mpath|robin' | grep -v '^$' > /tmp/mptotaldrives.lst-tmp
		/sbin/multipath -ll | egrep -iv 'prio|size' > /tmp/mprtdrives.lst-tmp
		MPENABLE=$(/sbin/multipath -ll | egrep -i 'robin' | egrep -i 'enabled' | wc -l) 
		MPACTIVE=$(/sbin/multipath -ll | egrep -i 'robin' | egrep -i 'active' | wc -l)
		MSANDRIVES=$(cat /tmp/mptotaldrives.lst-tmp | egrep -iv 'prio|size|mpath' | wc -l); MLUNS=$(multipath -ll | grep -i mpath | wc -l)
		if [[ $MPENABLE -gt 0 ]]; then MSANDRIVES=$((MSANDRIVES/2)); fi	
		if [[ $MPACTIVE -gt 0 ]]; then ROUTES=$((MSANDRIVES / MPACTIVE)); fi
		/sbin/multipath -ll | grep -i mpath | tr -d '()' | tr ',' ' ' | sort --field-separator=' ' -k1,1 -u | awk '{print $1" "$2}' > /tmp/mpathtemp.lst-tmp;  ## Create sort mpath table
		awk -F" " '{sub(/[3]/,"",$2)}1' OFS=" " /tmp/mpathtemp.lst-tmp > /tmp/mpathtable.lst-tmp
		TOTALDRIVES=$DISKNAME_ARRAY_LENGTH
#		echo "MPENABLE $MPENABLE MPACTIVE $MPACTIVE MSANDRIVES $MSANDRIVES ROUTES $ROUTES TOTALDRIVES $TOTALDRIVES"; read
	else
		MPUTIL=0
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 		
	fi
} # End of f_mprtnum function

f_legacy () # 
{ #echo f_legacy 
	#*****************************
	# Calculate Storage as reported prior to July 2015
	#-----------------------------

	# Calculate Total Storage
	#-----------------------------
	# Filter out device mapper and software RAID to eliminate duplication
	if [[ "$OUT2" == 1 ]]
	then
		TOTALSTORAGE=$(/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" |  egrep -iv "/dev/dm-" | awk '{total = total + $5} END {print total/1000/1000/1000}')
	else
		TOTALSTORAGE=$(/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" |  egrep -iv "/dev/dm-" | awk '{total = total + $5} END {print total}')
	fi

	# Calculate Allocated Storage   
	#-----------------------------
	if [[ "$OUT2" == 1 ]]
	then
		ALLOCATEDSTORAGE=$(/bin/df -lP | egrep -iv '/media/nss' | egrep -iv '/media/CDROM' | awk '{total += $2} END {print total/1000/1000}')
	else
		ALLOCATEDSTORAGE=$(/bin/df -lP | egrep -iv '/media/nss' | egrep -iv '/media/CDROM' | awk '{total += $2} END {print total*1000}')
	fi
	if [[ $SAN -eq 1 && $ROUTES -gt 0 ]]; then TOTALSTORAGE=$((TOTALSTORAGE/ROUTES)); fi
	LTS=$(printf '%.0f' $TOTALSTORAGE); LAS=$(printf '%.0f' $ALLOCATEDSTORAGE)
	TSG=$((LTS/1024/1024/1024))
	TSA=$((LAS/1024/1024/1024))
	echo "TOTALSTORAGE,$LTS,$TSG" |tee /tmp/LSTreport.lst-tmp
	echo "ALLOCATEDSTORAGE,$LAS,$TSA" |tee -a /tmp/LSTreport.lst-tmp
	exit 0
} # End of f_legacy function

f_extstore () # External/Shared Storage Identifier
{ #echo f_extstore
	#*****************************
	# Determine if this server is using external/shared storage mapped links
	#-----------------------------
	if [[ $(df -Pk|column -t | grep -iv filesystem | grep -iv tmpfs | grep -iv /dev/ | grep -iwv udev | grep -iv _admin) ]]; 
	then 
		EXTSTORE="YES" 
		df -Pk|column -t | grep -iv filesystem | grep -iv tmpfs | grep -iv /dev/ | grep -iwv udev | grep -iv nss | grep -iv admin > /tmp/ExtLinks1.lst-tmp
		awk '{print $1"," $2*1024}' /tmp/ExtLinks1.lst-tmp > /tmp/ExtLinks2.lst-tmp
		EXTTOTAL=$(cat /tmp/ExtLinks2.lst-tmp | awk -F',' '{sum+=$2} END {print sum}')
	else
	EXTSTORE="NO"
	EXTTOTAL=0
	echo "No External/Shared storage" > /tmp/ExtLinks2.lst-tmp
fi
}  ## End of f_extstore function

f_hiscsi () # Gather third party utility HiScsiBinaryLinux information into disk named temp files
{ #echo f_hiscsi
	while read LINE     ## HiScsiBinaryLinux Parsing
	do
		HDRV=$(echo $LINE | awk '{print $4}')
		if [[ -f /tmp/$HDRV.lst-tmp ]]
		then
			SANTYPE=$(cat /tmp/$HDRV.lst-tmp | grep "Manufacturer" | awk -F'= ' '{ print $2}'); if [ $SANTYPE = DGC ]; then SANTYPE="EMC"; fi
			if [[ $SANTYPE = *HITACHI* ]] 
			then 
				SANMOD=$(cat /tmp/$HDRV.lst-tmp | grep "Model Type" | awk -F'= ' '{ print $2}')
				LDEV=$(cat /tmp/$HDRV.lst-tmp | grep "Logical Unit Number" | awk -F'= ' '{ print $2}')
				ASN=$(cat /tmp/$HDRV.lst-tmp | grep "Storage Box Number" | awk -F'= ' '{ print $2}')
			elif [[ $SANTYPE=*EMC* ]]
			then
				SANMOD=$(cat /tmp/$HDRV.lst-tmp | grep "Storage Box Model" | awk -F'= ' '{ print $2}' | tr ' ' - | awk -F'-' '{print $NF}')
				LDEV="N/A"
				ASN=$(cat /tmp/$HDRV.lst-tmp | grep "Device Unit Serial Number" | awk -F'= ' '{ print $2}')				
			else
				SANMOD=$SANTYPE; LDEV="N/A"; ASN="N/A"
			fi
			[[ -z "$SANTYPE" ]] && SANTYPE="Unk"; [[ -z "$SANMOD" ]] && SANMOD="Unk"; [[ -z "$LDEV" ]] && LDEV="Unk"; [[ -z "$ASN" ]] && ASN="Unk"; 
			echo "$SANTYPE $SANMOD $LDEV $ASN $LINE" >> /tmp/santable2.lst-tmp
		else
			SANFO="HiScsiBinaryLinux Utility Here Missing"
			echo "$SANFO $LINE" >> /tmp/santable2.lst-tmp 
		fi
	done < /tmp/santable1.lst-tmp
} # End of f_hiscsi function

f_mptest () # Additional multipath testing to verify it it is working correctly
{ #echo f_mptest
	if [[ SAN -eq 1 ]]
	then
		if [[ -f /tmp/LOCSTORE.lst-tmp ]]
		then
			while read LINE
			do
				LOCDRVTEST=$(echo $LINE | awk -F',' '{print $1}') 
				if [[ -e /tmp/$LOCDRVTEST.lst-tmp ]]
				then 
					SMODEL1=$(cat /tmp/$LOCDRVTEST.lst-tmp | grep 'Model Type' | awk -F'= ' '{print $2}')
					SMODEL2=$(cat /tmp/$LOCDRVTEST.lst-tmp | grep 'Storage Box Model' | awk -F'= ' '{print $2}')
					MOD1=$(echo $SMODEL1 | egrep --quiet '5100|hsv200|1814|2145|VRAID|OPEN-V' | wc -c)
					MOD2=$(echo $SMODEL2 | egrep --quiet 'EMC|Hitachi' | wc -c)
					if [[ $MOD1 -gt 0 ]] || [[ $MOD2 -gt 0 ]] 
					then 
						MPERR=1
						echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
						echo "MP ERR Local Drive $LOCDRVTEST is SAN" >> /tmp/MPissue.lst-tmp
					fi
				fi
			done < /tmp/LOCSTORE.lst-tmp	
		fi
		# lsscsi testing to verify that there are no SAN drives listed as local drives.
		# the SAN model must be listed below or this will generate a false positive.
		if [[ SAN -eq 1 ]] 
		then
			if [ -f /usr/bin/lsscsi ]; 
			then 
				LOCDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iwv 'cd|dvd|5100|hsv200|1814|2145|VRAID|OPEN-V|DGC' | wc -l) ## (Drives to filter out CD,SAN Model, etc...))
				SANDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iw '5100|hsv200|1814|2145|VRAID|OPEN-V|DGC' | wc -l) ## (SAN Model for Hitachi,HP,IBM,EMC, etc...)
				if [ $(2>/dev/null cat /tmp/LOCSTORE.lst-tmp | wc -l) -ne $LOCDISKNUM ]
				then
					MPERR=1
					echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
					echo "Apprears to have more multipath drives reported than are available or SAN-model script coding" >> /tmp/MPissue.lst-tmp
				fi
			fi
		fi
	fi	
	if [[ ! -f /etc/multipath.conf ]]
	then
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "No /etc/multipath.conf file present" >> /tmp/MPissue.lst-tmp
	fi
	if grep --quiet -i "mpath" /tmp/mp-ll.lst-tmp
	then
		FRIENDLY=1
	else
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "Not using friendly names" >> /tmp/MPissue.lst-tmp
	fi
	if [[ $(multipath -ll | wc -l) -eq 0 && $(cat /proc/scsi/scsi | egrep -i 'EMC|DGC|Hitachi' | wc -l) -gt 0 ]]
	then 
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "multipath -ll empty" >> /tmp/MPissue.lst-tmp
	fi
	if grep --quiet -i "\[failed\]\[faulty\]" /tmp/mp-ll.lst-tmp
	then 
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp 
		echo "multipath -ll contains [failed][faulty] errors" >> /tmp/MPissue.lst-tmp
	fi
	if [[ -f /tmp/MPissue.lst-tmp ]]; then cat /tmp/MPissue.lst-tmp >> /tmp/SANoutput.lst-tmp; fi 
}  ## end of f_mptest function

f_mirror () # Tests & filtering for RAID1/Mirroring
{ #echo f_mirror
	#*****************************
	# Filers out configurations that couldn't/wouldn't have mirroring; i.e. VMware, less than two local disks, etc...
	# If MIRROR=0 then there is no RAID1, if 1 there is RAID1, if 2 meets the basic conditions but no /proc/mdstat RAID1
	#-----------------------------
	VM1=$(lspci | grep VMware)
	if [[ "$VM1" == *VMware* ]]
	then
		MIRROR=0
	else
		if [[ $LOCALDRIVES -lt 2 ]] 
		then
			MIRROR=0
		else
			REM=$(( $LOCALDRIVES % 2 ))
			if [ $REM -eq 0 ]
			then
				echo "There are an even number of Local drivers -- RAID0 tests go here..."
				if grep --quiet -i "raid1" /proc/mdstat
				then
					MIRROR=1
				else
					MIRROR=2
				fi
			else
				MIRROR=0
			fi
		fi
	fi
} # End of f_mirror function

#*****************************#*****************************#*****************************#*****************************#
#*****************************#*****************************#*****************************#*****************************#
# Start of Main Program Logic
#-----------------------------#-----------------------------#-----------------------------#-----------------------------#

if [[ $(id -u) -ne 0 ]] ; then echo "linuxstoragetotal.sh must be run as root" ; exit 1 ; fi
SAN=0; MPUTIL=0
SERVER="$(hostname | cut -d. -f1)"2>/dev/null rm -f /tmp/*.lst-tmp  ## Delete ALL prior tempfiles from this script
SERVER="$(hostname | cut -d. -f1)"
CMDSHELL=$(ps h -p $$ | awk '{print $5}' | awk -F'/' '{print $3}')  ##  What COMMAND SHELL is running (bash, korn, etc...)
if [[ "$(lspci | egrep -i "fibre channel" | wc -l)" -gt 0  ]]   ## determine if this server has HBA's & SAN attached storage 
then
	if [[ -f /sbin/lsscsi ]]
	then
		SANDISKNUM=$(lsscsi | grep disk | egrep -i 'dev' | egrep -iw '5100|hsv200|1814|2145|VRAID|OPEN-V|EMC|DGC' | wc -l)
	else
		SANDISKNUM=$(egrep -i '5100|hsv200|1814|2145|VRAID|OPEN-V|EMC|DGC' /proc/scsi/scsi | wc -l)
	fi
	if [[ $SANDISKNUM -gt 0 ]]; then SAN=1; else SAN=0; fi 
fi
f_diskinfo
if [[ $SAN -eq 1 ]]; then f_mprtnum; fi
if [[ $1 == [lL] ]]; then f_legacy; fi

#*****************************
# Deternime Local & SAN storage
#-----------------------------

if [[ $SAN -eq 0 ]]  ## LOCAL STORAGE ONLY, GET TOTAL OF ALL ATTACHED DRIVES
then
	let N=0
	while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
	do 
		echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
		N=$((N+1))		
	done
	LOCALSTORAGE=$TOTALSTORAGE
	SANSTORAGE=0
	echo "No SAN Attached Storage" > /tmp/SANoutput.lst-tmp
else  ## SAN ATTACHED STORAGE IS PRESENT, POSSIBLY LOCAL AS WELL
	if [[ $MPUTIL -eq 1 ]]  ## IF SAN ATTACHED BUILD SANTABLE
	then
		if [[ -f /tmp/fdskdrive.lst-tmp && -f /tmp/mpathtable.lst-tmp ]]
		then
			while read LINE
			do
				MPATHTEMP=$LINE
				MDRIVE=$(echo $MPATHTEMP | awk -F' ' '{ print $1 }')
				SDRIVES=$(/sbin/multipath -ll | egrep -iv 'prio|size' | grep -iwA$ROUTES $MDRIVE | grep -o 'sd[a-z]\|sd[a-z][a-z]' | tr '\n' ' ')
				SDRIVE=$(echo $SDRIVES | awk -F' ' '{ print $1 }')
				MSIZE=$(grep $SDRIVE /tmp/fdskdrive.lst-tmp | awk -F' ' '{ print $2 }')
				echo "$MSIZE $MPATHTEMP $SDRIVES" | grep "mpath" >> /tmp/santable1.lst-tmp
			done < /tmp/mpathtable.lst-tmp
			
			
			if [[ -f /tmp/santable1.lst-tmp ]] 
			then   
				f_hiscsi  ## HISCSI INFORMATION
				awk '{print $6"," $7"," $5"," $1"," $2"," $4"," $3}' /tmp/santable2.lst-tmp > /tmp/SANoutput.lst-tmp
		
				let N=0; let LOCSUM=0  ## IDENTIFY, ISOLATE AND TOTAL ANY LOCAL STORAGE
				while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
				do
					if grep -iwq ${ARRAY_DISKNAME[$N]} /tmp/santable1.lst-tmp	## -i=Ignore Case, -w=Whole Word, q=Quiet Mode
					then
						1>/dev/null echo SAN Attached storage
					else
						echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
						let LOCSUM+=${ARRAY_DISKSIZE[$N]}
					fi
				N=$((N+1))		
				done
			fi			
		fi	
		LOCALSTORAGE=$LOCSUM
			
	else  ## SAN ATTACHED WITH MULTIPATH ISSUES...
		let N=0
		while [ $N -lt "$DISKNAME_ARRAY_LENGTH" ]
		do 
			echo ${ARRAY_DISKNAME[$N]},LocalDisk,${ARRAY_DISKSIZE[$N]} >> /tmp/LOCSTORE.lst-tmp
			N=$((N+1))		
		done
		LOCALSTORAGE=$TOTALSTORAGE		
		MPERR=1
		echo "SAN Present - Multipath Issues" > /tmp/SANoutput.lst-tmp
		echo "SAN Present - No Multipath configuration" >> /tmp/SANoutput.lst-tmp
	fi		
fi
if [[ $SAN -eq 1 && $TOTALSTORAGE -gt 0 && ROUTES -gt 0 ]]; then SANSTORAGE=$(((TOTALSTORAGE - LOCALSTORAGE)/ROUTES)); TOTALSTORAGE=$((SANSTORAGE + LOCALSTORAGE)); fi
f_extstore
f_mirror
if [[ $SAN -eq 1 ]]; then f_mptest; fi
if [[ -f /tmp/LOCSTORE.lst-tmp ]]; then LOCALDRIVES=$(cat /tmp/LOCSTORE.lst-tmp | wc -l); else LOCALDRIVES=0; echo "No Local Storage" > /tmp/LOCSTORE.lst-tmp; fi
if [[ $MIRROR -eq 1 ]]; then echo "This server is using RAID1 Mirroring" >> /tmp/LOCSTORE.lst-tmp; elif [[ $MIRROR -eq 1 ]]; then echo "This server meets the qualifications but does not appear to be using RAID1 Mirroring" >> /tmp/LOCSTORE.lst-tmp; fi
if [[ $SAN -eq 1 ]]; then SANDRIVES=$((TOTALDRIVES-LOCALDRIVES)); fi		
if [[ $SAN -eq 1 && $ROUTES -gt 0 ]]; then LUNS=$MPACTIVE; fi

#*****************************
# "Manual" validatiuon -- Show the work (/tmp/LSTmanual.lst-tmp)
#-----------------------------
# Use /tmp/fdskdrive.lst-tmp, /tmp/LOCSTORE.lst-tmp, $FDASUM, $LOCSUM & $ROUTES
if [[ $ROUTES -gt 0 ]]
then
	echo "Since there is External SAN storage connected to $SERVER using $ROUTES Multipath routes" > /tmp/LSTmanual.lst-tmp
	echo "the formula used to calculate the total storage was; Total Local Storage + (Total SAN Storage / MP Routes used)"  >> /tmp/LSTmanual.lst-tmp
	echo "FDISK lists all the drives connected to this server as;"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/fdskdrive.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "Below is the breakdown of how this was calculated:"  >> /tmp/LSTmanual.lst-tmp
	echo "----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: LOCAL STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/LOCSTORE.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL Local Storage = $LOCSUM"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: SAN STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/santable1.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL SAN Storage = $SANSTORAGE"  >> /tmp/LSTmanual.lst-tmp
	echo "----- -----"
	echo "The TOTAL STORAGE on this server equals;"  >> /tmp/LSTmanual.lst-tmp
	TMSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	echo "TOTAL STORAGE $TOTALSTORAGE = Local Storage $LOCSUM + (SAN Storage $SANSTORAGE / MP Routes $ROUTES)"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "The TOTAL STORAGE in GB's is: $TMSTORAGE"  >> /tmp/LSTmanual.lst-tmp
else
	echo "This server $SERVER has only Local storage connected" > /tmp/LSTmanual.lst-tmp
	echo "the formula used to calculate the total storage was; Total Local Storage = TOTAL STORAGE)"  >> /tmp/LSTmanual.lst-tmp
	echo "FDISK lists all the drives connected to this server as;"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/fdskdrive.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	echo "Below is the breakdown of how this was calculated:"  >> /tmp/LSTmanual.lst-tmp
	echo "----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----"  >> /tmp/LSTmanual.lst-tmp
	echo ":: LOCAL STORAGE ::"  >> /tmp/LSTmanual.lst-tmp
	cat /tmp/LOCSTORE.lst-tmp  >> /tmp/LSTmanual.lst-tmp
	echo "TOTAL Local Storage = $LOCSUM"  >> /tmp/LSTmanual.lst-tmp
	echo "-----"  >> /tmp/LSTmanual.lst-tmp
	TMSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	echo "The TOTAL STORAGE in GB's is: $TMSTORAGE"  >> /tmp/LSTmanual.lst-tmp
fi

#*****************************
# Print Report to screen and disk (/tmp/LSTreport.lst-tmp)
#-----------------------------
#Total Local & SAN Attached Storage
#Total External/Shared Storage
#Breakdown and Mapping
#Local Disks -- Disk, LocalDisk, Size
#SAN LUN's -- Disk, LUID, Size
#External Links -- Host:path, Size
SERVER="$(hostname | awk -F'.' '{print $1}')"
if [[ $1 == [gG] ]]     # Opitional GB Conversion 
then 
	TOTALSTORAGE=$((TOTALSTORAGE/1024/1024/1024))
	LOCALSTORAGE=$((LOCALSTORAGE/1024/1024/1024))
	SANSTORAGE=$((SANSTORAGE/1024/1024/1024))
	EXTTOTAL=$((EXTTOTAL/1024/1024/1024))
fi
if [[ $MPERR -eq 1 ]]; then TOTALSTORAGE="MP-issue"; echo " --- multipath -ll output follows ---" >> /tmp/SANoutput.lst-tmp; cat /tmp/mp-ll.lst-tmp >> /tmp/SANoutput.lst-tmp; fi
echo " "; echo " " 
echo "$SERVER,$CMDSHELL,$VERSION" |tee /tmp/LSTreport.lst-tmp
echo "LocalStorage-Only,$LOCALSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "SANattached-Only,$SANSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "Local-SANattached,$TOTALSTORAGE" |tee -a /tmp/LSTreport.lst-tmp
echo "External/Shared,$EXTTOTAL" |tee -a /tmp/LSTreport.lst-tmp
echo "--- Itemized mapping results follow ---" |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized Local Storage" |tee -a /tmp/LSTreport.lst-tmp
echo "LOCAL_DRIVES $LOCALDRIVES" |tee -a /tmp/LSTreport.lst-tmp
if grep --quiet -i "LocalDisk" /tmp/LOCSTORE.lst-tmp; then echo "Drive | Description | Size" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/LOCSTORE.lst-tmp |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized SAN Attached storage and mappings" |tee -a /tmp/LSTreport.lst-tmp
if [[ $SAN -eq 1 ]]; then echo "SAN_DRIVES $SANDRIVES | ROUTES $ROUTES | LUN's $LUNS" |tee -a /tmp/LSTreport.lst-tmp; fi
if [[ $SAN -eq 1 ]]; then echo "Drive | LUID | SIZE | Manufacturer | Model | ASN | LDEV" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/SANoutput.lst-tmp |tee -a /tmp/LSTreport.lst-tmp
echo "* Itemized External/Shared storage and mappings" |tee -a /tmp/LSTreport.lst-tmp
if [[ $EXTSTORE = "YES" ]]; then echo "Storage Mapping | Size" |tee -a /tmp/LSTreport.lst-tmp; fi
2>/dev/null cat /tmp/ExtLinks2.lst-tmp |tee -a /tmp/LSTreport.lst-tmp

exit 0
>>>>>>> origin/master
