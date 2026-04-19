# fish.nix: setup shell and config
{ ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      set -Ux VISUAL vim
      set -Ux EDITOR vim

      function fish_mode_prompt
        # NOOP - Disable vim mode indicator
      end

      function fish_user_key_bindings
        bind -s --preset n history-search-forward
        bind -s --preset N history-search-backward

        bind -s --preset -m insert ci backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode
        bind -s --preset -m insert ca backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode

        bind -s --preset di backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection
        bind -s --preset da backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection

        bind -s --preset yi backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection
        bind -s --preset ya backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection
      end

      fish_user_key_bindings

      fish_add_path ~/solana-cli/bin
      fish_add_path ~/.cargo/bin
    '';
    promptInit = ''
      function fish_prompt --description 'Write out the prompt'
        set -l nix_shell_info (
          if test -n "$IN_NIX_SHELL"
            echo -n "<nix-sh> "
          end
        )
        printf '%s%s%s%s%s> ' (set_color yellow) $nix_shell_info (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
      end
    '';
  };
  programs.direnv.enable = true;
}
