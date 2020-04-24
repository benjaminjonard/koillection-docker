#!/bin/sh

set -e

[ ! -e /var/www/koillection/.env.local ] && \
	cp /var/www/koillection/.env /var/www/koillection/.env.local

echo "**** Inject .env values ****" && \
	/inject.sh

[ ! -e /tmp/first_run ] && \
	echo "**** Migrate the database ****" && \
	cd /var/www/koillection && \
	php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod && \
	touch /tmp/first_run

echo "**** Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"

echo "**** Set Permissions ****" && \
usermod -a -G "$USER" www-data
chown -R www-data:www-data /var/www/koillection

echo "**** Create nginx log files ****" && \
mkdir -p /logs/nginx
chown -R "$USER":"$USER" /logs/nginx

echo "**** Setup complete, starting the server. ****"
php-fpm7.4
exec $@