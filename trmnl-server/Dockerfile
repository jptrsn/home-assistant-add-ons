ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install dependencies
RUN apk add --no-cache \
    php84 \
    php84-fpm \
    php84-opcache \
    php84-pdo \
    php84-pdo_sqlite \
    php84-session \
    php84-tokenizer \
    php84-xml \
    php84-ctype \
    php84-fileinfo \
    php84-mbstring \
    php84-openssl \
    php84-curl \
    php84-zip \
    php84-gd \
    php84-dom \
    php84-xmlreader \
    php84-xmlwriter \
    php84-simplexml \
    php84-pecl-imagick \
    imagemagick \
    composer \
    nginx \
    nodejs \
    npm \
    git \
    chromium \
    chromium-chromedriver

# Clone the BYOS Laravel repository
WORKDIR /var/www/html
RUN git clone --depth 1 https://github.com/usetrmnl/byos_laravel.git .

# Copy environment file and set defaults
RUN cp .env.example .env

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Install node dependencies and build assets
RUN npm ci --no-audit && npm run build

# Setup directories and permissions
RUN mkdir -p /data/database /data/storage \
    && chown -R nginx:nginx /var/www/html \
    && chown -R nginx:nginx /data

# Copy nginx config
COPY rootfs/ /

# Expose port
EXPOSE 8080

CMD ["/run.sh"]