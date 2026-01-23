# udev.nix: additional udev rules for devices
{ config, pkgs, ...}:
{
  services.udev.packages = with pkgs; [
      ledger-udev-rules
      trezor-udev-rules
      # potentially even more if you need them
  ];
}

