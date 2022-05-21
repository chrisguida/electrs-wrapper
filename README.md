# Wrapper for Electrum Rust Server (electrs)

`electrs` is an efficient re-implementation of Electrum Server written in Rust. This wrapper allows electrs to integrate with other services on embassy-os and exposes its config in the embassy-os UI.

## Dependencies

- [docker](https://docs.docker.com/get-docker)
- [docker-buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [yq](https://mikefarah.gitbook.io/yq)
- [embassy-sdk](https://github.com/Start9Labs/embassy-os/blob/master/backend/install-sdk.sh)
- [make](https://www.gnu.org/software/make/)

## Cloning

```
git clone https://github.com/Start9Labs/electrs-wrapper.git
cd electrs-wrapper
git submodule update --init
```

## Building

```
make
```

## Sideload onto your Embassy

SSH into an Embassy device.
`scp` the `.s9pk` to any directory from your local machine.
Run the following command to determine successful install:

```
scp electrs.s9pk root@embassy-<id>.local:/embassy-data/package-data/tmp # Copy the S9PK to the external disk
ssh root@embassy-<id>.local
embassy-cli auth login
embassy-cli package install electrs.s9pk # Install the sideloaded package
```
