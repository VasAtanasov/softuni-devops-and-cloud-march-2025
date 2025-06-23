FROM almalinux:9

LABEL version="1.0" \
      description="A sample web application that displays It Works"

RUN dnf -y update && \
    dnf -y install httpd && \
    dnf clean all

COPY index.html /var/www/html/index.html

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]