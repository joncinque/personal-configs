#!/usr/bin/env bash
set -ex

source /home/val/scripts/service-env.sh
/home/val/scripts/port-check.sh
#sleep 30
/home/val/active-release/bin/solana --url "$RPC_URL" catchup /home/val/keys/identity.json http://127.0.0.1:8899 ${@}
