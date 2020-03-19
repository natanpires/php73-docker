FROM php:7.3-fpm-buster

RUN \
  apt-get update && \
  apt-get install -y \
  curl \
  wget \
  apt-transport-https \
  lsb-release \
  ca-certificates \
  gnupg2 \
  git

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget apt-transport-https ca-certificates libpcre3-dev gnupg

# NewRelic
RUN curl https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list

# PHP DEB.SURY.CZ ##########################################################
RUN wget -O- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
# Add Sury PHP repository

RUN rm /etc/apt/preferences.d/no-debian-php

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -y apt-transport-https \
        php7.3-mysql \
        php7.3-gd \
        php7.3-imagick \
        php7.3-dev \
        php7.3-curl \
        php7.3-opcache \
        php7.3-cli \
        php7.3-sqlite \
        php7.3-intl \
        php7.3-tidy \
        php7.3-imap \
        php7.3-json \
        php7.3-pspell \
        php7.3-common \
        php7.3-sybase \
        php7.3-sqlite3 \
        php7.3-bz2 \
        php7.3-common \
        php7.3-apcu-bc \
        php7.3-memcached \
        php7.3-redis \
        php7.3-xml \
        php7.3-shmop \
        php7.3-mbstring \
        php7.3-zip \
        php7.3-bcmath \
        php7.3-soap \
        zlibc \
        zlib1g \
        zlib1g-dev \
        newrelic-php5 \
        nginx \
        libmemcached-dev \
        libzip-dev

RUN cd ~ && \
    git clone https://github.com/php-memcached-dev/php-memcached.git && \
    cd php-memcached && \     
    phpize && \
    ./configure --disable-memcached-sasl && \
    make && \
    make install && \
    cd ~ && \
    rm -rf ~/php-memcached

COPY newrelic-boot-setup.sh /usr/local/sbin/newrelic-boot-setup.sh
RUN chmod +x /usr/local/sbin/newrelic-boot-setup.sh

RUN docker-php-ext-configure mbstring
RUN docker-php-ext-install mbstring zip
RUN docker-php-ext-install pdo pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && composer global require --prefer-dist "fxp/composer-asset-plugin:~1.0"