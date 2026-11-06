#!/bin/bash
# Run on the DB server (private subnet):
#   sudo DB_PASS='<your-password>' bash setup-db.sh
set -e
: "${DB_PASS:?Set DB_PASS first}"
apt-get update -y
apt-get install -y mysql-server
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
mysql <<SQL
CREATE DATABASE IF NOT EXISTS tododb;
CREATE USER IF NOT EXISTS 'todo_user'@'10.0.%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON tododb.* TO 'todo_user'@'10.0.%';
FLUSH PRIVILEGES;
SQL
echo "DB ready."
