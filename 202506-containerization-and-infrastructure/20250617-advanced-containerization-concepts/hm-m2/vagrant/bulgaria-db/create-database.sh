#!/usr/bin/env bash

set -euo pipefail

PSQL="psql -v ON_ERROR_STOP=1"

echo "  Creating user and database '$POSTGRES_DB'"

$PSQL --username "$POSTGRES_USER" <<-EOSQL
    DO
    \$\$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_DB}'
        ) THEN
            CREATE USER "${POSTGRES_DB}";
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}'
        ) THEN
            CREATE DATABASE "${POSTGRES_DB}" OWNER "${POSTGRES_DB}";
            GRANT ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" TO "${POSTGRES_DB}";
        END IF;
    END
    \$\$;
EOSQL

echo "  Populating database '$POSTGRES_DB' with embedded SQL..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    city_name VARCHAR(50),
    population INT
);

INSERT INTO cities (city_name, population) VALUES ('София', 1248452);
INSERT INTO cities (city_name, population) VALUES ('Пловдив', 343070);
INSERT INTO cities (city_name, population) VALUES ('Варна', 332686);
INSERT INTO cities (city_name, population) VALUES ('Бургас', 199571);
INSERT INTO cities (city_name, population) VALUES ('Русе', 137533);
INSERT INTO cities (city_name, population) VALUES ('Стара Загора', 124599);
INSERT INTO cities (city_name, population) VALUES ('Плевен', 93214);
INSERT INTO cities (city_name, population) VALUES ('Сливен', 83740);
INSERT INTO cities (city_name, population) VALUES ('Добрич', 79269);
INSERT INTO cities (city_name, population) VALUES ('Шумен', 72342);
EOSQL

echo "  Database '$POSTGRES_DB' populated successfully."