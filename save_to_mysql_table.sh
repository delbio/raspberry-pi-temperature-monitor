user=${1}
pass=${2}
db_name=${3}
table=${4}
temperature=${5}

echo "INSERT INTO ${table} (time, temperature) VALUES" >> $HOME/line.sql
echo "( NOW(), '"${temperature}"');" >> $HOME/line.sql

mysql -u ${user} --password=${pass} ${db_name} < $HOME/line.sql
rm $HOME/line.sql
