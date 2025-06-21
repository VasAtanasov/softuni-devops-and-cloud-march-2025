ARG BASE_IMAGE_TAG=latest
FROM postgres:${BASE_IMAGE_TAG}
COPY scripts /scripts

RUN chmod a+rx /scripts/postgres/*.sh

COPY scripts/postgres/create-database.sh /docker-entrypoint-initdb.d/create-database.sh