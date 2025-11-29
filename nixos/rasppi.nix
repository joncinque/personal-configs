# rasppi.nix: setup raspberry pi

{ config, pkgs, lib, ... }:

{
  imports = [
    ./docker.nix
    ./git.nix
    ./fish.nix
    ./funkwhale.nix
    ./neovim.nix
    ./nodejs.nix
    ./nginx.nix
    ./piwigo.nix
    ./postfix.nix
    ./python.nix
    ./rust.nix
    ./ssh.nix
    ./tmux.nix
    ./users.nix
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "pi-fun";
    wireless = {
      enable = true;
      #networks."SSID".psk = "PASSWORD";
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    gcc
  ];

  services.openssh.enable = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.11";

  system.copySystemConfiguration = true;
}
