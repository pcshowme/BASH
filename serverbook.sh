#!/bin/bash

#/**************************************************
#
#   Linux Server (Mult-Distro) Runbook generation script
#	(Solarix, AIX, RedHat, SuSE, Mandrake, Debian, UnitedLinux)
#	Developed from the UNIX team's runbook.sh, RebooShoot.sh & additional new coding
#
#   Script: serverbook.sh -- Version 2.17
#   Created by the Jim Bodden -- 2/15/2013
#   Last Modified by Jim Bodden on -- 6/11/2013
#
#
#	Runbook Format & Information
#
#	- title "runbook for server: server_name"
#	- hostname & domain information
#	- os release & version information
#	- physical or virtual machine & vmware-tools information
#	- ifconfig networking information
#	- /etc/nam.conf file
#	- exports file -- /etc/exports
#	- netstat
#	- nis information
#	- dns servers
#	- ntp servers
#	- smtp mail server
#	- hosts file -- /etc/hosts
#	- inittab
#	- sshd config
#	- crontabs
#	- users
#	- groups
#	- sudoers -- /etc/sudoers
#	- file systems information
#	- sysctl.conf information
#	- security/limits config file info
#	- system services  run level
#	- running services
#	- processes/applications
#	- installed packages
#	- edirectory infomation (if oes is installed)
#	- end of information
#
#/**************************************************

#/**************************************************
# 	Declaraitions, functions & setup...
#/**************************************************

FILENAME1="Runbook_"$(hostname)_$(date '+%F')".txt"
echo |tee $FILENAME1 2>&1
echo "Runbook for server: $(hostname)" |tee -a $FILENAME1

divline1 ()	# Divider line for readability
{ echo |tee -a $FILENAME1
  echo "########################################"|tee -a $FILENAME1
  echo |tee -a $FILENAME1
} # End of DIVIDELINE function 

divline2 ()	# Divider line for readability
{ echo "----------------------------------------" |tee -a $FILENAME1
} # End of DIVIDELINE function 

padding ()	# Spacing for readability
{ echo |tee -a $FILENAME1
	echo |tee -a $FILENAME1
	echo |tee -a $FILENAME1
} # End of PADDING function 

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

#/**************************************************
#	Runbook start -- Hostname & Domain info
#/**************************************************
clear
divline1
echo "** HOSTNAME & DOMAIN INFORMATION" |tee -a $FILENAME1
divline2
echo "Server Name: $(hostname)" |tee -a $FILENAME1
 if [ $(uname -a | awk '{print $1}') = "Linux" ]; then
  echo "Domain Name: $(domainname)" |tee -a $FILENAME1
  echo "FQDN: $(hostname -f)" |tee -a $FILENAME1
 else
     if [ $(uname -a | awk '{print $1}') = "SunOS" ]; then
      echo "Domain Name: $(domainname)" |tee -a $FILENAME1
      echo "FQDN: $(hostname)" |tee -a $FILENAME1 
     fi
 fi
padding

#/**************************************************
#	Determin OS & Version Information
#/**************************************************

OS=`lowercase \`uname\``
KERNEL=`uname -r`
MACH=`uname -m`

OS=`uname`
    if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p`
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
        OSDIST="SOLARIS"
    elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
        OSDIST="AIX"
    elif [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
            OSDIST="RedHat"
        elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
            OSDIST="SuSE"
            OESVER=`cat /etc/novell-release | tr "\n" ' '| sed s/VERSION.*//`
        elif [ -f /etc/mandrake-release ] ; then
            DistroBasedOn='Mandrake'
            PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
            OSDIST="Mandrake"
        elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
            PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
            REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            OSDIST="Debian"
        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
            OSDIST="UnitedLinux"
        fi
        OS=`lowercase $OS`
        DistroBasedOn=`lowercase $DistroBasedOn`
    fi
divline1
echo "** VERSION INFORMATION" |tee -a $FILENAME1
divline2
if [ -n "$OS" ]; then echo "OS: $OS" |tee -a $FILENAME1; fi
if [ -n "$DIST" ]; then echo "DIST: $DIST" |tee -a $FILENAME1; fi
if [ -n "$DistroBasedOn" ]; then echo "Distro Based on: $DistroBasedOn" |tee -a $FILENAME1; fi
if [ -n "$PSUEDONAME" ]; then echo "Psuedoname: $PSUEDONAME" |tee -a $FILENAME1; fi
if [ -n "$REV" ]; then echo "Rev/Pach-Level: $REV" |tee -a $FILENAME1; fi
if [ -n "$KERNEL" ]; then echo "Kernel $KERNEL:" |tee -a $FILENAME1; fi
if [ -n "$MACH" ]; then echo "Mach: $MACH" |tee -a $FILENAME1; fi
if [ -n "$OESVER" ]; then echo "OES is installed: $OESVER" |tee -a $FILENAME1;
else 
	if [ "${OSDIST}" = "SuSE" ]; then echo "OES is not installed on this server" |tee -a $FILENAME1; fi
fi
padding

#/**************************************************
#	Physical or Virtual machine & VMware-Tools Information
#/**************************************************
divline1
echo "** PHYSICAL OR VIRTUAL MACINE" |tee -a $FILENAME1
divline2
if [ "${OS}" = "linux" ] ; then
	VM1=$(lspci | grep VMware)
	if [[ "$VM1" == *VMware* ]]
	then
		echo "This is a virtual server running on VMware." |tee -a $FILENAME1
		if [ -e /usr/bin/vmware-config-tools.pl ]; then
			echo "This server is running the VMware tools..." |tee -a $FILENAME1
			VMTVER=$(grep -E 'buildNr.*build' /usr/bin/vmware-config-tools.pl)
			echo "Version: $VMTVER" |tee -a $FILENAME1
		else
			echo "This server is NOT running the VMware tools..." |tee -a $FILENAME1
		fi
	else
		echo "This is a standalone physical server." |tee -a $FILENAME1
		echo "Serial Number: $(/usr/sbin/dmidecode -s system-serial-number)" |tee -a $FILENAME1
	fi
elif [ "${OS}" = "SunOS" ] ; then
	SUNCODE="$(/usr/sbin/smbios | egrep -i 'VMWare|VirtualBox|ESX' | wc -l)"
	if [ $SUNCODE -eq "0" ]; then
		echo "This is a standalone physical server." |tee -a $FILENAME1
		echo "Serial Number: $(/usr/sbin/smbios | egrep -i 'Serial Number' | awk '{print $2}')" |tee -a $FILENAME1
	else
		echo "Virtual Machine" |tee -a $FILENAME1   
	fi
elif [ "${OS}" = "AIX" ] ; then
	echo "AIX"
else
	echo "catch-all"
fi
padding

#/**************************************************
#	ifconfig Networking Information
#/**************************************************

divline1
echo "** IFCONFIG NETWORK INFORMATION" |tee -a $FILENAME1
divline2
/sbin/ifconfig -a |tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "Gateway Adress: $(route | grep "default" | awk '{print $2}')" |tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "ETH Interface - ifup-eth* or ifcfg-eth* file(s)" |tee -a $FILENAME1
echo |tee -a $FILENAME1
if [ -d /etc/sysconfig/network-scripts ]; then 
	cat /etc/sysconfig/network-scripts/ifup-eth* |tee -a $FILENAME1
else
	cat /etc/sysconfig/network/ifcfg-eth* |tee -a $FILENAME1
fi
padding

#/**************************************************
#	/etc/nam.conf
#/**************************************************

divline1
echo "** /ETC/NAM.CONF" |tee -a $FILENAME1
divline2
if [ -f "/etc/nam.conf" ]; then cat /etc/nam.conf |tee -a $FILENAME1; fi
padding

#/**************************************************
#	Exports file information
#/**************************************************
	
divline1
echo "** EXPORTS FILE - /ETC/EXPORTS"|tee -a $FILENAME1
divline2
if [ $(uname -a | awk '{print $1}') = "Linux" ]; then
EXPORTCODE="$(less /etc/exports | wc -l)"
 if [ $EXPORTCODE -eq "0" ]; then
  echo "/etc/exports file is empty"|tee -a $FILENAME1
   else
  cat /etc/exports|tee -a $FILENAME1
 fi
else
 if [ $(uname -a | awk '{print $1}') = "SunOS" ]; then
  DFSCODE="$(less /etc/dfs/dfstab | wc -l)"
   if [ $DFSCODE -eq "0" ]; then
    echo "/etc/dfs/dfstab file is empty"
     else
    cat /etc/dfs/dfstab|tee -a $FILENAME1
   fi
 else
  echo "No export file exists"
 fi
fi
padding

#/**************************************************
#	Networking port Information
#/**************************************************
	
divline1
echo "** NETSTAT"|tee -a $FILENAME1
divline2
netstat -nr|tee -a $FILENAME1
padding

#/**************************************************
#	NIS Information
#/**************************************************
	
divline1
echo "** NIS INFORMATION"|tee -a $FILENAME1
divline2
cat /etc/yp.conf|tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "SYSCONFIG Network Information"|tee -a $FILENAME1
cat /etc/sysconfig/network|tee -a $FILENAME1
padding

#/**************************************************
#	DNS INFORMATION
#/**************************************************
	
divline1
echo "** DNS Servers"|tee -a $FILENAME1
divline2
cat /etc/resolv.conf|tee -a $FILENAME1
padding

#/**************************************************
#	NTP INFORMATION
#/**************************************************
	
divline1
echo "** NTP SERVERS"|tee -a $FILENAME1
divline2
cat /etc/ntp.conf|tee -a $FILENAME1
padding

#/**************************************************
#	SMTP Mail Server Information
#/**************************************************
	
divline1
echo "** SMTP MAIL SERVER"|tee -a $FILENAME1
divline2
dig $(domainname) MX|tee -a $FILENAME1
padding

#/**************************************************
#	Host file Information
#/**************************************************
	
divline1
echo "** HOSTS FILE - /ETC/HOSTS"|tee -a $FILENAME1
divline2
cat /etc/hosts|tee -a $FILENAME1
padding

#/**************************************************
#	INITTAB Information
#/**************************************************
	
divline1
echo "** INITTAB"|tee -a $FILENAME1
divline2
cat /etc/inittab|tee -a $FILENAME1
padding


#/**************************************************
#	SSHD Configuration
#/**************************************************
	
divline1
echo "** SSHD CONFIG"|tee -a $FILENAME1
divline2
cat /etc/ssh/sshd_config|tee -a $FILENAME1
padding


#/**************************************************
#	Crontab Information
#/**************************************************
	
divline1
echo "** CRONTABS"|tee -a $FILENAME1
divline2
echo "$USER crontab"|tee -a $FILENAME1
crontab -l|tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "System crontab"|tee -a $FILENAME1
cat /etc/crontab|tee -a $FILENAME1
padding


#/**************************************************
#	User Information
#/**************************************************
	
divline1
echo "** USERS"|tee -a $FILENAME1
divline2
cat /etc/passwd|tee -a $FILENAME1
padding

#/**************************************************
#	Goup Information
#/**************************************************
	
divline1
echo "** GROUPS"|tee -a $FILENAME1
divline2
cat /etc/group|tee -a $FILENAME1
padding

#/**************************************************
#	SUDO'ers Information
#/**************************************************
	
divline1
echo "** SUDOERS" - /etc/sudoers|tee -a $FILENAME1
divline2
cat /etc/sudoers|tee -a $FILENAME1
padding

#/**************************************************
#	File Systems Information
#/**************************************************
	
divline1
echo "** FILE SYSTEMS INFORMATION"|tee -a $FILENAME1
divline2
df -ha|tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "FSTAB File"|tee -a $FILENAME1
cat /etc/fstab|tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "Disk Information"|tee -a $FILENAME1
/sbin/fdisk -l|tee -a $FILENAME1
padding

#/**************************************************
#	SYSCTL Information
#/**************************************************
	
divline1
echo "** SYSCTL.CONF INFORMATION"|tee -a $FILENAME1
divline2
cat /etc/sysctl.conf|tee -a $FILENAME1
padding

#/**************************************************
#	Security Limits Config file Information
#/**************************************************
	
divline1
echo "** SECURITY/LIMITS CONFIG FILE INFO"|tee -a $FILENAME1
divline2
cat /etc/security/limits.conf|tee -a $FILENAME1
padding

#/**************************************************
#	System Services/Run Level Information
#/**************************************************
	
divline1
echo "** SYSTEM SERVICES - RUN LEVEL"|tee -a $FILENAME1
divline2
/sbin/chkconfig --list|tee -a $FILENAME1
padding

#/**************************************************
#	Running Services
#/**************************************************
	
divline1
echo "** RUNNING SERVICES"|tee -a $FILENAME1
divline2
/sbin/service --status-all|tee -a $FILENAME1
padding

#/**************************************************
#	Processes/Applications
#/**************************************************
	
divline1
echo "** PROCESSES/APPLICATIONS"|tee -a $FILENAME1
divline2
echo "Root Processes"|tee -a $FILENAME1
ps -fu root | grep -v "\[*\]"|tee -a $FILENAME1
echo |tee -a $FILENAME1
echo "User Processes"|tee -a $FILENAME1
ps -ef | grep -v root|tee -a $FILENAME1
padding

#/**************************************************
#	CPU INFORMATION
#/**************************************************
	
divline1
echo  "** CPU INFORMATION"|tee -a $FILENAME1
divline2
cat /proc/cpuinfo|tee -a $FILENAME1
padding

#/**************************************************
#	Memory Information
#/**************************************************
	
divline1
echo  "** MEMORY Information"|tee -a $FILENAME1
divline2
cat /proc/meminfo|tee -a $FILENAME1
padding

#/**************************************************
#	SCSI/PCI Device Information
#/**************************************************
	
divline1
echo  "** SCSI/PCI DEVICE Information"|tee -a $FILENAME1
divline2
/sbin/lspci|tee -a $FILENAME1
padding

#/**************************************************
#	Installed Packages
#/**************************************************
	
divline1
echo "** INSTALLED PACKAGES"|tee -a $FILENAME1
divline2
 if [ $(uname -a | awk '{print $1}') = "Linux" ]; then
   rpm -qa|tee -a $FILENAME1
   echo "$(rpm -qa | wc -l) packages installed"|tee -a $FILENAME1
     else
   if [ $(uname -a | awk '{print $1}') = "SunOS" ]; then
    pkg list|tee -a $FILENAME1
    echo "$(pkg list | wc -l) packages installed"|tee -a $FILENAME1
      else
    echo "Not a Red Hat, SUSE or Solaris server"|tee -a $FILENAME1
   fi
 fi
padding

#/**************************************************
#	eDirectory INFOMATION (if OES is installed)
#/**************************************************
	
divline1
echo "** EDIRECTORY INFORMATION"|tee -a $FILENAME1
divline2
if [ -f /etc/novell-release ];
then
	divline1
	ndsstat
	ndsrepair -T >> $FILENAME1
else
	echo
fi
padding

#/**************************************************
#	End of Report Information
#/**************************************************
	
echo "** END OF INFORMATION"|tee -a $FILENAME1
echo "Runbook for server: $(hostname) completed"

################################
# Transffer output file to ftp.pcSHOWme.com
################################
FTP_HOST=ftp.pcshowme.com
FTP_LOGIN=sot@pcshowme.com
FTP_PASSWORD=l3tm31n
ftp -inv ftp.pcshowme.com<<ENDFTP
user sot@pcshowme.com l3tm31n
cd ./txdot-phase1
lcd /root/Documents
put $FILENAME1
bye
ENDFTP

#/**************************************************
# End; gracefully exit
#/**************************************************
exit

