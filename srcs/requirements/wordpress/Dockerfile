FROM alpine:3.21

RUN apk update
RUN apk add php8 php8-fpm php8-mysqli php8-mysqlnd php8-phar php8-iconv php8-mbstring curl netcat-openbsd

COPY ./tools/script.sh /
COPY ./conf/php.conf /etc/php8/php-fpm.d/www.conf
COPY ./conf/php.ini /etc/php8/php.ini

EXPOSE 9000

ENTRYPOINT ["/script.sh"]
