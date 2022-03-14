#!/bin/bash

moodleschema="${moodle_schema}"
moodlename="${moodle_name}"

mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE DATABASE $moodleschema;"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER $moodlename identified by '${moodle_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON $moodleschema.* TO $moodlename;"

echo "Moodle Database and User created !"
echo "MOODLE USER = $moodlename"
echo "MOODLE SCHEMA = $moodleschema"
