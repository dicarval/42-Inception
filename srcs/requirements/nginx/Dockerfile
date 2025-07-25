FROM alpine:3.21

RUN apk update && \
	apk add nginx openssl


	COPY conf/nginx.conf /etc/nginx/nginx.conf
	COPY ./tools/nginx_script.sh /
