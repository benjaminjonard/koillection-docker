FROM debian:buster-slim

# Set version label
LABEL maintainer="Benjamin Jonard <jonard.benjamin@gmail.com>"

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='koillection'
ENV PHP_TZ=Europe/Paris

# Add User and Group
RUN \
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER"

# Install base dependencies, clone the repo and install php libraries
RUN \
    apt-get update && \
    apt-get install -y \
    nginx-light \
    php7.3-pgsql \
    php7.3-mbstring \
    php7.3-json \
    php7.3-gd \
    php7.3-xml \
    php7.3-zip \
    php7.3-fpm \
    php7.3-intl \
    php7.3-apcu \
    curl \
    libimage-exiftool-perl \
    ffmpeg \
    git \
    composer && \
    mkdir -p /var/www/koillection && \
    curl -o /tmp/koillection.tar.gz -L "https://github.com/koillection/koillection/archive/v1.1.tar.gz" && \
    tar xf /tmp/koillection.tar.gz -C /var/www/koillection --strip-components=1 && \
    rm -rf /tmp/* && \
    cd /var/www/koillection && \
    apt-get install -y composer && \
    composer install --no-scripts && \
    chown -R www-data:www-data /var/www/koillection && \
    apt-get purge -y git && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add custom site to apache
COPY default.conf /etc/nginx/nginx.conf
COPY php.ini /usr/local/etc/php/php.ini

EXPOSE 80
VOLUME /conf /uploads

WORKDIR /var/www/koillection

COPY entrypoint.sh inject.sh /

RUN chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
