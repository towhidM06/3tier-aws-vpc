#!/bin/bash
# Run on the web server (public subnet), from the cloned repo.
# Edit nginx/todo.conf first so the upstream lists your app server private IPs.
#   sudo bash scripts/setup-web.sh
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
apt-get update -y
apt-get install -y nginx openssl
mkdir -p /var/www/todo
cp "$REPO/web/index.html" /var/www/todo/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/todo.key -out /etc/ssl/certs/todo.crt -subj "/CN=todo-app"
cp "$REPO/nginx/todo.conf" /etc/nginx/sites-available/todo
ln -sf /etc/nginx/sites-available/todo /etc/nginx/sites-enabled/todo
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx
systemctl restart nginx
echo "Web ready."
