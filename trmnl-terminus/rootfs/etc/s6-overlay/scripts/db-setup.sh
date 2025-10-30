#!/usr/bin/bash

pg_password=$(cat /data/pg_password)
pg_user="terminus"
pg_database="terminus"

echo "[db-setup] Waiting for PostgreSQL to be ready..."

# Wait for PostgreSQL to accept connections
for i in {1..30}; do
    if su - postgres -c "psql -lqt" &>/dev/null; then
        echo "[db-setup] PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "[db-setup] PostgreSQL failed to start in time!"
        exit 1
    fi
    sleep 1
done

# Create database if it doesn't exist
if ! su - postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname = '${pg_database}'\"" | grep -q 1; then
    echo "[db-setup] Creating database ${pg_database}..."
    su - postgres -c "createdb ${pg_database}"
fi

# Create user if it doesn't exist
if ! su - postgres -c "psql -tc \"SELECT 1 FROM pg_roles WHERE rolname = '${pg_user}'\"" | grep -q 1; then
    echo "[db-setup] Creating user ${pg_user}..."
    su - postgres -c "psql -c \"CREATE USER ${pg_user} WITH PASSWORD '${pg_password}'\""
fi

# Grant privileges
echo "[db-setup] Granting privileges..."
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${pg_database} TO ${pg_user}\""
su - postgres -c "psql -d ${pg_database} -c \"GRANT ALL ON SCHEMA public TO ${pg_user}\""

echo "[db-setup] Database setup complete!"