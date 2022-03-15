#!/bin/bash
#set -x

cd /var/www/
wget https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz
tar zxvf moodle-latest-311.tgz
rm -rf html/ moodle-latest-311.tgz
mv moodle html
mkdir moodledata
chown apache. -R html
chown apache. -R moodledata

sed -i '/memory_limit = 128M/c\memory_limit = 256M' /etc/php.ini
sed -i '/max_execution_time = 30/c\max_execution_time = 240' /etc/php.ini
sed -i '/max_input_time = 60/c\max_input_time = 120' /etc/php.ini
sed -i '/post_max_size = 8M/c\post_max_size = 50M' /etc/php.ini
sed -i '/max_input_vars = 1000/c\max_input_vars = 5000' /etc/php.ini

systemctl start httpd
systemctl enable httpd

cp /home/opc/config.php /var/www/html/ 
chown apache:apache /var/www/html/config.php
chown -R apache:apache /var/www/moodledata
/usr/bin/php /var/www/html/admin/cli/install_database.php --adminuser=${moodle_admin_user} --adminpass=${moodle_admin_password} --adminemail=${moodle_admin_email} --fullname=${moodle_site_fullname} --shortname=${moodle_site_shortname} --agree-license
chcon -Rv -t httpd_sys_rw_content_t /var/www/moodledata/

echo "Moodle installed and Apache started !"
