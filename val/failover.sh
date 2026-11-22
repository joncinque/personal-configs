#!/usr/bin/env bash
set -ex
shopt -s nullglob

staked_pubkey=""
primary=""
secondary=""

# ssh ${primary}
sudo -u val /home/val/active-release/bin/agave-validator -l /ledger/ledger wait-for-restart-window --min-idle-time 2 --skip-new-snapshot-check
sudo -u val /home/val/active-release/bin/agave-validator -l /ledger/ledger set-identity /home/val/keys/identity-unstaked.json
sudo -u val ln -sf /home/val/keys/identity-unstaked.json /home/val/keys/identity.json

# middle machine
scp jon@${primary}:/ledger/ledger/vote_history-${staked_pubkey}.bin jon@${secondary}:/ledger/ledger

# ssh ${secondary}
sudo -u val /home/val/active-release/bin/agave-validator -l /ledger/ledger set-identity /home/val/keys/identity-staked.json
sudo -u val ln -sf /home/val/keys/identity-staked.json /home/val/keys/identity.json
