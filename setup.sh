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
sed -i "s/SetEnv APPLICATION_ENV production/SetEnv APPLICATION_ENV docker/" ${INSTALL_PATH}/public/.htaccess

# copy default configuration
cp ${INSTALL_PATH}/application/configs/application.ini.dist ${INSTALL_PATH}/application/configs/application.ini.base

# setup salts
APP_CONFIG=${INSTALL_PATH}/application/configs/application.ini.base

# set random rememberme salt
SALT=`</dev/urandom tr -dc 'A-Za-z0-9!#%()*+,-./:;<>?@[\]^_{|}~' | head -c 64  ; echo`
sed -i "/resources.auth.oss.rememberme.salt/d" ${APP_CONFIG}
sed -i "/\[user\]/a resources.auth.oss.rememberme.salt = '${SALT}'" ${APP_CONFIG}

# set crypt default
sed -i "/defaults.mailbox.password_scheme/d" ${APP_CONFIG}
sed -i "/\[user\]/a defaults.mailbox.password_scheme = 'crypt:sha512'" ${APP_CONFIG}

# turn off errors for production
sed -i "s/startup_errors = 1/startup_errors = 0/" ${APP_CONFIG} 
sed -i "s/display_errors = 1/display_errors = 0/" ${APP_CONFIG} 
sed -i "s/displayExceptions = 1/displayExceptions = 0/" ${APP_CONFIG} 

printf "\n\n[docker : production]\n\n" >> ${APP_CONFIG}
