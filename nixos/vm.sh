#!/usr/bin/env bash
nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=channel:nixos-25.11 -I nixos-config=./configuration.nix
