
FROM phusion/baseimage:latest
MAINTAINER gabriel schubiner <gabriel.schubiner@gmail.com>

# Installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    git \
    unzip \
    memcached \
    php5 \
    php5-mysqlnd \
    php5-pgsql \
    php5-imap \
    php5-cli \
    php-pear \
    php-apc \
    php5-gd \
    php5-memcached \
    python-pip 
 

# Networking
#RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
#    && echo "NETWORKING=yes" > /etc/sysconfig/network

# SSH
#RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key \
#    && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key \
#    && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 

#RUN sed -i \
#    -e 's/^#UseDNS yes/UseDNS no/g' \
#    -e 's/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g' \
#    /etc/ssh/sshd_config

# -e 's/^#UsePAM no/UsePAM no/g' \
# -e 's/^UsePAM yes/#UsePAM yes/g' \
# -e 's/^PasswordAuthentication yes/PasswordAuthentication no/g' \

### Set Root Pass
#ADD ./assets/scripts/set_root_pass.sh /opt/set_root_pass.sh

#RUN chmod +x /opt/set_root_pass.sh

### SUDO
#RUN sed -i 's/^# %wheel\tALL=(ALL)\tALL/%wheel\tALL=(ALL)\tALL/g' /etc/sudoers

# PHP Config
RUN sed -i \
    -e 's/^memory_limit.*$/memory_limit = 1024M/g' \
    -e 's/^max_execution_time.*$/max_execution_time = 900/g' \
    -e 's/^session.save_handler.*$/session.save_handler = memcache/g' \
    -e 's/^post_max_size.*$/post_max_size = 512M/g' \
    -e 's/^upload_max_file_size.*$/upload_max_file_size = 512M/g' \
    -e 's/^max_file_uploads.*$/max_file_uploads = 100/g' \
    /etc/php5/apache2/php.ini

RUN pear channel-discover pear.drush.org && \
    pear install drush/drush

# Pushtape

RUN rm /var/www/html/* && \
    curl http://ftp.drupal.org/files/projects/pushtape-7.x-1.0-beta18.tar.gz | tar xz -C /var/www/html --strip-components=1 

RUN cd /var/www/html && \
    drush make build-pushtape.make ./ && \
    cd /

#RUN chown -R root:apache /var/www/html/*
#RUN chown -R apache:apache /var/www/html/sites/default
#RUN chown -R apache:apache /var/www/html/sites/all

EXPOSE 22 80 443

# Supervisor
#ADD ./assets/supervisor/supervisord.conf /etc/supervisord.conf
#ADD ./assets/crontab /etc/crontab
#ADD ./assets/scripts/entrypoint.sh /entrypoint.sh

#RUN chmod +x /entrypoint.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/sbin/my_init"]
