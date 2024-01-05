# Prints the current time in UTC.

TMUX_POWERLINE_SEG_POMO_DEFAULT="🍅"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# date(1) format for the UTC time.
export TMUX_POWERLINE_SEG_POMO_DEFAULT="${TMUX_POWERLINE_SEG_POMO_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_POMO_DEFAULT" ]; then
		export TMUX_POWERLINE_SEG_POMO_DEFAULT="${TMUX_POWERLINE_SEG_POMO_DEFAULT}"
	fi
}

run_segment() {
	__process_settings
	POMO_FILE=~/.local/share/fish/fish_pomo
	if [ -f $POMO_FILE ]; then
		printf "$TMUX_POWERLINE_SEG_POMO_DEFAULT "
		cat $POMO_FILE
		printf "m"
	fi
	return 0
}
