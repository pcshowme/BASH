#!/bin/bash

#Define the string to split
text="learnHTMLlearnPHPlearnMySQLlearnJavascript"

#Define multi-character delimiter
delimiter="learn"
#Concatenate the delimiter with the main string
string=$text$delimiter

#Split the text based on the delimiter
myarray=()
while [[ $string ]]; do
  myarray+=( "${string%%"$delimiter"*}" )
  string=${string#*"$delimiter"}
done

#Print the words after the split
for value in ${myarray[@]}
do
  echo -n "$value "
done
printf "\n"