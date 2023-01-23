FROM debian:11-slim

COPY --from=caddy:2 /usr/bin/caddy /usr/local/bin/
COPY Caddyfile /etc/caddy/Caddyfile


# Set version label
LABEL maintainer="Benjamin Jonard"

ARG GITHUB_RELEASE

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='koillection'
ENV PHP_TZ=Europe/Paris
ENV APP_ENV=prod
ENV APP_DEBUG=0
ENV HTTPS_ENABLED=$HTTPS_ENABLED

ENV BUILD_DEPS=""

COPY entrypoint.sh inject.sh /

RUN \
# Add User and Group
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER" && \
# Install dependencies
    apt-get update && \
    apt-get install -y $BUILD_DEPS curl wget lsb-release  && \
# PHP
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
# Nodejs
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
# Yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y \
    ca-certificates \
    apt-transport-https \
    gnupg2 \
    git \
    unzip \
    openssl \
    php8.2 \
    php8.2-pgsql \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-gd \
    php8.2-xml \
    php8.2-zip \
    php8.2-fpm \
    php8.2-intl \
    php8.2-apcu \
    nodejs \
    yarn && \
# Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
# Clone the repo
    mkdir -p /srv/koillection && \
    curl -o /tmp/koillection.tar.gz -L "https://github.com/koillection/koillection/archive/$GITHUB_RELEASE.tar.gz" && \
    tar xf /tmp/koillection.tar.gz -C /srv/koillection --strip-components=1 && \
    rm -rf /tmp/* && \
    cd /srv/koillection && \
    composer install --no-dev --classmap-authoritative && \
    composer clearcache && \
# Dump translation files for javascript \
    php bin/console bazinga:js-translation:dump assets/js --format=js && \
# Build assets \
    cd ./assets && \
    yarn --version && \
    yarn install && \
    yarn build && \
    cd /srv/koillection && \
# Clean up \
    yarn cache clean && \
    rm -rf ./assets/node_modules && \
    apt-get purge -y wget lsb-release git nodejs yarn apt-transport-https ca-certificates gnupg2 unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/bin/composer && \
# Set permisions \
    chown -R "$USER":"$USER" /srv/koillection && \
    chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

COPY php.ini /etc/php/8.2/fpm/conf.d/php.ini

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

VOLUME /conf /uploads

WORKDIR /srv/koillection

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
