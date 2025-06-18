# Use AlmaLinux as the base image
FROM almalinux:9.6-minimal

# Install Apache using microdnf
RUN microdnf install -y httpd-2.4.62-4.el9 && \
    microdnf clean all

# Copy the local index.html into the Apache web root
COPY index.html /var/www/html/index.html

# Expose Apache's default port
EXPOSE 80

# Start Apache in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]