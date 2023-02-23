#!/bin/bash

#APP_DEBUG
APP_DEBUG="${APP_DEBUG:-0}"
if grep -q APP_DEBUG "/conf/.env.local"; then
  sed -i "s|APP_DEBUG=.*|APP_DEBUG=${APP_DEBUG}|i" "/conf/.env.local"
else
  echo "APP_DEBUG=${APP_DEBUG}" >> "/conf/.env.local"
fi

#APP_ENV
APP_ENV="${APP_ENV:-prod}"
if grep -q APP_ENV "/conf/.env.local"; then
  sed -i "s|APP_ENV=.*|APP_ENV=${APP_ENV}|i" "/conf/.env.local"
else
  echo "APP_ENV=${APP_ENV}" >> "/conf/.env.local"
fi

#DB_DRIVER
DB_DRIVER="${DB_DRIVER:-}"
if grep -q DB_DRIVER "/conf/.env.local"; then
  sed -i "s|DB_DRIVER=.*|DB_DRIVER=${DB_DRIVER}|i" "/conf/.env.local"
else
  echo "DB_DRIVER=${DB_DRIVER}" >> "/conf/.env.local"
fi

#DB_NAME
if grep -q DB_NAME "/conf/.env.local"; then
  sed -i "s|DB_NAME=.*|DB_NAME=${DB_NAME}|i" "/conf/.env.local"
else
  echo "DB_NAME=${DB_NAME}" >> "/conf/.env.local"
fi

#DB_HOST
if grep -q DB_HOST "/conf/.env.local"; then
  sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|i" "/conf/.env.local"
else
  echo "DB_HOST=${DB_HOST}" >> "/conf/.env.local"
fi

#DB_PORT
if grep -q DB_PORT "/conf/.env.local"; then
  sed -i "s|DB_PORT=.*|DB_PORT=${DB_PORT}|i" "/conf/.env.local"
else
  echo "DB_PORT=${DB_PORT}" >> "/conf/.env.local"
fi

#DB_USER
if grep -q DB_USER "/conf/.env.local"; then
  sed -i "s|DB_USER=.*|DB_USER=${DB_USER}|i" "/conf/.env.local"
else
  echo "DB_USER=${DB_USER}" >> "/conf/.env.local"
fi

#DB_VERSION
if grep -q DB_VERSION "/conf/.env.local"; then
  sed -i "s|DB_VERSION=.*|DB_VERSION=${DB_VERSION}|i" "/conf/.env.local"
else
  echo "DB_VERSION=${DB_VERSION}" >> "/conf/.env.local"
fi

#DB_PASSWORD
if grep -q DB_PASSWORD "/conf/.env.local"; then
  sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|i" "/conf/.env.local"
else
  echo "DB_PASSWORD=${DB_PASSWORD}" >> "/conf/.env.local"
fi

#JWT_SECRET_KEY
if grep -q JWT_SECRET_KEY "/conf/.env.local"; then
  sed -i "s|JWT_SECRET_KEY=.*|JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem|i" "/conf/.env.local"
else
  echo "JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem" >> "/conf/.env.local"
fi

#JWT_PUBLIC_KEY
if grep -q JWT_PUBLIC_KEY "/conf/.env.local"; then
  sed -i "s|JWT_PUBLIC_KEY=.*|JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem|i" "/conf/.env.local"
else
  echo "JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem" >> "/conf/.env.local"
fi

#JWT_PASSPHRASE
JWT_PASSPHRASE=$(openssl rand -base64 21)
if grep -q JWT_PASSPHRASE "/conf/.env.local"; then
  sed -i "s|JWT_PASSPHRASE=.*|JWT_PASSPHRASE=${JWT_PASSPHRASE}|i" "/conf/.env.local"
else
  echo "JWT_PASSPHRASE=${JWT_PASSPHRASE}" >> "/conf/.env.local"
fi

#APP_SECRET
APP_SECRET=$(openssl rand -base64 21)
if grep -q APP_SECRET "/conf/.env.local"; then
  sed -i "s|APP_SECRET=.*|APP_SECRET=${APP_SECRET}|i" "/conf/.env.local"
else
  echo "APP_SECRET=${APP_SECRET}" >> "/conf/.env.local"
fi

#PHP_TZ
if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php/8.2/cli/php.ini
fi

cat /conf/.env.local