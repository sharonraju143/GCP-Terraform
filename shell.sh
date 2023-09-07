#!/bin/bash
apt-get update -y
apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql
systemctl start apache2
systemctl enable apache2
systemctl start mysql
systemctl enable mysql
sudo usermod -a -G www-data $(whoami)
sudo chown -R $(whoami):www-data /var/www/html
sudo chmod -R 2775 /var/www/html
find /var/www/html -type d -exec sudo chmod 2775 {} \;
find /var/www/html -type f -exec sudo chmod 0664 {} \;
sudo rm -r /var/www/html/*
sudo git clone https://github.com/sharonraju143/AWS-Project.git /var/www/html --recursive