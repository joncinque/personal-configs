#!/usr/bin/env bash
nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=channel:nixos-25.05 -I nixos-config=./configuration.nix
