#!/usr/bin/env bash
export DISCORD_WEBHOOK=""
export IDENTITY=""
agave-watchtower \
  --url https://api.testnet.solana.com \
  --monitor-active-stake \
  --unhealthy-threshold 0 \
  --validator-identity $IDENTITY
