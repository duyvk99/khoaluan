yum -y update
yum install -y centos-release-scl
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl zabbix-server-mysql zabbix-get zabbix-agent --enablerepo=zabbix-frontend
yum install -y mariadb-server mariadb
systemctl enable mariadb
systemctl start mariadb
DATABASE_PASS=Admin123
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
mysql -u root -p"$DATABASE_PASS" -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
cd /usr/share/doc/zabbix-server-mysql*/
zcat create.sql.gz | mysql -u zabbix -pzabbix zabbix
sed -i "92i DBHost=localhost" /etc/zabbix/zabbix_server.conf
sed -i "126i DBPassword=zabbix" /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
sed -i "s@Europe/Riga@Asia/Ho_Chi_Minh@g"/etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i "s/;//g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
reboot
