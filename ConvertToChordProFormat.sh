#!/bin/bash

#/******************************************************************************
#
#   Bash Script to batch convert songs from generic text to ChordPro format"
#
VERSION='Script: ConvertToChordProFormat.sh -- Version 1.53'
#   Created by Jim Bodden -- 5/14/2021
#   Modified by Jim Bodden on -- 5/18/2021
#
#/******************************************************************************

FconvertSetListToIndividualSongs () # Function converts a file with a setlist of songs to individual song files
{ #echo FconvertSetListToIndividualSongs

for FILE in t-*.txt
   do
        echo $FILE
        SC=0; LC=0; IFS=$'\n'
        while read LINE
        do
            ((LC++));
            if [[ "$LINE" == *"Key:"* ]];
            then
                ((SC++));
                TITLE="$( cut -d"[" -f1 <<< "$LINE" | xargs )"
                SongFile="s-"${TITLE//[[:blank:]]/};
                if [ ! -f "$SongFile.txt" ];
                then
                    NAME="$SongFile"; i=0
                    while [[ -e $NAME-$i.txt || -L $NAME-$i.txt ]] ; 
                    do
                        ((i++))
                    done
                    SongFile="$NAME-$i"
                    echo "Creating individual text file $SC ==> $SongFile.txt"
                    echo "$TITLE" > "$SongFile.txt"

                fi
            else
                echo $LINE >> "$SongFile.txt"
                ((LC++));
            fi
        done < $FILE
    done

} # End of FconvertSetListToIndividualSongs


FconvertSongTextToChordPro () # Function converts an individual song file from plain text to ChordPro format for MobileSheets
{ #echo FconvertSongTextToChordPro
    SongDir="~/songs"
    for FILE in s-*.txt
    do
	    SOURCE=$FILE; ### SOURCE="s-HolyWater.txt"

        
        A="sed 's/A / [A] /g'| sed 's/Ab/ [Ab] /g'| sed 's/A#/ [A#] /g'| sed ':a;N;$!ba;s/ A\n/ [A] \n /g'"
        B="sed 's/B / [B] /g'| sed 's/Bb/ [Bb] /g'| sed 's/B#/ [B#] /g'| sed ':a;N;$!ba;s/ B\n/ [B] \n /g'"
        C="sed 's/C / [C] /g'| sed 's/Cb/ [Cb] /g'| sed 's/C#/ [C#] /g'| sed ':a;N;$!ba;s/ C\n/ [C] \n /g'"
        D="sed 's/D / [D] /g'| sed 's/Db/ [Db] /g'| sed 's/D#/ [D#] /g'| sed ':a;N;$!ba;s/ D\n/ [D] \n /g'"
        E="sed 's/E / [E] /g'| sed 's/Eb/ [Eb] /g'| sed 's/E#/ [E#] /g'| sed ':a;N;$!ba;s/ E\n/ [E] \n /g'"
        F="sed 's/F / [F] /g'| sed 's/Fb/ [Fb] /g'| sed 's/F#/ [F#] /g'| sed ':a;N;$!ba;s/ F\n/ [F] \n /g'"
        G="sed 's/G / [G] /g'| sed 's/Gb/ [Gb] /g'| sed 's/G#/ [G#] /g'| sed ':a;N;$!ba;s/ G\n/ [G] \n /g'"
        DASH="sed 's/Pre-Chorus/PreChorus/'| sed 's/-://'| sed 's/-/[-]/g'| sed 's/::/[::]/g'"
        REM="sed 's/()-://g'| sed 's/() -:)//g'| sed 's/()://g'| sed 's/(...)//g'| sed 's/()//g'| sed 's/):/)/g'"
        cat $SOURCE | eval $A | eval $B | eval $C | eval $D | eval $E | eval $F | eval $G | eval $DASH | eval $REM > SongChordPro.txt 
        
        C=0; IFS=$'\n'
        while read LINE     
        do
            ((C++))
            if [[ $C -eq 1 ]]; 
            then 
                TITLE="$( cut -d '[' -f 1 <<< "$LINE" )"; echo "$TITLE" | tee FL1.txt; 
            else
                SPLIT1="$( cut -d '[' -f 1 <<< "$LINE" )"; SPLIT2="$( cut -d '[' --complement -s -f1 <<< "$LINE" )"; 
                if test ! -z "$LINE" 
                then
                    echo "$SPLIT1" | xargs | tee -a FL1.txt; 
                    echo "[$SPLIT2" | tee -a FL1.txt
                fi
            fi
        done < ./SongChordPro.txt 
        FinalSongTitle="M-"${TITLE//[[:blank:]]/}"-BASS.txt";
        #cp FL1.txt "M-$TITLE-BASS.txt"
        cp FL1.txt ./$FinalSongTitle
        echo "Completed!  $C Lines converted from generic text to ChordPro format"
    done
} # End of FconvertSongTextToChordPro


FformatConvertedSong () # Function to better format converted song for MobileSheets
{ #echo FformatConvertedSong

    for FILE in M-*-BASS.txt
    do
	    FILENAME1=$FILE; ### FILENAME1="M-TrueReligion-BASS.txt"
        FILENAME2=$(echo "$FILENAME1" | awk '{ print substr( $0, 1, length($0)-7 ) }')".txt"
        mapfile -t SongArray < $FILENAME1  
        SongArrayLength=${#SongArray[@]}
        echo ${SongArray[0]} | tee $FILENAME2
        echo " " | tee -a $FILENAME2
        echo ${SongArray[1]} | tee -a $FILENAME2
        N=2
        while [ $N -lt "$SongArrayLength" ]
        do 
            if [[ "${SongArray[N+1]}" != "["* ]]
            then
                echo ${SongArray[N]} | tee -a $FILENAME2
            else
                echo " " | tee -a $FILENAME2
                echo ${SongArray[N]} | tee -a $FILENAME2
            fi 
            ((N++))
        done
    done        
} # End of FformatConvertedSong


#/******************************************************************************
################################################
#                                              #
#  Actual program execution code starts here.  #
#                                              #
################################################

FconvertSetListToIndividualSongs
FconvertSongTextToChordPro
FformatConvertedSong

exit 0

