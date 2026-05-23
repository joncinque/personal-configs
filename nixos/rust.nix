# rust.nix: rust stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    rustup
    #cargo
    #clippy
    #rustc
    #rustfmt
    #rust-analyzer
  ];
}
