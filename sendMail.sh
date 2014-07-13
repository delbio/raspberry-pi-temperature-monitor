# http://linuxconfig.org/configuring-gmail-as-sendmail-email-relay
target=$1
subject=$2
message=$3
echo "${message}" | mail -s "${subject}" ${target}
