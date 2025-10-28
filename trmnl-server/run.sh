#!/usr/bin/with-contenv bashio

bashio::log.info "Starting TRMNL Server..."

# Get configuration
REFRESH_INTERVAL=$(bashio::config 'refresh_interval')

# Set Laravel environment variables
export APP_ENV=production
export APP_DEBUG=false
export APP_KEY=$(php /var/www/html/artisan key:generate --show)
export DB_CONNECTION=sqlite
export DB_DATABASE=/data/database/database.sqlite
export STORAGE_PATH=/data/storage
export TRMNL_PROXY_REFRESH_MINUTES=$((REFRESH_INTERVAL / 60))
export REGISTRATION_ENABLED=1
export PHP_OPCACHE_ENABLE=1

# Create database if it doesn't exist
if [ ! -f "$DB_DATABASE" ]; then
    bashio::log.info "Creating database..."
    mkdir -p /data/database
    touch "$DB_DATABASE"
    cd /var/www/html
    php artisan migrate --force
fi

# Link storage
cd /var/www/html
php artisan storage:link

# Start PHP-FPM
php-fpm84 -D

# Start queue worker in background
php artisan queue:work --daemon &

bashio::log.info "TRMNL Server started on port 8080"

# Start nginx in foreground
exec nginx -g 'daemon off;'