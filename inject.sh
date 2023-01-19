#!/bin/bash
if [ "$APP_DEBUG" != '' ]; then
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=${APP_DEBUG}|i" "/var/www/koillection/.env.local"
fi
if [ "$APP_ENV" != '' ]; then
    sed -i "s|APP_ENV=.*|APP_ENV=${APP_ENV}|i" "/var/www/koillection/.env.local"
fi
if [ "$APP_SECRET" != '' ]; then
    sed -i "s|APP_SECRET=.*|APP_SECRET=${APP_SECRET}|i" "/var/www/koillection/.env.local"
fi

if [ "$DB_DRIVER" != '' ]; then
    sed -i "s|DB_DRIVER=.*|DB_DRIVER=${DB_DRIVER}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_NAME" != '' ]; then
    sed -i "s|DB_NAME=.*|DB_NAME=${DB_NAME}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_HOST" != '' ]; then
    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_PORT" != '' ]; then
    sed -i "s|DB_PORT=.*|DB_PORT=${DB_PORT}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_USER" != '' ]; then
    sed -i "s|DB_USER=.*|DB_USER=${DB_USER=}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_PASSWORD" != '' ]; then
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|i" "/var/www/koillection/.env.local"
fi
if [ "$DB_VERSION" != '' ]; then
    sed -i "s|DB_VERSION=.*|DB_VERSION=${DB_VERSION}|i" "/var/www/koillection/.env.local"
fi

if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php/8.2/cli/php.ini
fi