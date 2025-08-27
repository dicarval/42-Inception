FROM alpine:3.21

RUN apk update && \
	apk add mariadb mariadb-client

COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
