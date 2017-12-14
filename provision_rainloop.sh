#!/bin/sh

RAINLOOP_PATH=/var/www/html/rainloop
export RAINLOOP_PATH

if [ "x$RAINLOOP_ADMIN_PASSWORD" = "x" ] ; then
echo "no admin password specified. aborting."
exit 1
fi
touch /.configuring

pkgin -y in nginx unzip py27-certbot
pkgin -y in php71-curl php71-pdo_sqlite php71-fpm php71-zlib php71-json php71-iconv

rm -fr /var/www/html && \
 wget -q https://www.rainloop.net/repository/owncloud/rainloop.zip   -O /tmp/latest.zip 

if [ ! -f /tmp/latest.zip ] ; then
  echo "rainloop zip not found!"
  exit 1
fi
  
unzip /tmp/latest.zip   -d /tmp && \
  mkdir -p /var/www/html && \
  mkdir -p ${RAINLOOP_PATH} && \
  mkdir -p /var/www/html/data && \
  mv /tmp/rainloop/app/rainloop /var/www/html

  chown -R root.root ${RAINLOOP_PATH} && \
  find ${RAINLOOP_PATH} -type d -exec chmod 555 {} \; && \
  find ${RAINLOOP_PATH} -type f -exec chmod 444 {} \; && \
  rm /tmp/latest.zip

cp ${RAINLOOP_PATH}/v/*/index.php.root /var/www/html/index.php

cp /opt/local/etc/nginx/nginx.conf /opt/local/etc/nginx/nginx.conf.orig
mv /rainloop.conf /opt/local/etc/nginx/nginx.conf

cp ${RAINLOOP_PATH}/v/*/index.php.root /var/www/html/index.php
chmod 444 /var/www/html/index.php

php /adminPassword.php "/var/www/html" "$RAINLOOP_ADMIN_PASSWORD"
chown -R www.www /var/www/html/data
find /var/www/html/data -type d -exec chmod 770 {} \;
find /var/www/html/data -type f -exec chmod 660 {} \; 

mkdir -p /usr/local/bin
mkdir -p /usr/local/lib/svc/manifest
mkdir -p /usr/local/lib/svc/script

cd /usr/local/bin
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
/usr/local/bin/certbot-auto --debug

mv /letsencrypt_setup.sh /usr/local/lib/svc/script
mv /letsencrypt_setup.xml /usr/local/lib/svc/manifest

chmod 700 /usr/local/lib/svc/script/letsencrypt_setup.sh
svccfg import /usr/local/lib/svc/manifest/letsencrypt_setup.xml

/usr/sbin/svcadm disable inetd
/usr/sbin/svcadm disable pfexec

/usr/sbin/svcadm enable -r svc:/pkgsrc/php-fpm:default
#/usr/sbin/svcadm enable -r svc:/pkgsrc/nginx:default
/usr/sbin/svcadm enable -r svc:/local/letsencrypt_setup:default
(crontab -l ; echo "51 1,13 * * * /usr/local/bin/certbot-auto renew > /dev/null") | crontab
sleep 5
pkgin -y rm gcc47 gcc49 unzip \
	curl \
	gtar-base \
	less \
	nodejs \
	patch \
	postfix \
	rsyslog \
	sudo \
        diffutils \
        gawk \
        findutils \
        gsed \
pkgin -y ar
rm /.configuring
