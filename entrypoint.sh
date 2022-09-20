#!/bin/sh

set -e

echo "**** Inject .env values ****" && \
	/inject.sh

[ ! -e /tmp/first_run ] && \
	echo "**** Migrate the database ****" && \
	cd /var/www/koillection && \
	php bin/console doctrine:migration:migrate --no-interaction --allow-no-migration --env=prod && \
	touch /tmp/first_run

echo "**** Setup complete, starting the server. ****"
php-fpm8.1
exec $@