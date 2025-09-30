FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN	apt-get install -y --no-install-recommends mariadb-server mariadb-client

COPY ./tools/script.sh /

ENTRYPOINT ["/script.sh"]
