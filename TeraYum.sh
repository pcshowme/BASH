#!/bin/bash

# Script to remwdiate a faling yum configuration
# by wiping the old and creating a working new install

#-----------------Set up functions-----------------

ConfigBack () {# Backup the existing yum configuration
    YumConf=$(cat /etc/yum.conf)
    YumReposD=(`ls *.*`)
    
    echo "$YumConf"
    echo ${YumReposD[3]}
}

# Make a backup of the origenal yum configuration
