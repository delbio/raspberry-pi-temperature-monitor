#!/bin/bash

#echo "The number of arguments is: $#"
#a=${@}
#echo "The total length of all arguments is: ${#a}: "

min_args=1

if (( $# < ${min_args} ))
then
    echo "Errore config fie needed"
    echo "look config-sample.cfg for an example"
    exit
fi

set -e # exit on error


# http://wiki.bash-hackers.org/howto/conffile
configfile=${1}
configfile_secured='/tmp/cool.cfg'

if [ ! -f ${configfile} ]; # config file exist
then
    echo "Error, config file: \"${configfile}\" not exist. Create it before"
    echo "look config-sample.cfg for an example"
    exit
fi

# check if the file contains something we don't want
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
  echo "Config file is unclean, cleaning it..." >&2
  # filter the original to a new file
  egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
  configfile="$configfile_secured"
fi

# now source it, either the original or the filtered variant
echo "Reading user config...." >&2
source "$configfile"

echo "Dove sono: ${0}" >&2
echo "Ripeti script ogni: $repetition_time" >&2

patterns_string=$recipients
echo "Manda mail a: $recipients" >&2

# Extract array from string
# http://stackoverflow.com/questions/10586153/bash-split-string-into-array

## declare an array variable
send_mail_to=(${patterns_string//\ / })

# get length of an array 
arraylength=${#send_mail_to[@]}

for (( i =1; i<${arraylength}+1; i++ ));
do
    echo "[" $i "/" ${arraylength} "] Send mail to: ["${send_mail_to[$i-1]}"] ..."
done
