#!/bin/bash -eu

# setup jobs that need to be run only once when creating the container

# set permissions - only var has to be writable for the htuser
path='/var/www/html'
htuser='www-data'

chown -R root:root ${path}/
chown -R ${htuser}:${htuser} ${path}/var

# copy .htaccess, remove default subpath /vimbadmin as we want to run directly on / on our own vhost
cp ${INSTALL_PATH}/public/.htaccess.dist ${INSTALL_PATH}/public/.htaccess
sed -i "s/\/vimbadmin//g"  ${INSTALL_PATH}/public/.htaccess

# copy default configuration
cp ${INSTALL_PATH}/application/configs/application.ini.dist ${INSTALL_PATH}/application/configs/application.ini

# FIXME: setup salts!
#cat /salts >> ${INSTALL_PATH}/application/configs/application.ini
