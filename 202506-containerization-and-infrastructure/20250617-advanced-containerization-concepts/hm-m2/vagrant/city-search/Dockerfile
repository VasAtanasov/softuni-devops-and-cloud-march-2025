FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PGHOST=bulgaria-db
ENV PGPORT=5432
ENV PGUSER=postgres
ENV PGPASSWORD=Password1
ENV PGDATABASE=bulgaria

COPY run-query.sh /run-query.sh
RUN chmod +x /run-query.sh

ENTRYPOINT ["/run-query.sh"]
CMD [""]