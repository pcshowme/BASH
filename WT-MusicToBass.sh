#!/bin/bash

#/******************************************************************************
#
#   Bash Script to convert Worship Team standard music format to my 'ClifNotes' format ('BassNotes' if you will)...
#   I thought about doing it in Powershell so I could just scrape the website and parse it right in windows but...
#   I may still do that, but you love what you love right :-)
#
VERSION='Script: WT-MusicToBass.sh -- Version 1.17'
#   Created by Jim Bodden -- 5/18/2021
#   Modified by Jim Bodden on -- 5/23/2021
#
#/******************************************************************************

mapfile -t SongArray < SongToConvert.txt
SongArrayLength=${#SongArray[@]}

SongTitle="${SongArray[0]}"
SongComposer="${SongArray[1]}"

SectionArray=(Intro Verse Verse1 Verse2 Verse3 Verse4 Chorus Chorus1 Chorus2 Chorus3 Chorus4 Interlude Interlude1 Interlude2 Bridge Bridge1 Bridge2 Bridge3 Tag Tag1 Tag2 Tag3 Ending Ending1 Ending2 Refrain Pre-Chorus)
NotationArray=(Ab A# A Bb B# B Cb C# C Db D# D Eb E# E Fb F# F Gb G# G 1 2 3 4 5 6 7 8 9 sus add Maj M min m dim aug Dom dom repeat time st nd rd th x)
Notation="Ab#BCDEFGsusadd4Majmin/dimaugDomdom"
IntervalArray=(Maj maj M min m aug dim sus add Dom dom) 
CountSpaces="awk -v RS='[[:space:]]' 'END{print NR}'"
CountAlpha="awk -v RS='[[:alpha:]]' 'END{print NR}'"

### The spacing may be the key to parsing and identifying the notes vs lyrics



C=2
while [ $C -lt "$SongArrayLength" ]
do 
    echo "-----------------------------Start-------------------------------------"
    LINE=${SongArray[C]}  
    LINE1="${LINE//[[:blank:]]/}"; LINE2=$(echo $LINE1 | sed 's/\[//g'| sed 's/\]//g')   ### Detect song parts
    if [[ " ${SectionArray[@]} " =~ "$LINE2" ]]; then echo "==> $LINE"; else echo "Not - $LINE"; fi   ### Detect song parts
    SpaceNum=$(echo $LINE | eval $CountSpaces);
    AlphaNum=$(echo $LINE | eval $CountAlpha);
    LINETOTAL=$(($SpaceNum+$AlphaNum));echo $LINETOTAL
    echo "The Above line has $SpaceNum Spaces and has $AlphaNum Letters"
   # ECHO $LINE | grep -v '^>' | fold -w3 | grep -Fxe "${NotationArray[*]}" | sort | uniq -c
   # FilteredLine=$(echo $LINE | tr -d $Notation) 
   # echo $FilteredLine
#
LineTemp1=$LINE 
for i in "${NotationArray[@]}"
do
   LineTemp2=$(echo $LineTemp1 | tr -d '\/|()[]{}'); 
   #echo "VALUES: i=$i and LineTemp2=$LineTemp2"
   LineTemp1=$(echo $LineTemp2 | sed "s/$i//g") 
   LineTemp2=$LineTemp1 
done
FilteredLine=$LineTemp2
echo "FilteredLine= $FilteredLine"

    ((C++))
    echo "-----------------------------End/Next-------------------------------------"
done 
echo "Song Title: $SongTitle"
echo "Composer(s): $SongComposer"

exit 0


: <<'END'
bla bla

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D   Ab    B   " | awk '{print $1}'
G#

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($1)","NR}'
3,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($2)","NR}'
0,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($3)","NR}'
3,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($4)","NR}'
6,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($5)","NR}'
0,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($6)","NR}'
1,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($7)","NR}'
4,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($8)","NR}'
1,1

Jim@TheMachine MINGW64 ~/songs
$ Echo "   G#   D      Ab B    C " | awk -F'[^ ]' '{print length($8)","NR}'


blurfl
END

