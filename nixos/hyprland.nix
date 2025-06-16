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
    pkgs.brightnessctl
    pkgs.hypridle
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.waybar
    pkgs.wofi
  ];

  # For Electron / Chromium support
  environment.variables.NIXOS_OZONE_WL = "1";
}

