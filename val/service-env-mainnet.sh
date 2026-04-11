RESTART=false # Update the below block before uncommenting
if [[ "$RESTART" = true ]]; then
  WAIT_FOR_SUPERMAJORITY=96542804
  EXPECTED_BANK_HASH=5x6cLLsvsEbgbQxQNPoT1LvbTfYrx22kpXyzRxLKAMN3
fi

EXPECTED_SHRED_VERSION=50093
EXPECTED_GENESIS_HASH=5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d
export SOLANA_METRICS_CONFIG="host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"
RPC_URL=https://api.mainnet-beta.solana.com
ENTRYPOINTS=(entrypoint.mainnet-beta.solana.com:8001 entrypoint2.mainnet-beta.solana.com:8001 entrypoint3.mainnet-beta.solana.com:8001 entrypoint4.mainnet-beta.solana.com:8001 entrypoint5.mainnet-beta.solana.com:8001)
TRUSTED_VALIDATOR_PUBKEYS=(7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S)

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
XDP=false
