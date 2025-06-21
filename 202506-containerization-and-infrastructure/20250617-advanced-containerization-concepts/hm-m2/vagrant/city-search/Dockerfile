ARG BASE_IMAGE_TAG=latest

FROM postgres:${BASE_IMAGE_TAG}

ENV PGHOST=bulgaria-db
ENV PGPORT=5432
ENV PGUSER=postgres
ENV PGPASSWORD=Password1
ENV PGDATABASE=bulgaria

COPY run-query.sh /run-query.sh
RUN chmod +x /run-query.sh

ENTRYPOINT ["/run-query.sh"]
CMD [""]