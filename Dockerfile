# FROM alpine:3.12

# RUN apk update
# RUN apk add tini

# ADD ./hello-world/target/armv7-unknown-linux-musleabihf/release/hello-world /usr/local/bin/hello-world
# ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
# RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# WORKDIR /root

# EXPOSE 80


ARG VERSION=v0.9.4

FROM rust:1.48.0-slim AS builder
# FROM alpine:3.15 AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git clang cmake libsnappy-dev

# RUN apk update
# RUN apk add -y git clang cmake libsnappy-dev

RUN git clone --branch $VERSION https://github.com/romanz/electrs .

# COPY ./electrs /build/

RUN cargo install --locked --path .

FROM debian:buster-slim
# FROM alpine:3.15

RUN apt update && apt install -y bash curl tini
# RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs

COPY --from=builder /usr/local/cargo/bin/electrs /bin/electrs

ADD ./electrs/target/aarch64-unknown-linux-musl/release/electrs /usr/local/bin/electrs
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD ./check-electrum.sh /usr/local/bin/check-electrum.sh
RUN chmod a+x /usr/local/bin/check-electrum.sh

# USER electrs
WORKDIR /data

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

# ENTRYPOINT ["electrs"]
ENTRYPOINT ["docker_entrypoint.sh"]
