#!/bin/bash
# Run on each app server (private subnet), from the cloned repo:
#   sudo DB_HOST=<db-private-ip> DB_PASS='<your-password>' bash scripts/setup-app.sh
set -e
: "${DB_HOST:?Set DB_HOST}"; : "${DB_PASS:?Set DB_PASS}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
apt-get update -y
apt-get install -y python3-venv python3-pip
mkdir -p /opt/todo-app
cp -r "$REPO/app/." /opt/todo-app/
chown -R ubuntu:ubuntu /opt/todo-app
sudo -u ubuntu python3 -m venv /opt/todo-app/venv
sudo -u ubuntu /opt/todo-app/venv/bin/pip install -r /opt/todo-app/requirements.txt
cat > /etc/todo-app.env <<EOF
DB_HOST=${DB_HOST}
DB_USER=todo_user
DB_PASS=${DB_PASS}
DB_NAME=tododb
EOF
chmod 600 /etc/todo-app.env
cp /opt/todo-app/todo-app.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now todo-app
systemctl status todo-app --no-pager
