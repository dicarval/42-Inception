FROM alpine:3.21

RUN apk update && apk add vsftpd

COPY ./tools/script.sh /

EXPOSE 21

ENTRYPOINT ["/script.sh"]
