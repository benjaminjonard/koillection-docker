#!/bin/sh

set -e

echo "**** Make sure the /conf and /uploads folders exist ****"
[ ! -f /conf ] && \
	mkdir -p /conf
[ ! -f /uploads ] && \
	mkdir -p /uploads

echo "**** Create the symbolic link for the /uploads folder ****"
[ ! -L /var/www/koillection/public/uploads ] && \
	ln -s /uploads /var/www/koillection/public/uploads

echo "**** Copy the .env to /conf ****"
[ ! -e /conf/.env.local ] && \
	cp /var/www/koillection/.env /conf/.env.local
[ ! -L /var/www/koillection/.env.local ] && \
	ln -s /conf/.env.local /var/www/koillection/.env.local

echo "**** Inject .env values ****"
	/inject.sh

echo "**** Configure https ****"
if ! grep -q "session.cookie_secure=" /etc/php/8.0/fpm/conf.d/php.ini; then
    echo "session.cookie_secure=${HTTPS_ENABLED}" >> /etc/php/8.0/fpm/conf.d/php.ini
fi

echo "**** Migrate the database ****"
cd /var/www/koillection && \
php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod

echo "**** Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"

echo "**** Set Permissions ****" && \
chown -R "$USER":"$USER" /conf
chown -R "$USER":"$USER" /uploads
usermod -a -G "$USER" www-data
chmod -R 775 /uploads

echo "**** Create nginx log files ****" && \
mkdir -p /logs/nginx
chown -R "$USER":"$USER" /logs/nginx

echo "**** Setup complete, starting the server. ****"
php-fpm8.0
exec $@