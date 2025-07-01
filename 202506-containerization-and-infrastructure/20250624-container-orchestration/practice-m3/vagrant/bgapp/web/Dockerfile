FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    zip \
    unzip \
    supervisor \
    && docker-php-ext-install mysqli pdo pdo_mysql

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

RUN chown -R appuser.appgroup /var/www/html /run /var/lib/nginx /var/log/nginx

COPY . /var/www/html/

RUN chown -R appuser:appgroup /var/www/html

COPY default.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisord.conf

WORKDIR /var/www/html

USER appuser

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
