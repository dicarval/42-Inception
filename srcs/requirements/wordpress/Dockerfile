FROM alpine:3.21

RUN apk update
RUN apk add php php-fpm php-mysqli php-mysqlnd php-phar php-iconv php-mbstring curl netcat-openbsd

COPY ./tools/script.sh /
COPY ./conf/php.conf /etc/php/php-fpm.d/www.conf
COPY ./conf/php.ini /etc/php/php.ini

EXPOSE 9000

ENTRYPOINT ["/script.sh"]
