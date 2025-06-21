#!/bin/bash

CITY_PATTERN="$1"

echo "Waiting for PostgreSQL at $PGHOST:$PGPORT..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  sleep 1
done

echo "PostgreSQL is ready."

if [ -z "$CITY_PATTERN" ]; then
  echo "No city pattern provided. Listing all cities..."
  psql -d "$PGDATABASE" <<-EOSQL
SELECT * FROM cities;
EOSQL
else
  echo "Searching for cities matching pattern: $CITY_PATTERN"
  psql -d "$PGDATABASE" -v pattern="'%$CITY_PATTERN%'" <<-EOSQL
SELECT * FROM cities WHERE city_name ILIKE :pattern;
EOSQL
fi
