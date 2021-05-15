#!/bin/bash

#/******************************************************************************
#
#   Bash Script to batch convert songs from generic text to ChordPro format"
#
VERSION='Script: ConvertToChordProFormat.sh -- Version 1.14'
#   Created by Jim Bodden -- 5/14/2021
#   Modified by Jim Bodden on -- 5/15/2021
#
##   The improvements in this version are commented with ## as opposed to only #
#
##	Proper syntactical and format of convertion song output 

#/******************************************************************************

fconvertSongTextToChordPro () # Function converts an individual song file from plain text to ChordPro format for MobileSheets
{ #echo fconvertSongTextToChordPro
	SOURCE=$1; SOURCE="FieryLove.txt"
    cat $SOURCE | sed 's/ A / [A] /g'| sed 's/ Ab/ [Ab] /g'| sed 's/ A#/ [A#] /g' | sed 's/ B / [B] /g'| sed 's/ Bb/ [Bb] /g'| sed 's/ B#/ [B#] /g' | sed 's/ C / [C] /g'| sed 's/ Cb/ [Cb] /g'| sed 's/ C#/ [C#] /g' | sed 's/ D / [D] /g'| sed 's/ Db/ [Db] /g'| sed 's/ D#/ [D#] /g' | sed 's/ E / [E] /g'| sed 's/ Eb/ [Eb] /g'| sed 's/ E#/ [E#] /g' | sed 's/ F / [F] /g'| sed 's/ Fb/ [Fb] /g'| sed 's/ F#/ [F#] /g' | sed 's/ G / [G] /g'| sed 's/ Gb/ [Gb] /g'| sed 's/ G#/ [G#] /g' > FL1.txt

    cat FL1.txt | sed ':a;N;$!ba;s/ A\n/ [A] \n /g'| sed ':a;N;$!ba;s/ B\n/ [B] \n /g'| sed ':a;N;$!ba;s/ C\n/ [C] \n /g' | sed ':a;N;$!ba;s/ D\n/ [D] \n /g'| sed ':a;N;$!ba;s/ E\n/ [E] \n /g'| sed ':a;N;$!ba;s/ F\n/ [F] \n /g'| sed ':a;N;$!ba;s/ G\n/ [G] \n /g'| sed 's/ – / [-] /g' | sed 's/ : / [:] /g' | sed 's/ :: / [::] /g'  > FL2.txt

    C=0; IFS=$'\n'
    while read LINE     
    do
        ((C++))
        if [[ $C -eq 1 ]]; 
        then 
            TITLE="$( cut -d '[' -f 1 <<< "$LINE" )"; echo "$TITLE" > FL3.txt; 
        else
            SPLIT1="$( cut -d '[' -f 1 <<< "$LINE" )"; SPLIT2="$( cut -d '[' --complement -s -f1 <<< "$LINE" )"; 
            echo "$SPLIT1" | xargs>> FL3.txt; echo "[$SPLIT2">> FL3.txt
        fi
    done < FL2.txt
    echo "Completed!  $C Lines converted from generic text to ChordPro format"
} # End of fconvertSongTextToChordPro

################################################
#                                              #
#  Actual program execution code starts here.  #
#                                              #
################################################

fconvertSongTextToChordPro

exit 0
