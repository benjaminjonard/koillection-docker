#!/bin/bash

set -e

echo "**** 1/13 - Make sure the /conf and /uploads folders exist ****"
[ ! -f /conf ] && \
	mkdir -p /conf
[ ! -f /uploads ] && \
	mkdir -p /uploads

echo "**** 2/13 - Create the symbolic link for the /uploads folder ****"
[ ! -L /app/public/uploads ] && \
	cp -r /app/public/uploads/. /uploads && \
	rm -r /app/public/uploads && \
	ln -s /uploads /app/public/uploads

echo "**** 3/13 - Copy the .env to /conf ****"
[ ! -e /conf/.env.local ] && \
	touch /conf/.env.local
[ ! -L /app/.env.local ] && \
	ln -s /conf/.env.local /app/.env.local

echo "**** 4/13 - Inject .env values ****"
	/inject.sh

echo "**** 5/13 - Configure https ****"
if ! grep -q "session.cookie_secure=" /etc/php/8.2/fpm/conf.d/php.ini; then
    echo "session.cookie_secure=${HTTPS_ENABLED}" >> /etc/php/8.2/fpm/conf.d/php.ini
fi

echo "**** 6/13 - Migrate the database ****"
cd /app && \
php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod

echo "**** 7/13 - Refresh cached values ****"
cd /app && \
php bin/console app:refresh-cached-values --env=prod

echo "**** 8/13 - Create API keys ****"
cd /app && \
php bin/console lexik:jwt:generate-keypair --overwrite --env=prod

echo "**** 9/13 - Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"

echo "**** 10/13 - Set Permissions ****" && \
find /uploads -type d \( ! -user "$USER" -o ! -group "$USER" \) -exec chown -R "$USER":"$USER" \{\} \;
find /conf/.env.local /uploads \( ! -user "$USER" -o ! -group "$USER" \) -exec chown "$USER":"$USER" \{\} \;
usermod -a -G "$USER" www-data
find /uploads -type d \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod -R ug+w,ugo+rX \{\} \;
find /conf/.env.local /uploads \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod ug+w,ugo+rX \{\} \;

echo "**** 11/13 - Create nginx log files ****" && \
mkdir -p /logs/nginx
chown -R "$USER":"$USER" /logs/nginx

echo "**** 12/13 - Create symfony log files ****" && \
[ ! -f /app/var/log ] && \
	mkdir -p /app/var/log

[ ! -f /app/var/log/prod.log ] && \
	touch /app/var/log/prod.log

chown -R www-data:www-data /app/var

echo "**** 13/13 - Setup complete, starting the server. ****"
frankenphp run --config /etc/Caddyfile
exec "$@"

echo "**** All done ****"