command="bash $(pwd)/test-load_config_file.sh $1"
job="1 * * * * ${command}"
echo "$job"
#cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
crontab -l
