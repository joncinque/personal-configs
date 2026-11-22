#!/usr/bin/env bash
export DISCORD_WEBHOOK=""
export JSON_RPC_1="https://api.mainnet-beta.solana.com"
export JSON_RPC_2="https://api.mainnet-beta.solana.com"
export JSON_RPC_3="https://api.mainnet-beta.solana.com"
export IDENTITY=""
agave-watchtower \
  --urls $JSON_RPC_1 $JSON_RPC_2 $JSON_RPC_3 \
  --monitor-active-stake \
  --unhealthy-threshold 0 \
  --validator-identity $IDENTITY
