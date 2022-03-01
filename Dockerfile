# FROM alpine:3.12

# RUN apk update
# RUN apk add tini

# ADD ./hello-world/target/armv7-unknown-linux-musleabihf/release/hello-world /usr/local/bin/hello-world
# ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
# RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# WORKDIR /root

# EXPOSE 80


ARG VERSION=v0.9.5

# FROM rust:1.48.0-slim AS builder
FROM rust:alpine-3.15 AS builder

ARG VERSION

WORKDIR /build

# RUN apt-get update
# RUN apt-get install -y git clang cmake libsnappy-dev

RUN apk update
RUN apk add -y git clang cmake libsnappy-dev

# RUN git clone --branch $VERSION https://github.com/romanz/electrs .

COPY ./electrs ./electrs

RUN cargo install --locked --path .

# FROM debian:buster-slim
FROM FROM alpine:3.15 AS builder

RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs
USER electrs
WORKDIR /data

COPY --from=builder /usr/local/cargo/bin/electrs /bin/electrs

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

# ENTRYPOINT ["electrs"]
ENTRYPOINT ["docker_entrypoint.sh"]
