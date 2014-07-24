#!/bin/bash

#echo "The number of arguments is: $#"
#a=${@}
#echo "The total length of all arguments is: ${#a}: "

function getTemp()
{
    # alias temperature=' declare -i p; p=`cat /sys/class/thermal/thermal_zone0/temp`/1000 ; s="$p C°"; echo $s'

    local raw_temp=`cat /sys/class/thermal/thermal_zone0/temp`
    #local raw_temp=70000 # DEBUG
    local temp=$(( ${raw_temp} / 1000 ))
    echo $temp
    #echo "Temperature: ${raw_temp} value: ${temp}" >&2
}

function saveInMysql()
{
    echo "[ saveInMysql ] dati in ingresso ..."
    echo "[ saveInMysql ] DB User: ${db_user}" >&2
    echo "[ saveInMysql ] DB Pass: ${db_pass}" >&2
    echo "[ saveInMysql ] DB Name: ${db_name}" >&2
    echo "[ saveInMysql ] DB Table: ${table_name}" >&2
    echo "[ saveInMysql ] Temp: ${temp}" >&2

    # http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
    if hash mysql 2>/dev/null; then

        sh save_to_mysql_table.sh ${db_user} ${db_pass} ${db_name} ${table_name} ${temp}

    else
        echo "mysql not installed"
    fi
}

function sendMailFromRecipientFile() {
    recipient_file=${1}

    if [ ! -f $recipient_file ];
    then
        echo "Selected Recipient file: $recipient_file not found, mail not sent"
        exit
    fi

    while read email
    do
        target=$email

        echo "Send mail to: $target"

        subject="RaspBerry Pi temperatura elevata"
        message="Attenzione, la temperatura attuale: ${temp} °C superiore al limite: ${limite} °C"
        echo "${message}" | mail -s "${subject}" ${target}
        #echo "${message}" # DEBUG
    done < $recipient_file
}

function validateInput()
{
    local configfile_secured='/tmp/cool.cfg'

    echo "DB Config File exist?"

    if [ ! -f ${configfile} ]; # config file exist
    then
        echo "Error, db-config file: \"${configfile}\" not exist. Create it before"
        echo "look db-config-sample.cfg for an example"
        exit
    fi

    echo "Destination Emails Recipient file exist?"

    if [ ! -f ${recipient} ]; # recipient file exist
    then
        echo "Error, destination recipient file: \"${recipient}\" not exist. Create it before"
        echo "touch $HOME/recipient"
        exit
    fi

    echo "Validate DB Config File ..."

    # check if the file contains something we don't want
    if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
      echo "Config file is unclean, cleaning it..." >&2
      # filter the original to a new file
      egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
      configfile="$configfile_secured"
    fi
}


## END LIB

min_args=2

if (( $# < ${min_args} ))
then
    echo "Errore db-config file and destination recipient file needed"
    echo "[ usage ] bash $0 db-config-sample.cfg recipient.txt"
    exit
fi

set -e # exit on error

# http://wiki.bash-hackers.org/howto/conffile
configfile=${1}
recipient=${2}

validateInput

# now source it, either the original or the filtered variant
echo "Reading user config...." >&2
source "$configfile"

temp=$(getTemp)

saveInMysql

limite=65

if [ -n "$3" ]
then
    limite=$3
    echo "limite superiore scelto: "${limite}" °C"
else
    echo "limite non impostato, default: "${limite}" °C"
fi


if [ ${limite} -le ${temp} ]
then
    echo "Temperatura sopra la soglia ... Send Mail from recipients"
    sendMailFromRecipientFile $recipient
else
    echo "Temperatura sotto controllo, chiudo."
fi
