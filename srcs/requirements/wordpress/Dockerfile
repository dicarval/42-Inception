FROM alpine:3.21

RUN apk update
RUN apk add php php-fpm83 php-mysqli php-mysqlnd php-phar curl netcat-openbsd

COPY ./tools/script.sh /
COPY ./conf/php.conf /etc/php83/fpm/php-fpm.d/www.conf
COPY ./conf/php.ini /etc/php83/

EXPOSE 9000

ENTRYPOINT ["/script.sh"]
