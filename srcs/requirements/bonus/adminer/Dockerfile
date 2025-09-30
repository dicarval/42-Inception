FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends php8.2-cli php8.2-mysql curl ca-certificates

COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
