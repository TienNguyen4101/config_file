#using ubuntu 22.04
FROM ubuntu:22.04

#update and upgrade ubuntu
RUN apt update && apt upgrade -y

#install nginx
RUN apt install nginx -y

#install mariadb
RUN apt install mariadb-server -y \
    && apt install mariadb-client -y

RUN apt install wget -y

#Download file config in github
RUN wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/mysql_secure.sh

# Grant permission file in docker
RUN chmod u+x mysql_secure.sh

#run mysql_secure_installaiton
RUN service nginx start \
    && service mariadb start \
    && ./mysql_secure.sh

RUN apt-get install software-properties-common -y \
    && add-apt-repository ppa:ondrej/php -y

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select Asia" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Asia select Vietnam" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y tzdata

# install packet for php 7.4
RUN apt install php7.4-fpm php7.4-imagick php7.4-common php7.4-mysql php7.4-gmp php7.4-imap php7.4-json \
    php7.4-pgsql php7.4-ssh2 php7.4-sqlite3 php7.4-ldap php7.4-curl php7.4-intl \
    php7.4-mbstring php7.4-xmlrpc php7.4-gd php7.4-xml php7.4-cli php7.4-zip -y

#Remove default file php.ini in /etc/php/7.4/fpm/ and download file php.ini modify in github
RUN cd /etc/php/7.4/fpm/ \
    && rm php.ini \
    && wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/php.ini

#Start nginx,mariadb/ get file bash script in github /grant permission execute to run script create database and grant permission account database
RUN service nginx start \
    && service mariadb start \
    && wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/create_database.sh \
    && chmod u+x create_database.sh\
    && ./create_database.sh

#Get source code owncloud server and unzip it to /var/www
RUN wget https://download.owncloud.com/server/stable/owncloud-complete-latest.zip \
    && apt install unzip -y\
    && unzip owncloud-complete-latest.zip -d /var/www/

#Grant chown and chmod
RUN chown -R www-data:www-data /var/www/owncloud/ \
    && chmod -R 755 /var/www/owncloud/

#Download file owncloud.conf in github
RUN cd /etc/nginx/sites-available/ \
    && wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/owncloud.conf

#remove file default of nginx to fix the conflict nginx homepage and owncloud / Alias link /etc/nginx/sites-enabled/ to /etc/nginx/sites-available/owncloud.conf
RUN rm -rf /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/owncloud.conf /etc/nginx/sites-enabled/

RUN wget https://raw.githubusercontent.com/TienNguyen4101/config_file/main/start_service.sh \
    && chmod u+x start_service.sh

CMD service mariadb start \
    && service nginx start \
    && service php7.4-fpm start \
    && tail -f /var/log/nginx/access.log


#docker build -t owncloud_image .
#docker run --name owncloud_container -p 8080:80 -it owncloud_image
#docker run --name owncloud_container -p 80:80 -dit owncloud_image
#docker exec -it owncloud_container bash
#sudo chown -R www-data:www-data /var/www/html/owncloud/data
#docker run --name owncloud_container -p 12345:80 -v /data/owncloud_test/data_in_owncloud:/var/www/owncloud/data -dit owncloud_container
#create user in github: https://raw.githubusercontent.com/TienNguyen4101/config_file/main/create_database.sh
