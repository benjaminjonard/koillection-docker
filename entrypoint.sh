#!/bin/bash

set -e

echo "**** Make sure the /conf and /uploads folders exist ****"
[ ! -f /conf ] && \
	mkdir -p /conf
[ ! -f /uploads ] && \
	mkdir -p /uploads

echo "**** Create the symbolic link for the /uploads folder ****"
[ ! -L /var/www/koillection/public/uploads ] && \
	cp -r /var/www/koillection/public/uploads/. /uploads && \
	rm -r /var/www/koillection/public/uploads && \
	ln -s /uploads /var/www/koillection/public/uploads

echo "**** Copy the .env to /conf ****"
[ ! -e /conf/.env.local ] && \
	touch /conf/.env.local
[ ! -L /var/www/koillection/.env.local ] && \
	ln -s /conf/.env.local /var/www/koillection/.env.local

echo "**** Inject .env values ****"
	/inject.sh

echo "**** Configure https ****"
if ! grep -q "session.cookie_secure=" /etc/php/8.1/fpm/conf.d/php.ini; then
    echo "session.cookie_secure=${HTTPS_ENABLED}" >> /etc/php/8.1/fpm/conf.d/php.ini
fi

echo "**** Migrate the database ****"
cd /var/www/koillection && \
php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod

echo "**** Create API keys ****"
cd /var/www/koillection && \
php bin/console lexik:jwt:generate-keypair --overwrite --env=prod

echo "**** Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"

echo "**** Set Permissions ****" && \
find /uploads -type d \( ! -user "$USER" -o ! -group "$USER" \) -exec chown -R "$USER":"$USER" \{\} \;
find /conf/.env.local /uploads \( ! -user "$USER" -o ! -group "$USER" \) -exec chown "$USER":"$USER" \{\} \;
usermod -a -G "$USER" www-data
find /uploads -type d \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod -R ug+w,ugo+rX \{\} \;
find /conf/.env.local /uploads \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod ug+w,ugo+rX \{\} \;

echo "**** Create nginx log files ****" && \
mkdir -p /logs/nginx
chown -R "$USER":"$USER" /logs/nginx

[ ! -f /var/www/koillection/var/logs ] && \
	mkdir -p /var/www/koillection/var/logs
[ ! -f /var/www/koillection/var/log/prod.log ] && \
	touch /var/www/koillection/var/log/prod.log

echo "**** Setup complete, starting the server. ****"
php-fpm8.1
exec $@
