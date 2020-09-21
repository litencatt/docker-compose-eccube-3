FROM centos:7

RUN yum update -y
RUN yum install -y sudo
RUN yum install -y epel-release
RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum clean all
RUN yum -y install wget
RUN yum -y install httpd
RUN yum -y install --enablerepo=remi,remi-php56 php php-devel php-mbstring php-pdo php-gd php-xml php-mcrypt php-mysqli

#Install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN wget https://github.com/EC-CUBE/ec-cube3/archive/3.0.18-p1.tar.gz
RUN tar zxvf 3.0.18-p1.tar.gz

RUN mv ec-cube3-3.0.18-p1 /var/www/html/ec-cube \
    && chown -R apache:apache /var/www/html/ec-cube

RUN cd /var/www/html/ec-cube && composer install

RUN sed -i -e 's#DocumentRoot "/var/www/html"#DocumentRoot "/var/www/html/ec-cube/html"#g' -e 's#<Directory "/var/www/html">#<Directory /var/www/html/ec-cube/html">#g' -e 's#Options Indexes FollowSymLinks#Options -Indexes +FollowSymLinks#g' -e 's#AllowOverride None#AllowOverride All#g' /etc/httpd/conf/httpd.conf

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
EXPOSE 80
