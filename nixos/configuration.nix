# configuration.nix: top-level nixos config

{ pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./browser.nix
    ./communication.nix
    ./docker.nix
    ./git.nix
    ./fish.nix
    ./framework.nix
    #./hardware-configuration.nix # Auto-generated for full nixos machines
    #./home-manager.nix # I'm not a huge fan of this
    ./hyprland.nix
    ./neovim.nix
    ./nodejs.nix
    ./python.nix
    ./rust.nix
    ./ssh.nix
    ./tmux.nix
    ./users.nix
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lets-go-nix";
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  fonts = {
    packages = with pkgs; [
      font-awesome
    ];
  };

  environment.systemPackages = with pkgs; [
    pkgs.curl
    pkgs.gcc
    pkgs.lld
    pkgs.bluetui
    pkgs.bluetuith
  ];

  #networking.firewall = {
  #  enable = true;
  #  allowPing = true;
  #};
  services.openssh.enable = true;
  services.xserver = {
    enable = true;
    # GNOME desktop
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Keymap
    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "24.11";
  # TODO: extra key file for ssh: IdentityFile ~/.ssh/github_id_rsa
  # TODO: hyprland config
  # TODO: alacritty config
  # TODO: probably a bunch of missing utilities

  # Get the current configuration at /run/current-system/configuration.nix
  system.copySystemConfiguration = true;
}
