FROM debian:bullseye-slim

# Set version label
LABEL maintainer="Benjamin Jonard <jonard.benjamin@gmail.com>"

ARG GITHUB_RELEASE

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='koillection'
ENV PHP_TZ=Europe/Paris
ENV HTTPS_ENABLED=$HTTPS_ENABLED

ENV BUILD_DEPS="ca-certificates apt-transport-https lsb-release wget git yarn gnupg2"
ENV TOOL_DEPS="nginx-light curl"

COPY entrypoint.sh inject.sh /

RUN \
# Add User and Group
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER" && \
# Install php 8.0 and other dependencies
    apt-get update && \
    apt-get install -y $BUILD_DEPS $TOOL_DEPS && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y \
    php8.0 \
    php8.0-pgsql \
    php8.0-mysql \
    php8.0-mbstring \
    php8.0-gd \
    php8.0-xml \
    php8.0-zip \
    php8.0-fpm \
    php8.0-intl \
    php8.0-apcu \
    yarn && \
# Clone the repo
    mkdir -p /var/www/koillection && \
    curl -o /tmp/koillection.tar.gz -L "https://github.com/koillection/koillection/archive/$GITHUB_RELEASE.tar.gz" && \
    tar xf /tmp/koillection.tar.gz -C /var/www/koillection --strip-components=1 && \
    rm -rf /tmp/* && \
    cd /var/www/koillection && \
    bin/composer install --classmap-authoritative && \
    bin/composer clearcache && \
# Build assets \
    cd ./assets && \
    yarn --version && \
    yarn install && \
    yarn build && \
    cd /var/www/koillection && \
# Clean up \
    rm -rf ./assets/node_modules && \
    apt-get purge -y $BUILD_DEPS && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/bin/composer && \
# Set permisions \
    chown -R www-data:www-data /var/www/koillection && \
    chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

# Add custom site to apache
COPY default.conf /etc/nginx/nginx.conf
COPY php.ini /etc/php/8.0/fpm/conf.d/php.ini

EXPOSE 80

VOLUME /conf /uploads

WORKDIR /var/www/koillection

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
