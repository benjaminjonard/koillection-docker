#!/bin/bash

set -e

echo "**** 1/12 - Make sure the /conf and /uploads folders exist ****"
[ ! -f /conf ] && \
	mkdir -p /conf
[ ! -f /uploads ] && \
	mkdir -p /uploads

echo "**** 2/12 - Create the symbolic link for the /uploads folder ****"
[ ! -L /srv/koillection/public/uploads ] && \
	cp -r /srv/koillection/public/uploads/. /uploads && \
	rm -r /srv/koillection/public/uploads && \
	ln -s /uploads /srv/koillection/public/uploads

echo "**** 3/12 - Copy the .env to /conf ****"
[ ! -e /conf/.env.local ] && \
	touch /conf/.env.local
[ ! -L /srv/koillection/.env.local ] && \
	ln -s /conf/.env.local /srv/koillection/.env.local

echo "**** 4/12 - Inject .env values ****"
	/inject.sh

echo "**** 5/12 - Configure https ****"
if ! grep -q "session.cookie_secure=" /etc/php/8.2/fpm/conf.d/php.ini; then
    echo "session.cookie_secure=${HTTPS_ENABLED}" >> /etc/php/8.2/fpm/conf.d/php.ini
fi

echo "**** 6/12 - Migrate the database ****"
cd /srv/koillection && \
php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod

echo "**** 7/12 - Refresh cached values ****"
cd /srv/koillection && \
php bin/console app:refresh-cached-values --env=prod

echo "**** 8/12 - Create API keys ****"
cd /srv/koillection && \
php bin/console lexik:jwt:generate-keypair --overwrite --env=prod

echo "**** 9/12 - Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"

echo "**** 10/12 - Set Permissions ****" && \
find /uploads -type d \( ! -user "$USER" -o ! -group "$USER" \) -exec chown -R "$USER":"$USER" \{\} \;
find /conf/.env.local /uploads \( ! -user "$USER" -o ! -group "$USER" \) -exec chown "$USER":"$USER" \{\} \;
usermod -a -G "$USER" www-data
find /uploads -type d \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod -R ug+w,ugo+rX \{\} \;
find /conf/.env.local /uploads \( ! -perm -ug+w -o ! -perm -ugo+rX \) -exec chmod ug+w,ugo+rX \{\} \;

echo "**** 11/12 - Create symfony log files ****" && \
[ ! -f /srv/koillection/var/log ] && \
	mkdir -p /srv/koillection/var/log

[ ! -f /srv/koillection/var/log/prod.log ] && \
	touch /srv/koillection/var/log/prod.log

chown -R www-data:www-data /srv/koillection/var

echo "**** 12/12 - Setup complete, starting the server. ****"
php-fpm8.2
exec $@

echo "**** All done ****"