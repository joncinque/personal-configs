{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./fish.nix
    ./immich.nix
    ./jellyfin.nix
    ./neovim.nix
    ./nginx.nix
    ./postfix.nix
    ./rust.nix
    ./ssh.nix
    ./sys.nix
    ./tmux.nix
    ./users.nix
    ./wireless.nix
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

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8*1024; # 8 GB
  }];

  networking = {
    hostName = "pi-fun";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 25 80 443 587 ];
      allowedUDPPorts = [ 22 ];
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
