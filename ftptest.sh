#!/bin/bash

HOST=ftp.pcshowme.com  #This is the FTP servers host or IP address.
USER=sot@pcshowme.com             #This is the FTP user that has access to the server.
PASS=l3tm31n         #This is the password for the FTP user.

# Call 1. Uses the ftp command with the -inv switches.  -i turns off interactive prompting. -n Restrains FTP from attempting the auto-login feature. -v enables verbose and progress.

cd /tmp

ftp -inv $HOST << EOF


user $USER $PASS

put test.txt

exit
#!/bin/bash

HOST=ftp.pcshowme.com  #This is the FTP servers host or IP address.
USER=sot@pcshowme.com             #This is the FTP user that has access to the server.
PASS=l3tm31n         #This is the password for the FTP user.

# Call 1. Uses the ftp command with the -inv switches.  -i turns off interactive prompting. -n Restrains FTP from attempting the auto-login feature. -v enables verbose and progress.

cd /tmp

ftp -inv $HOST << EOF


user $USER $PASS

put test.txt

exit
