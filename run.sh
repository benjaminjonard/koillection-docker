#!/bin/sh
cd /koillection && php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod
mkdir -p /logs/nginx
chown -R $UID:$GID /etc/nginx /etc/php7 /var/log /var/lib/nginx /tmp /koillection /etc/s6.d /run /logs/nginx
exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
