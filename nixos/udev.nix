# udev.nix: additional udev rules for devices
{ config, pkgs, ...}:
{
  services.udev.packages = with pkgs; [
      ledger-udev-rules
      trezor-udev-rules
      # potentially even more if you need them
  ];
  services.udev.extraRules = ''
    # Keystone rules
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="3001", MODE="0660", TAG+="uaccess"
  '';
}
