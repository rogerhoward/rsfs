#!/usr/bin/env bash

cat >> /home/vagrant/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCvXcDMYaZIPcnjh9NAOEXmC6JSyu/oA/zC3v0sq84ZgveHHBX6nJKCKz64ScYlXfRiTTkR+IkZerU4+HITbKKfB20xfEe7GB7iVKo0ymX5GS5IuQuvmhvSFTf1ThsTlLCXXMKcWhjWfVZDL1UNC9HQczRg1QMZ5JphRbrIEaGjyQ== rogerhoward@rene.local
EOF

sudo su

# Update and install dependencies
echo "Updating and installing dependencies..."
# sudo apt-get update
apt-get -y debconf-utils curl wget htop avahi-daemon avahi-utils git unzip

debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password rootpass"
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password rootpass"

apt-get -y install mysql-server-5.5
apt-get -y install apache2 php5 php5-mysql php5-mcrypt php5-cli php5-gd php5-json php5-curl

# RS setup
echo "Downloading ResourceSpace..."
mkdir -p /var/www/rspace
cd /var/www/rspace
wget http://www.resourcespace.org/downloads/ResourceSpace_7_6_7683.zip -O rspace.zip
unzip rspace

# Apache conf
echo "Configuring Apache..."
rm -fR /etc/apache2/sites-enabled/000-default.conf
cat >> /etc/apache2/sites-available/rspace.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/rspace

    ErrorLog ${APACHE_LOG_DIR}/rspace.error.log
    CustomLog ${APACHE_LOG_DIR}/rspace.access.log combined
</VirtualHost>
<VirtualHost *:4567>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/rspace

    ErrorLog ${APACHE_LOG_DIR}/rspace.error.log
    CustomLog ${APACHE_LOG_DIR}/rspace.access.log combined
</VirtualHost>
EOF

cat >> /etc/apache2/mods-enabled/dir.conf <<EOF
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF

ln -s /etc/apache2/sites-available/rspace.conf /etc/apache2/sites-enabled/rspace.conf

# PHP settings
echo "Configuring PHP..."

php_memory_limit=256M #or what ever you want it set to
sed -i 's/memory_limit = .*/memory_limit = '${php_memory_limit}'/' /etc/php5/apache2/php.ini

php_post_max_size=256M #or what ever you want it set to
sed -i 's/post_max_size = .*/post_max_size = '${php_post_max_size}'/' /etc/php5/apache2/php.ini

php_upload_max_filesize=256M #or what ever you want it set to
sed -i 's/upload_max_filesize = .*/upload_max_filesize = '${php_upload_max_filesize}'/' /etc/php5/apache2/php.ini


# ImageMagic settings
echo "Configuring ImageMagic..."
apt-get -y install imagemagick


# Apache cleanup
echo "Cleaning up after Apache..."

rm -fR /var/www/html
chown -R www-data:www-data /var/www/rspace
service apache2 restart

# MySQL setup
echo "Configuring MySQL..."
if [ ! -f /var/log/databasesetup ];
then
    # Setup database, user and priveleges
    echo "CREATE DATABASE rspace" | mysql -h 127.0.0.1 -uroot -prootpass
    echo "flush privileges" | mysql -h 127.0.0.1 -uroot -prootpass
    # Set flag file
    touch /var/log/databasesetup
fi

service mysql restart

# make sure mysql max connections are set high for testing
echo "set global max_connections = 1000;" | mysql -h 127.0.0.1 -uroot -prootpass


# Vagrant completed
echo "Vagrant deployment completed..."
echo "You may access your new instance:"
echo "via http:  http://127.0.0.1:4567"