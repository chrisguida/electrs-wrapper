ASSETS := $(shell yq e '.assets.[].src' manifest.yaml)
ASSET_PATHS := $(addprefix assets/,$(ASSETS))
VERSION := $(shell yq e ".version" manifest.yaml)
ELECTRS_SRC := $(shell find ./electrs/src) electrs/Cargo.toml electrs/Cargo.lock
S9PK_PATH=$(shell find . -name electrs.s9pk -print)

.DELETE_ON_ERROR:

all: verify

verify: electrs.s9pk $(S9PK_PATH)
	embassy-sdk verify s9pk $(S9PK_PATH)

clean:
	rm -f image.tar
	rm -f electrs.s9pk

electrs.s9pk: manifest.yaml assets/compat/config_spec.yaml assets/compat/config_rules.yaml image.tar instructions.md $(ASSET_PATHS)
	embassy-sdk pack

image.tar: Dockerfile check-electrum.sh docker_entrypoint.sh
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/electrs/main:$(VERSION) --platform=linux/arm64 -o type=docker,dest=image.tar .

# electrs/target/aarch64-unknown-linux-musl/release/electrs: $(ELECTRS_SRC)
# 	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/electrs:/home/rust/src start9/rust-musl-cross:aarch64-musl cargo build --release
# 	# cd electrs && cargo build --release
