FROM alpine:edge

LABEL maintainer="Benjamin Jonard <jonard.benjamin@gmail.com>"

ENV UID=991 GID=991

COPY run.sh /usr/local/bin/run.sh
COPY s6.d /etc/s6.d

RUN BUILD_DEPS=" \
    tar \
    libressl \
    ca-certificates \
    build-base \
    autoconf \
    pcre-dev \
    libtool" \
    && apk update \
    && apk upgrade --update-cache --available \
    && apk add \
        ${BUILD_DEPS} \
        git \
        unzip \
        nginx \
        curl \
        php7 \
        php7-cgi \
        php7-dom \
        php7-xml \
        php7-xmlwriter \
        php7-curl \
        php7-mbstring \
        php7-fpm \
        php7-exif \
        php7-openssl \
        php7-gd \
        php7-phar \
        php7-json \
        php7-pdo \
        php7-pdo_pgsql \
        php7-zip \
        php7-session \
        php7-ctype \
        php7-apcu \
        php7-tokenizer \
        php7-opcache \
        php7-simplexml \
        php7-fileinfo \
        php7-sodium \
        php7-iconv \
        php7-intl \
        s6 \
        su-exec \
    && apk del ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/* /tmp/* \
    # Add composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --version \
    && mkdir -p /koillection \
    # Get Koillection latest release
    && last_tag=$(curl -sX GET "https://api.github.com/repos/koillection/koillection/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') \
    && curl -o /tmp/koillection.tar.gz -L "https://github.com/koillection/koillection/archive/${last_tag}.tar.gz" \
    && tar xf /tmp/koillection.tar.gz -C /koillection --strip-components=1 \
    && rm -rf /tmp/* \
    && cd /koillection \
    && touch .env \
    # Update composer
    && composer install -o --no-scripts --no-progress --no-suggest \
    && composer clear-cache \
    && chmod +x /usr/local/bin/run.sh /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /etc/php7/php-fpm.conf

WORKDIR "/koillection"

EXPOSE 8880

VOLUME ["/koillection/public/uploads"]

CMD ["run.sh"]
