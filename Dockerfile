FROM rust:1.48.0-slim AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git clang cmake libsnappy-dev

COPY ./electrs .

RUN cargo install --locked --path .

FROM debian:buster-slim

RUN apt update && apt install -y bash curl netcat tini wget
RUN wget https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_arm.tar.gz -O - |\
    tar xz && mv yq_linux_arm /usr/bin/yq

COPY --from=builder /usr/local/cargo/bin/electrs /bin/electrs

ADD ./configurator/target/aarch64-unknown-linux-musl/release/configurator /usr/local/bin/configurator
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD ./check-electrum.sh /usr/local/bin/check-electrum.sh
RUN chmod a+x /usr/local/bin/check-electrum.sh
ADD ./check-synced.sh /usr/local/bin/check-synced.sh
RUN chmod a+x /usr/local/bin/check-synced.sh

WORKDIR /data

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT ["docker_entrypoint.sh"]
