#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAME="build_xref_token"

if docker ps -a --format '{{.Names}}' | grep -Eq "^${NAME}\$"; then
    echo "Container exists"
else
docker create \
     --mount type=bind,source=$DIR/..,target=/host \
     --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
     --name=$NAME \
     -w /host/xref-token \
     -e RUSTFLAGS='-C link-arg=-s' \
     -it \
     nearprotocol/contract-builder \
     /bin/bash
fi

docker start $NAME
docker exec -it $NAME /bin/bash -c "rustup toolchain install 1.69.0;rustup default 1.69.0;rustup target add wasm32-unknown-unknown; cargo build --target wasm32-unknown-unknown --release"

mkdir -p $DIR/../res
cp $DIR/../target/wasm32-unknown-unknown/release/xref_token.wasm $DIR/../res/xref_token_release.wasm

