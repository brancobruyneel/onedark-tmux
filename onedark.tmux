#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
	local option value default
	option="$1"
	default="$2"
	value="$(tmux show-option -gqv "$option")"

	if [ -n "$value" ]; then
		echo "$value"
	else
		echo "$default"
	fi
}

set() {
	local option=$1
	local value=$2
	tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
	local option=$1
	local value=$2
	tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
	local theme
	theme="$(get_tmux_option "@onedark_flavour" "dark")"

	# Aggregate all commands in one array
	local tmux_commands=()

	# NOTE: Pulling in the selected theme by the theme that's being set as local
	# variables.
	# shellcheck source=onedark.tmuxtheme
	source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/onedark-${theme}.tmuxtheme")"

	# status
	set status "on"
	set status-bg "${black}"
	set status-justify "left"
	set status-left-length "100"
	set status-right-length "100"

	# messages
	set message-style "fg=${white},bg=${black},align=centre"
	set message-command-style "fg=${white},bg=${black},align=centre"

	# panes
	set pane-border-style "fg=${line}"
	set pane-active-border-style "fg=${nord_blue}"

	# windows
	setw window-status-activity-style "fg=${white},bg=${black},none"
	setw window-status-separator ""
	setw window-status-style "fg=${white},bg=${black},none"

	# --------=== Statusline

	# NOTE: Checking for the value of @onedark_window_tabs_enabled
	local wt_enabled
	wt_enabled="$(get_tmux_option "@onedark_window_tabs_enabled" "off")"
	readonly wt_enabled

	local right_separator
	right_separator="$(get_tmux_option "@onedark_right_separator" "")"
	readonly right_separator

	local left_separator
	left_separator="$(get_tmux_option "@onedark_left_separator" "")"
	readonly left_separator

	local user
	user="$(get_tmux_option "@onedark_user" "off")"
	readonly user

	local host
	host="$(get_tmux_option "@onedark_host" "off")"
	readonly host

	local date_time
	date_time="$(get_tmux_option "@onedark_date_time" "off")"
	readonly date_time

	# These variables are the defaults so that the setw and set calls are easier to parse.
	local show_directory
	readonly show_directory="#[fg=$red,bg=$one_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$one_bg,bg=$blue,nobold,nounderscore,noitalics]  #[fg=$thm_fg,bg=$thm_gray] #{b:pane_current_path} #{?client_prefix,#[fg=$thm_red]"

	local show_window
	readonly show_window="#[fg=$red,bg=$statusline_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$black,bg=$red,nobold,nounderscore,noitalics] #[fg=$white,bg=$one_bg2] #W "

	local show_session
	readonly show_session="#{?client_prefix,#[fg=$green],#[fg=$nord_blue]}#[bg=$black]$right_separator#{?client_prefix,#[bg=$green],#[bg=$nord_blue]}#[fg=$black] #[fg=$white,bg=$one_bg2] #S "

	local show_directory_in_window_status
	readonly show_directory_in_window_status="#[fg=$one_bg,bg=$grey] #I #[fg=$white,bg=$one_bg] #W "

	local show_directory_in_window_status_current
	readonly show_directory_in_window_status_current="#[fg=$black,bg=$nord_blue] #I #[fg=$white,bg=$one_bg] #W "

	local show_window_in_window_status
	readonly show_window_in_window_status="#[fg=$white,bg=$black] #W #[fg=$black,bg=$nord_blue] #I#[fg=$nord_blue,bg=$black]$left_separator#[fg=$nord_blue,bg=$black,nobold,nounderscore,noitalics] "

	local show_window_in_window_status_current
	readonly show_window_in_window_status_current="#[fg=$white,bg=$black] #W #[fg=$black,bg=$one_bg2] #I#[fg=$black,bg=$one_bg2]$left_separator#[fg=$black,bg=$one_bg2,nobold,nounderscore,noitalics] "

	# Right column 1 by default shows the Window name.
	local right_column1=$show_window

	# Right column 2 by default shows the current Session name.
	local right_column2=$show_session

	# Window status by default shows the current directory basename.
	local window_status_format=$show_directory_in_window_status
	local window_status_current_format=$show_directory_in_window_status_current

	set status-left ""

	set status-right "${right_column2}"

	setw window-status-format "${window_status_format}"
	setw window-status-current-format "${window_status_current_format}"

	# --------=== Modes
	#
	setw clock-mode-colour "${nord_blue}"
	setw mode-style "fg=${nord_blue} bg=${black} bold"

	tmux "${tmux_commands[@]}"
}

main "$@"
