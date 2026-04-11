RESTART=false # Update the below block before uncommenting
if [[ "$RESTART" = true ]]; then
  WAIT_FOR_SUPERMAJORITY=96542804
  EXPECTED_BANK_HASH=5x6cLLsvsEbgbQxQNPoT1LvbTfYrx22kpXyzRxLKAMN3
fi

EXPECTED_GENESIS_HASH=4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY
export SOLANA_METRICS_CONFIG="host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"
RPC_URL=https://api.testnet.solana.com
ENTRYPOINTS=(entrypoint.testnet.solana.com:8001 entrypoint2.testnet.solana.com:8001 entrypoint3.testnet.solana.com:8001)
TRUSTED_VALIDATOR_PUBKEYS=(5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv)

ENABLE_ACCOUNT_INDEXES=false
if [[ "$ENABLE_ACCOUNT_INDEXES" = true ]]; then
  ACCOUNT_INDEXES=(program-id spl-token-owner spl-token-mint)
fi

ENABLE_EXCLUDE_KEYS=false
if [[ "$ENABLE_EXCLUDE_KEYS" = true ]]; then
  EXCLUDE_KEYS=(kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6 TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA)
fi

export RUST_BACKTRACE=1

DISABLE_ACCOUNTSDB_CACHE=false
ENABLE_CPI_AND_LOG_STORAGE=false
DISABLE_ACCOUNTS_DB_INDEX_HASHING=false
XDP=true
