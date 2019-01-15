# PHP-FPM 7 Docker Container
# Base Dockerfile: composer/base
FROM php:7.2-fpm
MAINTAINER Nicolas Dhers <n.dhers.pro@gmail.com>

# User conf
ENV RUN_UID=8181
ENV RUN_GID=8181

# Packages
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bash \
    sudo \
    locales \
    gettext \
    zlib1g-dev libicu-dev g++ \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libbz2-dev \
    libxslt-dev \
    libldap2-dev \
    curl \
    git \
    unzip \
    wget \
    nano \
    mysql-client \
    build-essential \
    dos2unix \
    ntp \
  && rm -r /var/lib/apt/lists/*

# Language config

# RUN sed -i -e 's/# fr_FR ISO-8859-1/fr_FR ISO-8859-1/' /etc/locale.gen && \
   # dpkg-reconfigure --frontend=noninteractive locales

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen 
RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales


ENV LANG fr_FR.UTF-8  
ENV LANGUAGE fr_FR:en  
ENV LC_ALL fr_FR.UTF-8 


# Time config

# Conf settings
ENV PHP_CONF_FILE=/etc/php/7.2/fpm/conf.d/20-system.ini \
    PHP_CONF_FILE_CLI=/etc/php/7.2/cli/conf.d/20-system.ini \
    PHP_CONF_TIMEZONE=UTC \
    PHP_CONF_MAX_EXECUTION_TIME=30 \
    PHP_CONF_UPLOAD_LIMIT=40M \
    PHP_CONF_PHAR_READONLY=off \
    PHP_CONF_MEMORY_LIMIT=512M \
    PHP_CONF_DISPLAY_ERRORS=off \
    PHP_CONF_ERROR_REPORTING=0 \
    PHP_CONF_OPCACHE_ENABLE=0 \
    PHP_CONF_OPCACHE_ENABLE_CLI=0 \
    PHP_CONF_OPCACHE_MEMORY_CONSUMPTION=128 \
    PHP_CONF_OPCACHE_INTERNED_STRINGS_BUFFER=8 \
    PHP_CONF_OPCACHE_MAX_ACCELERATED_FILES=4000 \
    PHP_CONF_OPCACHE_MAX_WASTED_PERCENTAGE=20 \
    PHP_CONF_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_CONF_OPCACHE_REVALIDATE_FREQ=60 \
    PHP_CONF_OPCACHE_FAST_SHUTDOWN=0

# Pool settings
ENV PHP_POOL_FILE=/etc/php/7.2/fpm/pool.d/20-system.pool.conf \
    PHP_POOL_USER=www-data \
    PHP_POOL_GROUP=www-data \
    PHP_POOL_LISTEN_HOST=127.0.0.1 \
    PHP_POOL_LISTEN_PORT=9000 \
    PHP_POOL_PM_CONTROL=dynamic \
    PHP_POOL_PM_MAX_CHILDREN=20 \
    PHP_POOL_PM_START_SERVERS=2 \
    PHP_POOL_PM_MIN_SPARE_SERVERS=1 \
    PHP_POOL_PM_MAX_SPARE_SERVERS=3 \
    PHP_CONF_OPCACHE_ENABLE=0

# RUN ntpd -gq \
#   && service ntp start &&\
#   echo "$TIMEZONE" > /etc/timezone &&\
#   ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime &&\
#   dpkg-reconfigure -f noninteractive tzdata

# # Time Zone
# RUN echo "date.timezone=$TIMEZONE" > $PHP_INI_DIR/conf.d/10-date_timezone.ini

# PHP

# PHP Extensions

RUN pecl install redis
RUN pecl install mcrypt-1.0.1

RUN docker-php-ext-install bcmath zip bz2 mbstring xsl gettext \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install pdo pdo_mysql mysqli \
  && docker-php-ext-enable redis \
  && docker-php-ext-enable mcrypt \
  && docker-php-ext-enable gettext \
  && docker-php-ext-configure opcache --enable-opcache \
  && docker-php-ext-install opcache
# RUN echo extension=gettext.so > /usr/local/etc/php/conf.d/gettext.ini

RUN echo "PHP $PHP_VERSION configured, with extensions and special conf files" &&\
    ls -l $PHP_INI_DIR/conf.d



# Composer

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer
# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH
# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1
# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"
ENV COMPOSER_VERSION master
# Install Composer
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php
# Setup the Composer installer and extensions
RUN composer global require 'phing/phing=2.*' &&\
    composer global require 'phpunit/phpunit=*' &&\
    composer global require 'theseer/phpdox=@stable'



# WP-cli

RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY scripts/wp-su.sh /bin/wp
# RUN ln -s /bin/wp-cli.phar /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp && \
    dos2unix /bin/wp


# NPM / Yarn
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
  && rm -r /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs yarn \
  && rm -r /var/lib/apt/lists/*
RUN npm install -g gulp bower


# Mailcatcher
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ruby-full \
    libsqlite3-dev \
  && rm -r /var/lib/apt/lists/*
RUN gem install mailcatcher --no-rdoc --no-ri


# Drush install
# Install Drush 8 with the phar file.
# Set the Drush version.
ENV DRUSH_VERSION 8.1.16
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush
RUN drush core-status



# new entrypoint (config with env vars)

COPY scripts/docker-php-entrypoint-new /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint-new && \
    dos2unix /usr/local/bin/docker-php-entrypoint-new

COPY scripts/php-init /usr/local/bin/
RUN chmod +x /usr/local/bin/php-init && \
    dos2unix /usr/local/bin/php-init

# runtime configs

ADD conf/00-custom.conf /usr/local/etc/php/php-custom.conf

COPY commands/setup-* /root/
RUN chmod +x /root/setup-cli-conf.sh && \
    chmod +x /root/setup-fpm-conf.sh && \
    chmod +x /root/setup-fpm-pool.sh && \
    dos2unix /root/setup-cli-conf.sh && \
    dos2unix /root/setup-fpm-conf.sh && \
    dos2unix /root/setup-fpm-pool.sh

# ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint-new"]
CMD ["php-init"]

WORKDIR /var/www