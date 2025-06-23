FROM almalinux:9.6-minimal

RUN microdnf -y update && \
    microdnf -y install httpd-2.4.62-4.el9 && \
    microdnf clean all

COPY index.html /var/www/html/index.html

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]