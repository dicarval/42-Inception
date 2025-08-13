FROM alpine:3.21

RUN apk update && \
	apk add nginx openssl

RUN mkdir -p /var/www/html && chmod 755 /var/www/html &&\
	chown -R nginx:nginx /var/www/html

COPY ./conf/nginx_server.conf /
COPY ./tools/script.sh /

EXPOSE 443

ENTRYPOINT ["/script.sh"]
