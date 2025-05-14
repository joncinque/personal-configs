# rust.nix: rust stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.rustup
    #pkgs.cargo
    #pkgs.clippy
    #pkgs.rustc
    #pkgs.rustfmt
    #pkgs.rust-analyzer
  ];
}
