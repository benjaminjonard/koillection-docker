#!/bin/bash

if [ "$APP_DEBUG" != '' ]; then
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=${APP_DEBUG}|i" "/conf/.env.local"
fi
if [ "$APP_ENV" != '' ]; then
    sed -i "s|APP_ENV=.*|APP_ENV=${APP_ENV}|i" "/conf/.env.local"
fi

if [ "$DB_DRIVER" != '' ]; then
    sed -i "s|DB_DRIVER=.*|DB_DRIVER=${DB_DRIVER}|i" "/conf/.env.local"
fi
if [ "$DB_NAME" != '' ]; then
    sed -i "s|DB_NAME=.*|DB_NAME=${DB_NAME}|i" "/conf/.env.local"
fi
if [ "$DB_HOST" != '' ]; then
    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|i" "/conf/.env.local"
fi
if [ "$DB_PORT" != '' ]; then
    sed -i "s|DB_PORT=.*|DB_PORT=${DB_PORT}|i" "/conf/.env.local"
fi
if [ "$DB_USER" != '' ]; then
    sed -i "s|DB_USER=.*|DB_USER=${DB_USER=}|i" "/conf/.env.local"
fi
if [ "$DB_PASSWORD" != '' ]; then
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|i" "/conf/.env.local"
fi
if [ "$DB_VERSION" != '' ]; then
    sed -i "s|DB_VERSION=.*|DB_VERSION=${DB_VERSION}|i" "/conf/.env.local"
fi

sed -i "s|JWT_SECRET_KEY=.*|JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem|i" "/conf/.env.local"
sed -i "s|JWT_PUBLIC_KEY=.*|JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem|i" "/conf/.env.local"

JWT_PASSPHRASE=$(openssl rand -base64 21)
sed -i "s|JWT_PASSPHRASE=.*|JWT_PASSPHRASE=${JWT_PASSPHRASE}|i" "/conf/.env.local"

APP_SECRET=$(openssl rand -base64 21)
sed -i "s|APP_SECRET=.*|APP_SECRET=${APP_SECRET}|i" "/conf/.env.local"

if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php/8.1/cli/php.ini
fi

cat /conf/.env.local