FROM debian:buster-slim

# Set version label
LABEL maintainer="Benjamin Jonard <jonard.benjamin@gmail.com>"

# Environment variables
ENV PHP_TZ=Europe/Paris
ENV HTTPS_ENABLED=1

ENV BUILD_DEPS="ca-certificates apt-transport-https lsb-release wget curl git"
ENV TOOL_DEPS="nginx-light"

COPY entrypoint.sh inject.sh /

RUN \
# Install php 8.1 and other dependencies
    apt-get update && \
    apt-get install -y $BUILD_DEPS && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y \
    chromium-chromedriver \
    firefox-geckodriver \
    php8.1 \
    php8.1-curl \
    php8.1-pgsql \
    php8.1-mysql \
    php8.1-mbstring \
    php8.1-gd \
    php8.1-xml \
    php8.1-zip \
    php8.1-fpm \
    php8.1-intl \
    php8.1-apcu \
    php8.1-xdebug \
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
COPY php.ini /etc/php/8.1/fpm/conf.d/php.ini
RUN echo "session.cookie_secure=$HTTPS_ENABLED" >> /etc/php/8.1/fpm/conf.d/php.ini

EXPOSE 80
VOLUME /var/www/koillection/public/uploads
WORKDIR /var/www/koillection

RUN usermod -u 1000 www-data

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
