ASSETS := $(shell yq e '.assets.[].src' manifest.yaml)
ASSET_PATHS := $(addprefix assets/,$(ASSETS))
VERSION := $(shell yq e ".version" manifest.yaml)
ELECTRS_SRC := $(shell find ./electrs/src) electrs/Cargo.toml electrs/Cargo.lock
CONFIGURATOR_SRC := $(shell find ./configurator/src) configurator/Cargo.toml configurator/Cargo.lock
S9PK_PATH=$(shell find . -name electrs.s9pk -print)

.DELETE_ON_ERROR:

all: verify

verify: electrs.s9pk $(S9PK_PATH)
	embassy-sdk verify s9pk $(S9PK_PATH)

clean:
	rm -f image.tar
	rm -f electrs.s9pk

electrs.s9pk: manifest.yaml assets/compat/* image.tar instructions.md $(ASSET_PATHS) scripts/embassy.js
	embassy-sdk pack

image.tar: Dockerfile check*.sh docker_entrypoint.sh configurator/target/aarch64-unknown-linux-musl/release/configurator $(ELECTRS_SRC)
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/electrs/main:$(VERSION) --platform=linux/arm64 -o type=docker,dest=image.tar .

configurator/target/aarch64-unknown-linux-musl/release/configurator: $(CONFIGURATOR_SRC)
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/configurator:/home/rust/src start9/rust-musl-cross:aarch64-musl cargo build --release

scripts/embassy.js: scripts/**/*.ts
	deno cache --reload scripts/embassy.ts
	deno bundle scripts/embassy.ts scripts/embassy.js
