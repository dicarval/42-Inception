FROM alpine:3.21

RUN apk update && apk add redis

COPY ./tools/script.sh /

EXPOSE 6379

ENTRYPOINT ["/script.sh"]
