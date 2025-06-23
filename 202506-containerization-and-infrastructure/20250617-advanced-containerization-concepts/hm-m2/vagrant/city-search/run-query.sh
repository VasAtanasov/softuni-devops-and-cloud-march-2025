#!/bin/bash

CITY_PATTERN="$1"

until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" > /dev/null 2>&1; do
  sleep 1
done

PSQL="psql -U $PGUSER -d $PGDATABASE -t -A -q"

if [ -z "$CITY_PATTERN" ]; then
  $PSQL -c "SELECT json_agg(cities) FROM cities;" | jq .
else
  $PSQL -c "SELECT json_agg(cities) FROM cities WHERE city_name ILIKE '%$CITY_PATTERN%';" | jq .
fi
