FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends php8.2-fpm php8.2-mysql php8.2-redis
RUN apt-get install -y --no-install-recommends curl ca-certificates netcat-openbsd
RUN apt-get install -y --no-install-recommends redis-tools

COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
