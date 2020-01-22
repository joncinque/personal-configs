fish_vi_key_bindings
set -Ux VISUAL vim
set -Ux EDITOR vim

set -Ux DEBFULLNAME "Jon Cinque"
set -Ux DEBEMAIL jon.cinque@gmail.com
set -gx PATH /snap/bin $PATH

function fish_mode_prompt
  # NOOP - Disable vim mode indicator
end

#function reverse_history_search
#history | fzf --no-sort | read -l command
#if test $command
#commandline -rb $command
#end
#end

#function fish_user_key_bindings
#bind -M default / reverse_history_search
#end

function fish_prompt --description 'Write out the prompt'
  set -l last_status $status
	if test -z $WINDOW
        printf '%s[%s]%s%s%s:%s%s%s> ' (set_color yellow) (date +%H:%M) (set_color purple) (whoami) (set_color normal) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    else
        printf '%s[%s]%s%s%s:%s(%s)%s%s%s> ' (set_color yellow) (date +%H:%M) (set_color purple) (whoami) (set_color normal) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
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
