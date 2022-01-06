#!/bin/bash

################################
# ZENworks Linux Management (ZLM) Client ISO distribution program
################################
# Source = ADC ZLM Server
# Destination = /media/nss/DATA1/SHARED
################################

ftpsend ()		# ftp delivery subroutine
{ ftp -inv $FTP_HOST<<ENDFTP
user anonymous
lcd /installs/zlm/
put ZLM73_Agent_with_IR4.iso
bye
ENDFTP
} # End of PROCTEST function

FILE1=datanames.txt
i=0
while read line; do
  ARRAY1[$i]=$line
  i=$((i+1))
done < "$FILE1"

for (( i=0; i<${#ARRAY1[@]}; i++ )); do
  echo ${ARRAY1[i]}
  FTP_HOST=${ARRAY1[i]}
  ftpsend
done

exit 0
#!/bin/bash

################################
# ZENworks Linux Management (ZLM) Client ISO distribution program
################################
# Source = ADC ZLM Server
# Destination = /media/nss/DATA1/SHARED
################################

ftpsend ()		# ftp delivery subroutine
{ ftp -inv $FTP_HOST<<ENDFTP
user anonymous
lcd /installs/zlm/
put ZLM73_Agent_with_IR4.iso
bye
ENDFTP
} # End of PROCTEST function

FILE1=datanames.txt
i=0
while read line; do
  ARRAY1[$i]=$line
  i=$((i+1))
done < "$FILE1"

for (( i=0; i<${#ARRAY1[@]}; i++ )); do
  echo ${ARRAY1[i]}
  FTP_HOST=${ARRAY1[i]}
  ftpsend
done

exit 0
