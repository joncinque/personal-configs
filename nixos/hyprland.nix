# hyrpland.nix: install and configure
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

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

