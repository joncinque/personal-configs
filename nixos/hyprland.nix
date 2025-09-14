# hyrpland.nix: install and configure
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # File manager stuff
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # See home-manager.nix for settings

  # Other things
  environment.systemPackages = with pkgs; [
    brightnessctl
    hypridle
    pavucontrol
    playerctl
    waybar
    wofi
    mako
    hyprpolkitagent
    hyprpaper
    grim
    slurp
    wl-clipboard
  ];

  # For Electron / Chromium support
  environment.variables.NIXOS_OZONE_WL = "1";
}

