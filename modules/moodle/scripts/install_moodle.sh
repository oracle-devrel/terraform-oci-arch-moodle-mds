#!/bin/bash
#set -x

export use_shared_storage='${use_shared_storage}'

if [[ $use_shared_storage == "true" ]]; then
  echo "Mount NFS share: ${moodle_shared_working_dir}"
  yum install -y -q nfs-utils
  mkdir -p ${moodle_shared_working_dir}
  echo '${mt_ip_address}:${moodle_shared_working_dir} ${moodle_shared_working_dir} nfs nosharecache,context="system_u:object_r:httpd_sys_rw_content_t:s0" 0 0' >> /etc/fstab
  setsebool -P httpd_use_nfs=1
  mount ${moodle_shared_working_dir}
  mount
  echo "NFS share mounted."
  cd ${moodle_shared_working_dir}
else
  echo "No mount NFS share. Moving to /var/www/" 
  cd /var/www/	
fi


wget https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz

if [[ $use_shared_storage == "true" ]]; then
  tar zxvf moodle-latest-311.tgz --directory ${moodle_shared_working_dir}
  rm -rf ${moodle_shared_working_dir}/moodle-latest-311.tgz
  mv ${moodle_shared_working_dir}/moodle ${moodle_shared_working_dir}/html
  mkdir ${moodle_shared_working_dir}/moodledata
  chown apache. -R ${moodle_shared_working_dir}/html
  chown apache. -R ${moodle_shared_working_dir}/moodledata
  cp /home/opc/index.html ${moodle_shared_working_dir}/html/index.html
  rm /home/opc/index.html
  chown apache:apache ${moodle_shared_working_dir}/html/index.html
  echo "... Changing /etc/httpd/conf/httpd.conf with Document set to new shared NFS space ..."
  sed -i 's/"\/var\/www\/html"/"\${moodle_shared_working_dir}\/html"/g' /etc/httpd/conf/httpd.conf
  echo "... /etc/httpd/conf/httpd.conf with Document set to new shared NFS space ..."
else
  tar zxvf moodle-latest-311.tgz --directory /var/www/
  rm -rf html/ moodle-latest-311.tgz
  mv moodle html
  mkdir moodledata
  chown apache. -R html
  chown apache. -R moodledata
fi 

sed -i '/memory_limit = 128M/c\memory_limit = 256M' /etc/php.ini
sed -i '/max_execution_time = 30/c\max_execution_time = 240' /etc/php.ini
sed -i '/max_input_time = 60/c\max_input_time = 120' /etc/php.ini
sed -i '/post_max_size = 8M/c\post_max_size = 50M' /etc/php.ini
sed -i '/max_input_vars = 1000/c\max_input_vars = 5000' /etc/php.ini

systemctl start httpd
systemctl enable httpd

if [[ $use_shared_storage == "true" ]]; then
  echo "... Preparing ${moodle_shared_working_dir}/html/config.php ..."
	cp /home/opc/config.php ${moodle_shared_working_dir}/html/ 
	chown apache:apache ${moodle_shared_working_dir}/html/config.php
	chown -R apache:apache ${moodle_shared_working_dir}/moodledata
  echo "... Starting ${moodle_shared_working_dir}/html/admin/cli/install_database.php ..."
	/usr/bin/php ${moodle_shared_working_dir}/html/admin/cli/install_database.php --adminuser=${moodle_admin_user} --adminpass=${moodle_admin_password} --adminemail=${moodle_admin_email} --fullname=${moodle_site_fullname} --shortname=${moodle_site_shortname} --agree-license
	chcon -Rv -t httpd_sys_rw_content_t ${moodle_shared_working_dir}/moodledata/
	chcon -Rv -t httpd_sys_rw_content_t ${moodle_shared_working_dir}/html/ 
  echo "... ${moodle_shared_working_dir}/html/admin/cli/install_database.php finished ..."
else
	cp /home/opc/config.php /var/www/html/ 
	chown apache:apache /var/www/html/config.php
	chown -R apache:apache /var/www/moodledata
	/usr/bin/php /var/www/html/admin/cli/install_database.php --adminuser=${moodle_admin_user} --adminpass=${moodle_admin_password} --adminemail=${moodle_admin_email} --fullname=${moodle_site_fullname} --shortname=${moodle_site_shortname} --agree-license
	chcon -Rv -t httpd_sys_rw_content_t /var/www/moodledata/
fi

systemctl stop httpd
systemctl start httpd

echo "Moodle installed and Apache started !"
