#!/bin/bash -ex

sed -i "s/PRIMARY_HOSTNAME/${HOSTNAME}/g"  /var/www/html/public/mail/config-v1.1.xml
sed -i "s/PRIMARY_HOSTNAME/${HOSTNAME}/g"  /var/www/html/public/mail.mobileconfig.php
sed -i "s/UUID2/$(cat /proc/sys/kernel/random/uuid)/g"  /var/www/html/public/mail.mobileconfig.php
sed -i "s/UUID4/$(cat /proc/sys/kernel/random/uuid)/g"  /var/www/html/public/mail.mobileconfig.php

APP_CONFIG=${INSTALL_PATH}/application/configs/application.ini.base
sed -i "/resources.doctrine2.connection.options.password/d" ${APP_CONFIG}
sed -i "/\[user\]/a resources.doctrine2.connection.options.password = '${MYSQL_PASSWORD}'" ${APP_CONFIG}

sed -i "/resources.doctrine2.connection.options.host/d" ${APP_CONFIG}
sed -i "/\[user\]/a resources.doctrine2.connection.options.host = 'db'" ${APP_CONFIG}

sed -i "/defaults.mailbox.password_salt/d" ${APP_CONFIG}
sed -i "/\[user\]/a resources.doctrine2.connection.options.host = '${SALT_MAILBOX}'" ${APP_CONFIG}

sed -i "/securitysalt/d" ${APP_CONFIG}
sed -i "/\[user\]/a securitysalt = '${SALT_SECURITY}'" ${APP_CONFIG}

APP_CONFIG_INI=${INSTALL_PATH}/application/configs/application.ini
cp $APP_CONFIG $APP_CONFIG_INI


# append custom config
if [ -f /tmp/docker-vimbadmin/application.ini ]; then
  cat /tmp/docker-vimbadmin/application.ini >> $APP_CONFIG_INI
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

for ((i=0;i<3;i++))
do
    DB_CONNECTABLE=$(mysql -uvimbadmin -p${MYSQL_PASSWORD} -hdb -P3306 -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ DB_CONNECTABLE -eq 0 ]]; then
      if [ $(mysql -N -s -uvimbadmin -p${MYSQL_PASSWORD} -hdb -e \
        "select count(*) from information_schema.tables where \
          table_schema='vimbadmin' and table_name='domain';") -eq 1 ]; then
        exec "$@"
      else
        echo "Creating DB"
        ./bin/doctrine2-cli.php orm:schema-tool:create

        if [ -n "${ADMIN_EMAIL}" ] && [ -n "${ADMIN_PASSWORD}" ]; then
          echo "Creating Superuser"
          HASH_PASS=`php -r "echo password_hash('${ADMIN_PASSWORD}', PASSWORD_DEFAULT);"`
          mysql -u vimbadmin -p${MYSQL_PASSWORD} -h db vimbadmin -e \
            "INSERT INTO admin (username, password, super, active, created, modified) VALUES ('${ADMIN_EMAIL}', '$HASH_PASS', 1, 1, NOW(), NOW())"
        fi

        echo "Vimbadmin setup completed successfully"
        exec "$@"
      fi
    fi
    sleep 5
done

exit 1
