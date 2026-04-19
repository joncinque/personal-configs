#!/usr/bin/env fish

set -g fish_key_bindings fish_vi_key_bindings

set -Ux VISUAL vim
set -Ux EDITOR vim

set -gx PATH $HOME/.cargo/bin $HOME/.local/bin $PATH
set -gx RUST_SRC_PATH (rustc --print sysroot)/lib/rustlib/src/rust/library

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

source "$HOME/.cargo/env.fish"
eval (dircolors -c ~/.dircolors)

function fish_prompt --description 'Write out the prompt'
  #if test -z "$WINDOW"
    #printf '%s%s@%s%s%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  #else
  #  printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  #end
  set -l nix_shell_info (
    if test -n "$IN_NIX_SHELL"
      echo -n "<nix-sh> "
    end
  )
  printf '%s%s%s%s%s> ' (set_color yellow) $nix_shell_info (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end
