FROM alpine:3.21

RUN apk update && \
	apk add mariadb-server

COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
