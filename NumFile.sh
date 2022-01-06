#!/bin/bash
# NumFile.sh -- Created by Jim Bodden 3/3/2015 -- Modified on: 5/6/2015
# Version 1.28
#
# Goal: Count the number of files in each file system to obtain the total number of files without duplicating paths.

declare -i TOTAL X
TOTAL=0; X=0
file=/etc/fstab
2>/dev/null rm -f /tmp/NumFile.tmp; 2>/dev/null rm -f /tmp/NumFile.csv 
# set field separator to a single white space
OLDIFS=$IFS;
while IFS=' ' read -r f1 f2 f3
do


if [[ "$f2" == "/proc" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
elif [[ "$f2" == "/dev/pts" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
elif [[ "$f2" == "swap" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
else
	X=$(2>/dev/null find $f2 -type f | wc -l)
	TOTAL=$TOTAL+$X
	printf "%-30s %15i\n" $f2 $X |tee -a /tmp/NumFile.tmp
fi
done < "$file"
printf "%-30s %15i\n" "TOTAL  " $TOTAL |tee -a /tmp/NumFile.tmp
sed 's/ \+ /,/g' /tmp/NumFile.tmp > /tmp/NumFile.csv
exit 0
#!/bin/bash
# NumFile.sh -- Created by Jim Bodden 3/3/2015 -- Modified on: 5/6/2015
# Version 1.28
#
# Goal: Count the number of files in each file system to obtain the total number of files without duplicating paths.

declare -i TOTAL X
TOTAL=0; X=0
file=/etc/fstab
2>/dev/null rm -f /tmp/NumFile.tmp; 2>/dev/null rm -f /tmp/NumFile.csv 
# set field separator to a single white space
OLDIFS=$IFS;
while IFS=' ' read -r f1 f2 f3
do


if [[ "$f2" == "/proc" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
elif [[ "$f2" == "/dev/pts" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
elif [[ "$f2" == "swap" ]]
then
	printf "%-30s %15s\n" $f2 "EXCLUDED" |tee -a /tmp/NumFile.tmp
else
	X=$(2>/dev/null find $f2 -type f | wc -l)
	TOTAL=$TOTAL+$X
	printf "%-30s %15i\n" $f2 $X |tee -a /tmp/NumFile.tmp
fi
done < "$file"
printf "%-30s %15i\n" "TOTAL  " $TOTAL |tee -a /tmp/NumFile.tmp
sed 's/ \+ /,/g' /tmp/NumFile.tmp > /tmp/NumFile.csv
exit 0
