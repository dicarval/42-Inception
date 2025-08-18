FROM alpine:3.21

RUN apk update
RUN apk add php php-fpm php-mysqli php-mysqlnd php-phar php-iconv php-mbstring curl netcat-openbsd && \
	if command -v php-fpm83 >/dev/null 2>&1; then \
	  ln -sf "$(command -v php-fpm83)" /usr/sbin/php-fpm || true; \
	fi

COPY ./tools/script.sh /
COPY ./conf/php.conf /etc/php/php-fpm.d/www.conf

EXPOSE 9000

ENTRYPOINT ["/script.sh"]
