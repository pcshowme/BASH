<<<<<<< HEAD
#!/bin/bash
#Linux Storage Billing Script
#Matthew Millhouse 20120719
#	v0.2 edited 20121012
#	added:  script now creates a file with the hostname and date in /tmp/ru_output
#		In this output file, each value is labeled.
#Note: on physical servers with SAN and multipathing, the Total Storage numbers will be inaccurate
#	Manual calculations will be necessary for those servers.

###############
#Output format: values on a single line, separated by spaces.  Sizes are in GB.
###############
#Hostname TotalStorage TotalLocalStorage TotalVMStorage TotalSANStorage AllocatedStorage AllocatedLocalStorage AllocatedVMStorage AllocatedSANStorage WWN1 WWN2 WWN3 WWN4 

##############################
# Calculate Total Storage
##############################
# Filter out device mapper and software RAID to eliminate duplication
TotalStorage=`/sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "/dev/dm|dev/md" | awk '{total = total + $5} END {print total/1024/1024/1024}'`

##############################
# Calculate Allocated Storage
##############################
AllocatedStorage=`/bin/df -lP | awk '{total = total + $2} END {print total/1024/1024}'`

##############################
# Calculate Total SAN Storage
##############################
# Filter out device mapper, software raid, and local storage devices
#	The remaining devices would be SAN block storage devices
TotalSanStorage=`/sbin/fdisk -l | grep -i "Disk /dev/" | egrep -iv "/dev/dm|/dev/md|/dev/sd|/dev/hd" | awk '{total = total + $5} END {print total/1024/1024/1024}'`

##############################
# If server is virtual, assign correct "virtual" values
##############################
isvirtual=`/usr/sbin/dmidecode | grep -i vmware` 
if [ -n "$isvirtual" ]; then TotalVmStorage=$TotalStorage; else TotalVmStorage=0; fi
if [ -n "$isvirtual" ]; then AllocatedVmStorage=$AllocatedStorage; else AllocatedVmStorage=0; fi

##############################
# Calculate remaining values
##############################
AllocatedSanStorage=$TotalSanStorage
TotalLocalStorage=($TotalStorage - $TotalSanStorage)
AllocatedLocalStorage=($AllocatedStorage - $AllocatedSanStorage)

##############################
# Collect WWNs - if there is no SAN, the $wwn variables will be empty
##############################
read wwn1 wwn2 wwn3 wwn4 <<<$(/usr/bin/systool -av -c fc_transport | grep port_name | sort | uniq | awk '{print $3}' | sed s/\"//g )


##############################
# Print comma separated values on a single line to match the spreadsheet format
##############################
echo `/bin/hostname -a`","$TotalStorage","$TotalLocalStorage","$TotalVmStorage","$TotalSanStorage","$AllocatedStorage","$AllocatedLocalStorage","$AllocatedVmStorage","$AllocatedSanStorage","$wwn1","$wwn2","$wwn3","$wwn4
##############################
# Send single line with all values to file /tmp/ru_output/all_values.csv
##############################
mkdir /tmp/ru_output
echo `/bin/hostname -a`","$TotalStorage","$TotalLocalStorage","$TotalVmStorage","$TotalSanStorage","$AllocatedStorage","$AllocatedLocalStorage","$AllocatedVmStorage","$AllocatedSanStorage","$wwn1","$wwn2","$wwn3","$wwn4 > /tmp/ru_output/all_values.csv
##############################
# Use filename that contains the hostname and date
# Label each value on a separate line
##############################
echo -e "Hostname:\t\t "`/bin/hostname -a` > /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total Storage:\t\t" $TotalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total Local Storage:\t" $TotalLocalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total VM Storage:\t" $TotalVmStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total SAN Storage:\t" $TotalSanStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocate Storage:\t" $AllocatedStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated Local Storage:" $AllocatedLocalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated VM Storage:\t" $AllocatedVmStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated SAN Storage:\t" $AllocatedSanStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN1:\t\t" $wwn1 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN2:\t\t" $wwn2 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN3:\t\t" $wwn3 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN4:\t\t" $wwn4 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
##############################
# Send each value to an individual file in /tmp/ru_output/
##############################
echo `/bin/hostname -a` > /tmp/ru_output/hostname
echo $TotalStorage > /tmp/ru_output/TotalStorage
echo $TotalLocalStorage > /tmp/ru_output/TotalLocalStorage
echo $TotalVmStorage > /tmp/ru_output/TotalVmStorage
echo $TotalSanStorage > /tmp/ru_output/TotalSanStorage
echo $AllocatedStorage > /tmp/ru_output/AllocatedStorage
echo $AllocatedLocalStorage > /tmp/ru_output/AllocatedLocalStorage
echo $AllocatedVmStorage > /tmp/ru_output/AllocatedVmStorage
echo $AllocatedSanStorage > /tmp/ru_output/AllocatedSanStorage
echo $wwn1 > /tmp/ru_output/WWN1
echo $wwn2 > /tmp/ru_output/WWN2
echo $wwn3 > /tmp/ru_output/WWN3
echo $wwn4 > /tmp/ru_output/WWN4
################################
cd /tmp/ru_output
################################
# Transffer output file to ftp.pcSHOWme.com
################################
FTP_HOST=ftp.pcshowme.com
FTP_LOGIN=sot@pcshowme.com
FTP_PASSWORD=l3tm31n
ftp -inv ftp.pcshowme.com<<ENDFTP
user sot@pcshowme.com l3tm31n
cd ./
bin
lcd /tmp/ru_output
put `hostname`_`date +%F`
bye
ENDFTP
exit 0
=======
#!/bin/bash
#Linux Storage Billing Script
#Matthew Millhouse 20120719
#	v0.2 edited 20121012
#	added:  script now creates a file with the hostname and date in /tmp/ru_output
#		In this output file, each value is labeled.
#Note: on physical servers with SAN and multipathing, the Total Storage numbers will be inaccurate
#	Manual calculations will be necessary for those servers.

###############
#Output format: values on a single line, separated by spaces.  Sizes are in GB.
###############
#Hostname TotalStorage TotalLocalStorage TotalVMStorage TotalSANStorage AllocatedStorage AllocatedLocalStorage AllocatedVMStorage AllocatedSANStorage WWN1 WWN2 WWN3 WWN4 

##############################
# Calculate Total Storage
##############################
# Filter out device mapper and software RAID to eliminate duplication
TotalStorage=`/sbin/fdisk -l | egrep -i "disk /dev" | egrep -iv "/dev/dm|dev/md" | awk '{total = total + $5} END {print total/1024/1024/1024}'`

##############################
# Calculate Allocated Storage
##############################
AllocatedStorage=`/bin/df -lP | awk '{total = total + $2} END {print total/1024/1024}'`

##############################
# Calculate Total SAN Storage
##############################
# Filter out device mapper, software raid, and local storage devices
#	The remaining devices would be SAN block storage devices
TotalSanStorage=`/sbin/fdisk -l | grep -i "Disk /dev/" | egrep -iv "/dev/dm|/dev/md|/dev/sd|/dev/hd" | awk '{total = total + $5} END {print total/1024/1024/1024}'`

##############################
# If server is virtual, assign correct "virtual" values
##############################
isvirtual=`/usr/sbin/dmidecode | grep -i vmware` 
if [ -n "$isvirtual" ]; then TotalVmStorage=$TotalStorage; else TotalVmStorage=0; fi
if [ -n "$isvirtual" ]; then AllocatedVmStorage=$AllocatedStorage; else AllocatedVmStorage=0; fi

##############################
# Calculate remaining values
##############################
AllocatedSanStorage=$TotalSanStorage
TotalLocalStorage=($TotalStorage - $TotalSanStorage)
AllocatedLocalStorage=($AllocatedStorage - $AllocatedSanStorage)

##############################
# Collect WWNs - if there is no SAN, the $wwn variables will be empty
##############################
read wwn1 wwn2 wwn3 wwn4 <<<$(/usr/bin/systool -av -c fc_transport | grep port_name | sort | uniq | awk '{print $3}' | sed s/\"//g )


##############################
# Print comma separated values on a single line to match the spreadsheet format
##############################
echo `/bin/hostname -a`","$TotalStorage","$TotalLocalStorage","$TotalVmStorage","$TotalSanStorage","$AllocatedStorage","$AllocatedLocalStorage","$AllocatedVmStorage","$AllocatedSanStorage","$wwn1","$wwn2","$wwn3","$wwn4
##############################
# Send single line with all values to file /tmp/ru_output/all_values.csv
##############################
mkdir /tmp/ru_output
echo `/bin/hostname -a`","$TotalStorage","$TotalLocalStorage","$TotalVmStorage","$TotalSanStorage","$AllocatedStorage","$AllocatedLocalStorage","$AllocatedVmStorage","$AllocatedSanStorage","$wwn1","$wwn2","$wwn3","$wwn4 > /tmp/ru_output/all_values.csv
##############################
# Use filename that contains the hostname and date
# Label each value on a separate line
##############################
echo -e "Hostname:\t\t "`/bin/hostname -a` > /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total Storage:\t\t" $TotalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total Local Storage:\t" $TotalLocalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total VM Storage:\t" $TotalVmStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Total SAN Storage:\t" $TotalSanStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocate Storage:\t" $AllocatedStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated Local Storage:" $AllocatedLocalStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated VM Storage:\t" $AllocatedVmStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "Allocated SAN Storage:\t" $AllocatedSanStorage >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN1:\t\t" $wwn1 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN2:\t\t" $wwn2 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN3:\t\t" $wwn3 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
echo -e "WWN4:\t\t" $wwn4 >> /tmp/ru_output/`/bin/hostname`_`date +%F`
##############################
# Send each value to an individual file in /tmp/ru_output/
##############################
echo `/bin/hostname -a` > /tmp/ru_output/hostname
echo $TotalStorage > /tmp/ru_output/TotalStorage
echo $TotalLocalStorage > /tmp/ru_output/TotalLocalStorage
echo $TotalVmStorage > /tmp/ru_output/TotalVmStorage
echo $TotalSanStorage > /tmp/ru_output/TotalSanStorage
echo $AllocatedStorage > /tmp/ru_output/AllocatedStorage
echo $AllocatedLocalStorage > /tmp/ru_output/AllocatedLocalStorage
echo $AllocatedVmStorage > /tmp/ru_output/AllocatedVmStorage
echo $AllocatedSanStorage > /tmp/ru_output/AllocatedSanStorage
echo $wwn1 > /tmp/ru_output/WWN1
echo $wwn2 > /tmp/ru_output/WWN2
echo $wwn3 > /tmp/ru_output/WWN3
echo $wwn4 > /tmp/ru_output/WWN4
################################
cd /tmp/ru_output
################################
# Transffer output file to ftp.pcSHOWme.com
################################
FTP_HOST=ftp.pcshowme.com
FTP_LOGIN=sot@pcshowme.com
FTP_PASSWORD=l3tm31n
ftp -inv ftp.pcshowme.com<<ENDFTP
user sot@pcshowme.com l3tm31n
cd ./
bin
lcd /tmp/ru_output
put `hostname`_`date +%F`
bye
ENDFTP
exit 0
>>>>>>> origin/master
