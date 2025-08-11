FROM alpine:3.21

RUN apk update && \
	apk add nginx openssl

RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY ./conf/nginx_server.conf /
COPY ./tools/script.sh /

RUN chmod -R +x /script.sh

EXPOSE 443

ENTRYPOINT ["/script.sh"]
