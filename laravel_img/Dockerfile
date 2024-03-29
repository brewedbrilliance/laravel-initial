FROM php:8.2-apache
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN apt-get -y update \
&& apt-get install -y libicu-dev zip unzip git \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl mysqli pdo pdo_mysql