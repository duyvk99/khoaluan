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
sed -i "s@Europe/Riga@Asia/Ho_Chi_Minh@g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i "s/;//g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i '/Listen 80/c\Listen 8080' /etc/httpd/conf/httpd.conf
systemctl restart zabbix-server httpd rh-php72-php-fpm
firewall-cmd --permanent --add-port=10050/tcp --permanent
firewall-cmd --permanent --add-port=10051/tcp --permanent
firewall-cmd --permanent --add-port=80/tcp --permanent
firewall-cmd --permanent --add-port=443/tcp --permanent
firewall-cmd --reload
yum install epel-release -y 
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm 
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum install -y nginx
yum -y install git
cd ~
git clone https://github.com/vuukhanhduy/khoaluan.git
mkdir -p /etc/nginx/conf.d/ssl
mv khoaluan/ansible/roles/add_ssl/files/* /etc/nginx/conf.d/ssl/
rm -rf khoaluan
wget https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /etc/nginx/conf.d/ssl
wget https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem -P /etc/nginx/conf.d/ssl
cat >/etc/nginx/proxy_config <<EOF
proxy_redirect      off;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header    Host            \$host;
proxy_set_header    X-Real-IP       \$remote_addr;
proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_pass_header   Set-Cookie;
proxy_connect_timeout   90;
proxy_send_timeout  90;
proxy_read_timeout  90;
proxy_buffers       32 4k;
client_max_body_size 1024m;
client_body_buffer_size 128k;
EOF
cat >/etc/nginx/conf.d/zabbix.conf <<EOF
server {
    listen 80;
    server_name zabbix.isphone.ga;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location / {
        proxy_pass http://localhost:8080;
        include /etc/nginx/proxy_config;
    }
}
EOF
mv ~/isphone.ga.conf /etc/nginx/conf.d/
nginx -t
systemctl enable nginx
systemctl restart nginx