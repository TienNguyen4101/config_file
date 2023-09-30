sudo yum update -y
yum install epel-release -y
yum install wget -y
yum install git -y

sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum-config-manager --enable remi-php74
sudo yum update -y
sudo yum install php php-cli -y
sudo yum install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json -y

yum install httpd -y
yum install phpmyadmin -y
yum install expect -y
sudo wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install htop -y
yum install nano -y
#shut the fuckup firewall

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld

mkdir /data
cd /data

sudo rpm -Uvh mysql80-community-release-el7-3.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum install mysql-server -y
sudo systemctl start mysqld

#install httpd

systemctl start httpd
systemctl enable httpd

#install php
 

systemctl restart httpd

#install phpmyadmin

systemctl restart httpd

cd /etc/httpd/conf.d/
rm -f phpMyAdmin.conf
wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/phpMyAdmin.conf

# Config mysql_secure_installation 

sudo grep 'password' /var/log/mysqld.log >> password.txt
mysql_password=$(grep "A temporary password is generated" password.txt | awk -F ': ' '{print $NF}')
echo $mysql_password

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Securing the MySQL server deployment\"
expect \"Enter password for user root:\"
send \"$mysql_password\r\"
expect \"New password:\"
send \"Admin@123\r\"
expect \"Re-enter new password:\"
send \"Admin@123\r\"
expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"

expect eof
")
echo "${SECURE_MYSQL}"

#Config mysql

Config_MySql=$(expect -c "

set timeout 3
spawn mysql -u root -p
expect \"Enter password:\"
send \"Admin@123\r\"
set timeout 3
expect \"mysql>\"
send \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Admin@123';\r\"
send \"quit;\r\"

expect eof
")
echo "${Config_MySql}"


#Set ip addr
cd /etc/httpd/conf.d/
ip a show ens33 >> ip_addr.txt
ip_addr=$(grep -oP 'inet \K[0-9.]+' ip_addr.txt)

config_file="phpMyAdmin.conf"

sed -i "25s/.*/Allow from 127.0.0.1 $ip_addr/" "$config_file"
systemctl restart httpd

echo "Domain: $ip_addr/phpmyadmin  -  Username: root - Password: Admin@123"
