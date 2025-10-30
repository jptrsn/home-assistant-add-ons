#!/usr/bin/bash

postgres_data="/data/postgres"
uploads_dir="/data/uploads"

echo "[init-db] Initializing TRMNL Terminus..."

# Create directories if they don't exist
mkdir -p "${postgres_data}" "${uploads_dir}"

# Create postgres user if it doesn't exist
if ! id -u postgres >/dev/null 2>&1; then
    echo "[init-db] Creating postgres user..."
    groupadd -r postgres && useradd -r -g postgres -d /var/lib/postgresql postgres
fi

# Set ownership and permissions
chown -R postgres:postgres "${postgres_data}"
chmod 700 "${postgres_data}"

# Generate APP_SECRET if it doesn't exist
if [ ! -f "/data/app_secret" ]; then
    echo "[init-db] Generating APP_SECRET..."
    pwgen -s 64 1 > /data/app_secret
fi

# Generate PostgreSQL password if it doesn't exist
if [ ! -f "/data/pg_password" ]; then
    echo "[init-db] Generating PostgreSQL password..."
    pwgen -s 32 1 > /data/pg_password
fi

# Initialize PostgreSQL data directory if needed
if [ ! -d "${postgres_data}/base" ]; then
    echo "[init-db] Initializing PostgreSQL database..."
    su - postgres -c "/usr/lib/postgresql/18/bin/initdb -D ${postgres_data}"

    # Configure PostgreSQL
    echo "host all all 127.0.0.1/32 md5" >> "${postgres_data}/pg_hba.conf"
    echo "listen_addresses = 'localhost'" >> "${postgres_data}/postgresql.conf"
    echo "port = 5432" >> "${postgres_data}/postgresql.conf"
fi

echo "[init-db] Initialization complete!"