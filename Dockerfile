# FROM alpine:3.12

# RUN apk update
# RUN apk add tini

# ADD ./hello-world/target/armv7-unknown-linux-musleabihf/release/hello-world /usr/local/bin/hello-world
# ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
# RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# WORKDIR /root

# EXPOSE 80



FROM rust:1.44.1-slim-buster AS builder

ARG VERSION=v0.9.0
ENV REPO=https://github.com/romanz/electrs.git

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git cargo clang cmake libsnappy-dev

RUN git clone --branch $VERSION $REPO .

RUN cargo build --release --bin electrs


FROM debian:buster-slim

COPY --from=builder /build/target/release/electrs /bin/electrs

# Electrum RPC Mainnet
EXPOSE 50001
# Electrum RPC Testnet
EXPOSE 60001
# Electrum RPC Regtest
EXPOSE 60401

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

HEALTHCHECK CMD curl -fSs http://localhost:4224/ || exit 1

# ENTRYPOINT [ "electrs" ]
ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
