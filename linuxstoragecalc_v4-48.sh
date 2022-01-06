#!/bin/bash
#
#Linux Storage Billing Script for total allocated space
#Version: 4.49
#Created; 5/15/2014 by Jim Bodden
#Modified; 7/06/2014 by Jim Bodden/Srinivas Nagapuri
#(Based on the script linuxstoragecalc_v2.sh developed by Matthew Millhouse)
#
#       This script now creates a file with the hostname and date in /tmp
#       In this output file, each value is labeled.
#       Note: on servers running Oracle this information will be incorrect and thus skipped.
#       Manual calculations will be necessary for those servers.
#*****************************
#Output format: values on a single line, separated by spaces.  Sizes are in GB.
#Due to the way storage is computed with certain tools & OS's this sizes may differ slightly.
#*****************************


#*****************************
# Determin/set output filename
#-----------------------------
FILENAME="/tmp/StorageCalc_`/bin/hostname`_`date +%F`.csv"
echo " " |tee $FILENAME

#*****************************
# If server is virtual then ISVIRTUAL=1
#-----------------------------
VM1=$(lspci | grep VMware)
if [[ "$VM1" == *VMware* ]]
then
        VIRTUSTAT="This is a virtual server running on VMware."
        VM2=1
else
        VIRTUSTAT="This is a standalone physical server."
        VM2=0
fi

#*****************************
# Is the server connected to external SAN
#-----------------------------
SN1=$(lspci | egrep -i "fibre channel")
if [[ "$SN1" == *Fibre* ]]
then
        SANSTAT="This server is connected to an external SAN."
        SN2=1
else
        SANSTAT="This server is NOT connected to an external SAN."
        SN2=0
fi

#*****************************
# Is the server Multipathing
#-----------------------------
MP1=$(service multipathd status)
if [[ "$MP1" == *running* ]]
then
        MULTISTAT="This server is using Multipathing."
        MP2=1
else
        MULTISTAT="This server is NOT using Multipathing."
        MP2=0
fi

#*****************************
# Is the server Running Oracle
#-----------------------------
OR1=$(rpm -qa | grep oracle)
if [[ "$OR1" == *oracle* ]]
then
        ORASTAT="This server is running Oracle -- COLLECT MANUALLY."
        OUT2=1
else
        ORASTAT="This server is NOT running Oracle."
        OUT2=0
fi

#*****************************
# Format output in Bytes or GB's?
#-----------------------------
if [[ "$1" == *GB* ]]
then
        OUT1="GB"
        OUT2=1
else
        OUT1="Bytes"
        OUT2=0
fi

#*****************************
# Gather LUID information
#-----------------------------
ls -l /dev/disk/by-id | egrep '600' | awk '{print $9}' | sed 's/scsi\-3/LUID: /g' | cut -d'-' -f1 > /tmp/luid2.tmp
sort /tmp/luid2.tmp | uniq > /tmp/luid.tmp

#*****************************
# Gather UUID information
#-----------------------------
blkid | awk '{print $2}' | egrep -iv "type" | sed 's/UUID\=/UUID: /g' | sed 's/\"//g' > /tmp/blkid.tmp

#*****************************
# Calculate Total Storage
#-----------------------------
# Filter out device mapper and software RAID to eliminate duplication
if [[ "$OUT2" == 1 ]]
then
	TotalStorage=`/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" | awk '{total = total + $5} END {print total/1024/1024/1024}'`
else
	TotalStorage=`/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" | awk '{total = total + $5} END {print total}'`
fi

#*****************************
# Calculate Allocated Storage
#-----------------------------

if [[ "$OUT2" == 1 ]]
then
	AllocatedStorage=`/bin/df -lP | egrep -iv '/media/nss' | awk '{total += $2} END {print total/1024/1024}'`
else
	AllocatedStorage=`/bin/df -lP | egrep -iv '/media/nss' | awk '{total += $2} END {print total*1024}'`
fi


##############################
# Collect WWNs - if there is no SAN, the $wwn variables will be empty
##############################
read wwn1 wwn2 wwn3 wwn4 <<<$(/usr/bin/systool -av -c fc_transport 2>/dev/null | grep port_name | sort | uniq | awk '{print $3}' | sed s/\"//g )

#*****************************
# Display output and create /tmp/`/bin/hostname`_`date +%F` output file
#-----------------------------
echo " " |tee -a $FILENAME
echo "Hostname: `/bin/hostname`" |tee -a $FILENAME
echo $VIRTUSTAT |tee -a $FILENAME
echo $SANSTAT |tee -a $FILENAME
echo $MULTISTAT |tee -a $FILENAME
if [[ "$OR2" == 1 ]]
then
        echo $ORASTAT |tee -a $FILENAME
        exit
fi
echo "DATE,SERVER,ALLOCATED-STORAGE,TOTAL-STORAGE" |tee -a $FILENAME
if [[ "$OUT2" == 1 ]]
then
	printf "%s,%s,%0.2f,%0.2f\n" `date +%F` `/bin/hostname` $AllocatedStorage $TotalStorage |tee -a $FILENAME
else
	echo "`date +%F`,`/bin/hostname`,$AllocatedStorage,$TotalStorage" |tee -a $FILENAME
fi

echo "WWN1: $wwn1" |tee -a $FILENAME
echo "WWN2: $wwn2" |tee -a $FILENAME
echo "WWN3: $wwn3" |tee -a $FILENAME
echo "WWN4: $wwn4" |tee -a $FILENAME
cat /tmp/luid.tmp |tee -a $FILENAME
cat /tmp/blkid.tmp |tee -a $FILENAME

exit
#!/bin/bash
#
#Linux Storage Billing Script for total allocated space
#Version: 4.49
#Created; 5/15/2014 by Jim Bodden
#Modified; 7/06/2014 by Jim Bodden/Srinivas Nagapuri
#(Based on the script linuxstoragecalc_v2.sh developed by Matthew Millhouse)
#
#       This script now creates a file with the hostname and date in /tmp
#       In this output file, each value is labeled.
#       Note: on servers running Oracle this information will be incorrect and thus skipped.
#       Manual calculations will be necessary for those servers.
#*****************************
#Output format: values on a single line, separated by spaces.  Sizes are in GB.
#Due to the way storage is computed with certain tools & OS's this sizes may differ slightly.
#*****************************


#*****************************
# Determin/set output filename
#-----------------------------
FILENAME="/tmp/StorageCalc_`/bin/hostname`_`date +%F`.csv"
echo " " |tee $FILENAME

#*****************************
# If server is virtual then ISVIRTUAL=1
#-----------------------------
VM1=$(lspci | grep VMware)
if [[ "$VM1" == *VMware* ]]
then
        VIRTUSTAT="This is a virtual server running on VMware."
        VM2=1
else
        VIRTUSTAT="This is a standalone physical server."
        VM2=0
fi

#*****************************
# Is the server connected to external SAN
#-----------------------------
SN1=$(lspci | egrep -i "fibre channel")
if [[ "$SN1" == *Fibre* ]]
then
        SANSTAT="This server is connected to an external SAN."
        SN2=1
else
        SANSTAT="This server is NOT connected to an external SAN."
        SN2=0
fi

#*****************************
# Is the server Multipathing
#-----------------------------
MP1=$(service multipathd status)
if [[ "$MP1" == *running* ]]
then
        MULTISTAT="This server is using Multipathing."
        MP2=1
else
        MULTISTAT="This server is NOT using Multipathing."
        MP2=0
fi

#*****************************
# Is the server Running Oracle
#-----------------------------
OR1=$(rpm -qa | grep oracle)
if [[ "$OR1" == *oracle* ]]
then
        ORASTAT="This server is running Oracle -- COLLECT MANUALLY."
        OUT2=1
else
        ORASTAT="This server is NOT running Oracle."
        OUT2=0
fi

#*****************************
# Format output in Bytes or GB's?
#-----------------------------
if [[ "$1" == *GB* ]]
then
        OUT1="GB"
        OUT2=1
else
        OUT1="Bytes"
        OUT2=0
fi

#*****************************
# Gather LUID information
#-----------------------------
ls -l /dev/disk/by-id | egrep '600' | awk '{print $9}' | sed 's/scsi\-3/LUID: /g' | cut -d'-' -f1 > /tmp/luid2.tmp
sort /tmp/luid2.tmp | uniq > /tmp/luid.tmp

#*****************************
# Gather UUID information
#-----------------------------
blkid | awk '{print $2}' | egrep -iv "type" | sed 's/UUID\=/UUID: /g' | sed 's/\"//g' > /tmp/blkid.tmp

#*****************************
# Calculate Total Storage
#-----------------------------
# Filter out device mapper and software RAID to eliminate duplication
if [[ "$OUT2" == 1 ]]
then
	TotalStorage=`/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" | awk '{total = total + $5} END {print total/1024/1024/1024}'`
else
	TotalStorage=`/sbin/fdisk -l 2>/dev/null | egrep -i "disk /dev" | egrep -iv "mapper" | awk '{total = total + $5} END {print total}'`
fi

#*****************************
# Calculate Allocated Storage
#-----------------------------

if [[ "$OUT2" == 1 ]]
then
	AllocatedStorage=`/bin/df -lP | egrep -iv '/media/nss' | awk '{total += $2} END {print total/1024/1024}'`
else
	AllocatedStorage=`/bin/df -lP | egrep -iv '/media/nss' | awk '{total += $2} END {print total*1024}'`
fi


##############################
# Collect WWNs - if there is no SAN, the $wwn variables will be empty
##############################
read wwn1 wwn2 wwn3 wwn4 <<<$(/usr/bin/systool -av -c fc_transport 2>/dev/null | grep port_name | sort | uniq | awk '{print $3}' | sed s/\"//g )

#*****************************
# Display output and create /tmp/`/bin/hostname`_`date +%F` output file
#-----------------------------
echo " " |tee -a $FILENAME
echo "Hostname: `/bin/hostname`" |tee -a $FILENAME
echo $VIRTUSTAT |tee -a $FILENAME
echo $SANSTAT |tee -a $FILENAME
echo $MULTISTAT |tee -a $FILENAME
if [[ "$OR2" == 1 ]]
then
        echo $ORASTAT |tee -a $FILENAME
        exit
fi
echo "DATE,SERVER,ALLOCATED-STORAGE,TOTAL-STORAGE" |tee -a $FILENAME
if [[ "$OUT2" == 1 ]]
then
	printf "%s,%s,%0.2f,%0.2f\n" `date +%F` `/bin/hostname` $AllocatedStorage $TotalStorage |tee -a $FILENAME
else
	echo "`date +%F`,`/bin/hostname`,$AllocatedStorage,$TotalStorage" |tee -a $FILENAME
fi

echo "WWN1: $wwn1" |tee -a $FILENAME
echo "WWN2: $wwn2" |tee -a $FILENAME
echo "WWN3: $wwn3" |tee -a $FILENAME
echo "WWN4: $wwn4" |tee -a $FILENAME
cat /tmp/luid.tmp |tee -a $FILENAME
cat /tmp/blkid.tmp |tee -a $FILENAME

exit
