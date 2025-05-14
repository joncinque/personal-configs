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

      function ll
        ls -lh $argv
      end

      function setclip
        wl-copy
      end

      function getclip
        wl-paste -o
      end

      #source "$HOME/.cargo/env.fish"
      #eval (dircolors -c ~/.dircolors)
      #set -x N_PREFIX "$HOME/n"; contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
    '';
    promptInit = ''
      function fish_prompt --description 'Write out the prompt'
        printf '%s%s%s> ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
      end
    '';
  };
}
