# Dockerfile

# Base Stage: Build the MediaWiki container
FROM mediawiki:latest as base

# Copy extensions or additional configurations if needed
# COPY ./extensions /var/www/html/extensions
# COPY ./LocalSettings.php /var/www/html/LocalSettings.php

# Base image for MediaWiki
FROM php:8.1-apache

# Update package manager and install dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install necessary dependencies and MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    libmariadb-dev \
    && docker-php-ext-install mysqli

# Set up MediaWiki
RUN curl -L https://releases.wikimedia.org/mediawiki/1.39/mediawiki-1.39.3.tar.gz | tar -xz -C /var/www/html --strip-components=1

# Set permissions for MediaWiki
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Define environment variables
ENV MEDIAWIKI_DB_HOST=localhost \
    MEDIAWIKI_DB_USER=wikiuser \
    MEDIAWIKI_DB_PASSWORD=examplepass \
    MEDIAWIKI_DB_NAME=wikidb \
    MYSQL_ROOT_PASSWORD=rootpass

# Start MariaDB and Apache services
CMD service mariadb start && \
    mariadb -uroot -e "CREATE DATABASE IF NOT EXISTS ${MEDIAWIKI_DB_NAME}; GRANT ALL PRIVILEGES ON ${MEDIAWIKI_DB_NAME}.* TO '${MEDIAWIKI_DB_USER}'@'localhost' IDENTIFIED BY '${MEDIAWIKI_DB_PASSWORD}';" && \
    apache2-foreground

# Final Stage: Add LocalSettings.php
FROM base as final

# Copy LocalSettings.php into the MediaWiki root
COPY config/LocalSettings.php /var/www/html/LocalSettings.php

# restart Apache services
#CMD apache2-foreground
