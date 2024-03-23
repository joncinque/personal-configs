#!/usr/bin/env fish

set -g fish_key_bindings fish_vi_key_bindings

set -Ux VISUAL vim
set -Ux EDITOR vim

set -gx PATH $HOME/.local/share/solana/install/active_release/bin $HOME/.cargo/bin $HOME/.local/bin $HOME/n/bin /usr/sbin /sbin $PATH
set -gx RUST_SRC_PATH (rustc --print sysroot)/lib/rustlib/src/rust/library

function fish_mode_prompt
  # NOOP - Disable vim mode indicator
end

function fish_user_key_bindings
  # TODO remove once fish 3.2.0 is released
  bind -s --preset -m insert cf begin-selection forward-jump kill-selection end-selection repaint-mode
  bind -s --preset -m insert ct begin-selection forward-jump backward-char kill-selection end-selection repaint-mode
  bind -s --preset -m insert cF begin-selection backward-jump kill-selection end-selection repaint-mode
  bind -s --preset -m insert cT begin-selection backward-jump forward-char kill-selection end-selection repaint-mode
  bind -s --preset df begin-selection forward-jump kill-selection end-selection
  bind -s --preset dt begin-selection forward-jump backward-char kill-selection end-selection
  bind -s --preset dF begin-selection backward-jump kill-selection end-selection
  bind -s --preset dT begin-selection backward-jump forward-char kill-selection end-selection
  # TODO finish removal area

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

function fish_prompt --description 'Write out the prompt'
  if test -z "$WINDOW"
    printf '%s%s@%s%s%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  else
    printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  end
end

function ll
  ls -lh $argv
end

function setclip
  xsel --clipboard
end

function getclip
  xsel --clipboard -o
end

source "$HOME/.cargo/env.fish"

set -x N_PREFIX "$HOME/n"; contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
