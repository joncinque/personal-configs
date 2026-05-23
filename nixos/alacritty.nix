# alacritty.nix

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alacritty
  ];
  # See home-manager.nix for settings / alacritty.toml
}

