
min_args=2

if (( $# < ${min_args} ))
then
    echo "Errore db-config file and recipient file is needed"
    exit
fi

db_config_file=${1}

if [ ! -f $db_config_file ];
then
        echo "Selected db-config file: $db_config_file not found"
        exit
fi

recipient_file=${2}

if [ ! -f $recipient_file ];
then
        echo "Selected Recipient file: $recipient_file not found"
        exit
fi

limite=${3}

if [ -n "$3" ]
then
    if [ "$limite" -eq "$limite" ] 2>/dev/null;
    then
        echo "Correct Parameters"
    else
        echo "Selected max limit not a number"
        exit
    fi
fi

minute=6

debug_command="cd $(pwd); sudo bash temp_monitor.sh ${db_config_file} ${recipient_file} ${limite} 2<&1 >> $(pwd)/debug-temp.txt"

command="cd $(pwd); sudo bash temp_monitor.sh ${db_config_file} ${recipient_file} ${limite}"
job="*/${minute} * * * * ${command}"

cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
crontab -l
