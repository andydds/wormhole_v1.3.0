#!/usr/bin/env bash
# Regenerate bridge/pkg/ethereum/abi using a running eth-devnet's state.
set -euo pipefail

(
  cd third_party/abigen
  docker build -t localhost/certusone/wormhole-abigen:latest .
)

function gen() {
  local name=$1
  local pkg=$2

  kubectl exec -c tests eth-devnet-0 -- npx truffle run abigen $name

  kubectl exec -c tests eth-devnet-0 -- cat abigenBindings/abi/${name}.abi | \
    docker run --rm -i localhost/certusone/wormhole-abigen:latest /bin/abigen --abi - --pkg ${pkg} > \
    node/pkg/ethereum/${pkg}/abi.go
}

gen Wormhole abi
gen ERC20 erc20
