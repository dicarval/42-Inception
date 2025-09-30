FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends nginx

COPY ./website /usr/share/nginx/html
COPY ./conf/parallax_server.conf /
COPY ./tools/script.sh /

RUN chmod 755 /usr/share/nginx/html &&\
 chown -R www-data:www-data /usr/share/nginx/html


ENTRYPOINT ["/script.sh"]
