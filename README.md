# bytecast-de / docker-vimbadmin

Standalone apache / php5.6 container, running fully installed and configured vimbadmin (https://www.vimbadmin.net/)

Based on https://github.com/indiehosters/docker-vimbadmin

Getting started:

 * The application needs a mysql-container to be linked (see docker-compose.example.yml)
 * You have to create the database and user inside the mysql-container manually:

```
CREATE DATABASE `vimbadmin`;
GRANT ALL ON `vimbadmin`.* TO `vimbadmin`@`%` IDENTIFIED BY 'XXX';
FLUSH PRIVILEGES;
```

 * Make sure to change the passwords!
 * Database tables and the superdmin user will be automatically initialized (if they do not exist) during startup of the vimbadmin-container as soon as there is a valid database connection / credentials. 
 * See docker-compose.example.yml for more information about mandatory environment variables and how to use.

TODOs:
 * setup / configure salts via environment
 * memcached
