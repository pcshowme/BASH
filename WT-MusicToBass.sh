#!/bin/bash

#/******************************************************************************
#
#   Bash Script to convert Worship Team standard music format to my 'ClifNotes' format ('BassNotes' if you will)...
#   I thought about doing it in Powershell so I could just scrape the website and parse it right in windows but...
#   I may still do that, but you love what you love right :-)
#
VERSION='Script: WT-MusicToBass.sh -- Version 1.06'
#   Created by Jim Bodden -- 5/18/2021
#   Modified by Jim Bodden on -- 5/19/2021
#
#/******************************************************************************

mapfile -t SongArray < SongToConvert.txt
SongArrayLength=${#SongArray[@]}

SongTitle="${SongArray[0]}"
SongComposer="${SongArray[1]}"

SectionArray=(Intro Verse Verse1 Verse2 Verse3 Verse4 Chorus Chorus1 Chorus2 Chorus3 Chorus4 Interlude Interlude1 Interlude2 Bridge Bridge1 Bridge2 Bridge3 Tag Tag1 Tag2 Tag3 Ending Ending1 Ending2 Refrain Pre-Chorus)

C=2
while [ $C -lt "$SongArrayLength" ]
do 
    LINE=${SongArray[C]}
    LINE1="${LINE//[[:blank:]]/}";
    if [[ " ${SectionArray[@]} " =~ "$LINE1" ]]; then echo "==> $LINE"; else echo "Not - $LINE"; fi 
    ((C++))
done 
echo "Song Title: $SongTitle"
echo "Composer(s): $SongComposer"

exit 0
