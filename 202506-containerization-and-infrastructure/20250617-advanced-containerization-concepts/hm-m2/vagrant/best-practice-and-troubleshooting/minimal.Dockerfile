FROM almalinux:9.6-minimal

RUN microdnf -y update && \
    microdnf -y install httpd && \
    microdnf clean all

COPY index.html /var/www/html/index.html

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]