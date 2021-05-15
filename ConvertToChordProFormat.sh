#!/bin/bash
cat FieryLove.txt | sed 's/ A / [A] /g'| sed 's/ Ab/ [Ab] /g'| sed 's/ A#/ [A#] /g' | sed 's/ B / [B] /g'| sed 's/ Bb/ [Bb] /g'| sed 's/ B#/ [B#] /g' | sed 's/ C / [C] /g'| sed 's/ Cb/ [Cb] /g'| sed 's/ C#/ [C#] /g' | sed 's/ D / [D] /g'| sed 's/ Db/ [Db] /g'| sed 's/ D#/ [D#] /g' | sed 's/ E / [E] /g'| sed 's/ Eb/ [Eb] /g'| sed 's/ E#/ [E#] /g' | sed 's/ F / [F] /g'| sed 's/ Fb/ [Fb] /g'| sed 's/ F#/ [F#] /g' | sed 's/ G / [G] /g'| sed 's/ Gb/ [Gb] /g'| sed 's/ G#/ [G#] /g' > FL1.txt

cat FL1.txt | sed ':a;N;$!ba;s/ A\n/ [A] \n /g'| sed ':a;N;$!ba;s/ B\n/ [B] \n /g'| sed ':a;N;$!ba;s/ C\n/ [C] \n /g' | sed ':a;N;$!ba;s/ D\n/ [D] \n /g'| sed ':a;N;$!ba;s/ E\n/ [E] \n /g'| sed ':a;N;$!ba;s/ F\n/ [F] \n /g'| sed ':a;N;$!ba;s/ G\n/ [G] \n /g'| sed 's/ – / [-] /g' | sed 's/ : / [:] /g' | sed 's/ :: / [::] /g'  > FL2.txt
C=0
while read LINE     
do
  $C++
  if [[ $C -eq 1 ]]; then TITLE="$( cut -d '[' -f 1 <<< "$LINE" )"; echo "$TITLE"; fi
  echo -e $LINE | sed ':a;N;$!ba;s/ \[/ \n/1' >> FL3.txt
done < FL2.txt
