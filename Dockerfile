FROM dunglas/frankenphp

ARG GITHUB_RELEASE

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='koillection'
ENV PHP_TZ=Europe/Paris
ENV APP_ENV=prod
ENV APP_DEBUG=0
ENV HTTPS_ENABLED=$HTTPS_ENABLED

COPY entrypoint.sh inject.sh /

RUN \
# Add User and Group
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER" && \
# Install dependencies
    apt-get update && \
    apt-get install -y curl wget lsb-release  && \
# Nodejs
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
# Yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y \
      ca-certificates \
      apt-transport-https \
      gnupg2 \
      git \
      openssl \
      nodejs \
      yarn && \
    install-php-extensions pdo_pgsql && \
    install-php-extensions pdo_mysql && \
    install-php-extensions intl && \
    install-php-extensions gd && \
    install-php-extensions zip && \
# Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
# Clone the repo
    mkdir -p /app && \
    curl -o /tmp/koillection.tar.gz -L "https://github.com/koillection/koillection/archive/$GITHUB_RELEASE.tar.gz" && \
    tar xf /tmp/koillection.tar.gz -C /app --strip-components=1 && \
    rm -rf /tmp/* && \
    cd /app && \
    composer install --no-dev --classmap-authoritative && \
    composer clearcache && \
# Dump translation files for javascript \
    php bin/console bazinga:js-translation:dump assets/js --format=js && \
# Build assets \
    cd ./assets && \
    yarn --version && \
    yarn install && \
    yarn build && \
    cd /app && \
# Clean up \
    yarn cache clean && \
    rm -rf ./assets/node_modules && \
    apt-get purge -y wget lsb-release git nodejs yarn apt-transport-https ca-certificates gnupg2 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/bin/composer && \
# Set permisions \
    chown -R "$USER":"$USER" /app && \
    chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

# Add custom site to apache
COPY php.ini /etc/php/8.2/fpm/conf.d/php.ini
COPY Caddyfile /etc/Caddyfile

VOLUME /conf /uploads

WORKDIR /app

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]