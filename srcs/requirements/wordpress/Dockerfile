FROM alpine:3.21

RUN apk update
RUN apk add php php-fpm php-mysqli php-mysqlnd php-phar php-iconv php-mbstring curl netcat-openbsd

COPY ./tools/script.sh /

EXPOSE 9000

ENTRYPOINT ["/script.sh"]
