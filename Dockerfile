# Use the official Rocky Linux 8 base image
FROM rockylinux:8

# Install the Apache HTTP server package
RUN yum install -y httpd

# Copy the index.html file into the Apache document root
COPY index.html /var/www/html/

# Start Apache in the foreground
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

# Expose port 80
EXPOSE 80