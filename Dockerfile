FROM debian:buster-slim

# Set version label
LABEL maintainer="Benjamin Jonard <jonard.benjamin@gmail.com>"

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='koillection'
ENV PHP_TZ=Europe/Paris

ENV BUILD_DEPS="ca-certificates apt-transport-https lsb-release wget curl git"
ENV TOOL_DEPS="nginx-light"

COPY entrypoint.sh inject.sh /

RUN \
# Add User and Group
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER" && \
# Install php 7.4 and other dependencies
    apt-get update && \
    apt-get install -y $BUILD_DEPS && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y \
    php7.4 \
    php7.4-pgsql \
    php7.4-mysql \
    php7.4-mbstring \
    php7.4-json \
    php7.4-gd \
    php7.4-xml \
    php7.4-zip \
    php7.4-fpm \
    php7.4-intl \
    php7.4-apcu \
    php7.4-xdebug \
    $TOOL_DEPS && \
# Add composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer --version && \
# Clone the repo
    mkdir -p /var/www/koillection && \
    cd /var/www/koillection && \
    chown -R www-data:www-data /var/www/koillection && \
# Clean up
    apt-get purge -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
# Set permisions
    chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

# Add custom site to apache
COPY default.conf /etc/nginx/nginx.conf
COPY php.ini /etc/php/7.4/fpm/conf.d/php.ini

EXPOSE 80
VOLUME /var/www/koillection/public/uploads
WORKDIR /var/www/koillection
HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
