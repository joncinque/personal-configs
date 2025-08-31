# this doesn't seem to work
{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.alice = { pkgs, ... }: {
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";

    home.username = "alice";
    home.homeDirectory = "/home/alice";
    programs.home-manager.enable = true;

    home.file.".alacritty.toml".text = ''
      [window]
      decorations = "None"
      startup_mode = "Maximized"
      [font]
      size = 12.0
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        exec-once = "waybar";
        "$terminal" = "alacritty";
        "$fileManager" = "dolphin";
        "$menu" = "wofi --show drun";
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ];
        general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";
            resize_on_border = true;
            allow_tearing = false;
            layout = "dwindle";
        };

        decoration = {
            rounding = 10;
            rounding_power = 2;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
            };

            blur = {
                enabled = true;
                size = 3;
                passes = 1;
                vibrancy = 0.1696;
            };
        };

        animations = {
            enabled = true;

            bezier = [
              "easeOutQuint,0.23,1,0.32,1"
              "easeInOutCubic,0.65,0.05,0.36,1"
              "linear,0,0,1,1"
              "almostLinear,0.5,0.5,0.75,1.0"
              "quick,0.15,0,0.1,1"
            ];

            animation = [
              "global, 1, 10, default"
              "border, 1, 5.39, easeOutQuint"
              "windows, 1, 4.79, easeOutQuint"
              "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
              "windowsOut, 1, 1.49, linear, popin 87%"
              "fadeIn, 1, 1.73, almostLinear"
              "fadeOut, 1, 1.46, almostLinear"
              "fade, 1, 3.03, quick"
              "layers, 1, 3.81, easeOutQuint"
              "layersIn, 1, 4, easeOutQuint, fade"
              "layersOut, 1, 1.5, linear, fade"
              "fadeLayersIn, 1, 1.79, almostLinear"
              "fadeLayersOut, 1, 1.39, almostLinear"
              "workspaces, 1, 1.94, almostLinear, fade"
              "workspacesIn, 1, 1.21, almostLinear, fade"
              "workspacesOut, 1, 1.94, almostLinear, fade"
            ];
        };

        dwindle = {
            pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true; # You probably want this
        };

        master = {
            new_status = "master";
        };

        misc = {
            force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
        };

        input = {
            kb_layout = "us";

            follow_mouse = 1;

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

            touchpad = {
                natural_scroll = true;
            };
        };

        gestures = {
            workspace_swipe = false;
        };

        device = {
            name = "epic-mouse-v1";
            sensitivity = -0.5;
        };

        "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

        bind = [
          "$mainMod, Q, exec, $terminal"
          "$mainMod, C, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, pseudo,"
          "$mainMod, J, togglesplit,"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Cycle workspace with mainMod + TAB
          "$mainMod, Tab, workspace, e+1"
          "$mainMod SHIFT, Tab, workspace, e-1"

          # Example special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];

          # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

# Laptop multimedia keys for volume and LCD brightness
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];
        bindl = [
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        windowrule = [
          # Ignore maximize requests from apps. You'll probably like this.
          "suppressevent maximize, class:.*"
          # Fix some dragging issues with XWayland
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];
      };
    };
  };
}
