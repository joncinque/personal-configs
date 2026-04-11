#!/usr/bin/env bash
set -ex
shopt -s nullglob

#shellcheck source=/dev/null
source /home/val/scripts/service-env.sh

#shellcheck source=/dev/null
source /home/val/scripts/jito-env.sh

# Delete any zero-length snapshots that can cause validator startup to fail
find /ledger/ledger -name 'snapshot-*' -size 0 -print -exec rm {} \; || true
find /accounts/snapshots -name 'snapshot-*' -size 0 -print -exec rm {} \; || true

vote_keypair=/home/val/keys/vote.json
voter_keypair=/home/val/keys/identity.json
identity_keypair=/home/val/keys/identity.json
identity_pubkey=$(/home/val/active-release/bin/solana-keygen pubkey $identity_keypair)

log_file=/data2/agave-validator.log
ledger_dir=/ledger/ledger
accounts_dir=/accounts/accounts
snapshots_dir=/accounts/snapshots
args=(
  --dynamic-port-range 8002-8027
  --gossip-port 8001
  --identity $identity_keypair
  --ledger "$ledger_dir"
  --accounts "$accounts_dir"
  --snapshots "$snapshots_dir"
  --limit-ledger-size
  --log "$log_file"
  --rpc-port 8899
  --private-rpc
  --full-rpc-api
  --expected-genesis-hash "$EXPECTED_GENESIS_HASH"
  --wal-recovery-mode skip_any_corrupted_record
  #--account-index program-id
  #--account-index spl-token-owner
)

if [[ -n $PUBLIC_RPC_ADDRESS ]]; then
  args+=(--public-rpc-address "$PUBLIC_RPC_ADDRESS")
fi

if [[ -f "$vote_keypair" ]]; then
  args+=(--vote-account "$vote_keypair")
else
  args+=(--no-voting)
fi

if [[ -f "$voter_keypair" ]]; then
  args+=(--authorized-voter "$voter_keypair")
fi

trusted_validators=
for tv in "${TRUSTED_VALIDATOR_PUBKEYS[@]}"; do
  if [[ $tv != "$identity_pubkey" ]]; then
    args+=(--trusted-validator "$tv")
    trusted_validators=1
  fi
done

if [[ -n $trusted_validators ]]; then
  args+=(--no-untrusted-rpc)
fi

if [[ -n $EXPECTED_SHRED_VERSION ]]; then
  args+=(--expected-shred-version "$EXPECTED_SHRED_VERSION")
fi

if [[ -n $SNAPSHOT_COMPRESSION ]]; then
  args+=(--snapshot-compression "$SNAPSHOT_COMPRESSION")
fi

if [[ $RESTART = true ]]; then
  args+=(--expected-bank-hash "$EXPECTED_BANK_HASH")
  args+=(--wait-for-supermajority "$WAIT_FOR_SUPERMAJORITY")
  args+=(--hard-fork "$hard_fork")
fi

if [[ -n $GOSSIP_HOST ]]; then
  args+=(--gossip-host "$GOSSIP_HOST")
fi

if [[ -d "$ledger_dir" ]]; then
  args+=(--no-genesis-fetch)
  args+=(--no-snapshot-fetch)
fi

if [[ $ENABLE_BPF_JIT = true ]]; then
  args+=(--bpf-jit)
fi
if [[ $DISABLE_ACCOUNTSDB_CACHE = true ]]; then
  args+=(--no-accounts-db-caching)
fi
if [[ $ENABLE_CPI_AND_LOG_STORAGE = true ]]; then
  args+=(--enable-cpi-and-log-storage)
fi
for entrypoint in "${ENTRYPOINTS[@]}"; do
  args+=(--entrypoint "$entrypoint")
done

if [[ $JITO = true ]]; then
  args+=(--tip-payment-program-pubkey ${TIP_PAYMENT_PROGRAM_PUBKEY})
  args+=(--tip-distribution-program-pubkey ${TIP_DISTRIBUTION_PROGRAM_PUBKEY})
  args+=(--merkle-root-upload-authority ${MERKLE_ROOT_UPLOAD_AUTHORITY})
  args+=(--commission-bps ${COMMISSION_BPS})
  args+=(--block-engine-url ${BLOCK_ENGINE_URL})
  args+=(--shred-receiver-address ${SHRED_RECEIVER_ADDRESS})
fi

if [[ $XDP = true ]]; then
  args+=(--experimental-retransmit-xdp-cpu-cores 1)
  #args+=(--experimental-retransmit-xdp-zero-copy)
  args+=(--experimental-poh-pinned-cpu-core 10)
fi

exec /home/val/active-release/bin/agave-validator "${args[@]}"
