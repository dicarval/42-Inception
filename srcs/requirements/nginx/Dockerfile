FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends nginx openssl

RUN mkdir -p /var/www/html && chmod 755 /var/www/html &&\
	chown -R www-data:www-data /var/www/html

COPY ./conf/nginx_server.conf /
COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
