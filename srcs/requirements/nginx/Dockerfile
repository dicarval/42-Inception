FROM alpine:3.21

RUN apk update && \
	apk add nginx openssl

COPY ./conf/nginx_server.conf /
COPY ./tools/script.sh /

RUN chmod +x /script.sh

ENTRYPOINT ["/script.sh"]
