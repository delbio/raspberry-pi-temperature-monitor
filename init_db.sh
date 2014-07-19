#!/bin/bash

set -e # exit on error

min_args=1

if (( $# < ${min_args} ))
then
    echo "Error config.cfg file is needed"
    exit
fi

# Load config file -- http://wiki.bash-hackers.org/howto/conffile
configfile=${1}
init_db_sql_file=/tmp/init_db_file.sql
configfile_secured='/tmp/cool.cfg'

touch ${init_db_sql_file}

if [ ! -e ${configfile} ]  # config file exist?
then
    echo "Error: ${configfile} not exist. Create it before"
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
source "$configfile"

user=$db_user
user_pass=$db_pass
name_db=$db_name

tables_name_string=$table_name

# Extract array from string
# http://stackoverflow.com/questions/10586153/bash-split-string-into-array

## declare an array variable
table_names=(${tables_name_string//\ / })

# get length of an array
arraylength=${#table_names[@]}

rm ${init_db_sql_file}

# Create DB if not esist
echo "Create DB ..."
echo "CREATE DATABASE IF NOT EXISTS ${name_db};" >> ${init_db_sql_file}

echo "USE ${name_db};" >> ${init_db_sql_file}

# use for loop read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do

    echo "[" $i "/" ${arraylength} "] Create table ${table_names[$i-1]} in DB ${name_db} ..."
    echo "CREATE TABLE IF NOT EXISTS ${table_names[$i-1]} (id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, time DATETIME NOT NULL, temperature INT NOT NULL);" >> ${init_db_sql_file}

done

echo "GRANT ALL PRIVILEGES ON ${name_db}.* TO '${user}'@'localhost' IDENTIFIED BY '${user_pass}';" >> ${init_db_sql_file}
echo "FLUSH PRIVILEGES;" >> ${init_db_sql_file}

# http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
if hash mysql 2>/dev/null; then

    # get input from user
    # http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_08_02.html

    echo  "You want to init db, tables and user to MySQL? type [Y/n] followed by [ENTER]: "

    read isYes

    case "$isYes" in
    'Y')
        echo "Select credential to access mysql";
	echo "Enter user name:"
	read actual_user
	echo "Enter password:"
	read actual_pass
        mysql -u ${actual_user} --password=${actual_pass} < ${init_db_sql_file} && rm ${init_db_sql_file}; 
        ;;
    *)
        #do_nothing;;
	echo "Copyng db import to $(pwd)/db_import.sql"
	cp ${init_db_sql_file} $(pwd)/db_import.sql && rm ${init_db_sql_file}
    esac

else
	echo "mysql not installed"
	echo "Copyng db import to $(pwd)/db_import.sql"
	cp ${init_db_sql_file} $(pwd)/db_import.sql && rm ${init_db_sql_file}
	exit
fi
