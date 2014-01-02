#!/usr/bin/env bash

VERSION="0.1.0"
SPEED_UNITS="KBytes/s"
SPEED_UNITS_ALT="KB/s"
IS_TRAPPED=false

# Check if running as super user
function flegma_check_sudo() {
	if [[ $(is_sudo) -eq 0 ]]; then
		echo "To run this command you must have root privileges."
		sudo -v
		if [[ $(is_sudo) -eq 0 ]]; then
			exit 126
		fi
	fi
}

function is_sudo() {
	sudo -n uptime 2>&1 | grep "load" | wc -l
}

# Stop throttling when exit is trapped
function flegma_trap_exit() {
	flegma_stop
	exit $?
}

# Trap exit
function flegma_trap() {
	trap flegma_trap_exit SIGINT
	while true; do
		# Run for 24 hours
		sleep 864000
	done
}

# Stop throttling
function flegma_stop() {
	sudo ipfw delete 1
	echo "Throttling stopped."
}

function flegma_help() {
	printf "%s [-hv] [-t [edge|3g|NUMBER]] [OPTION|NUMBER]

Options:
  test       Run Speed Test to check current speed.
  stop       Stop throttling.
  edge       Use EDGE preset (speed throttled to 90 $SPEED_UNITS_ALT)
  3g         Use 3G preset (speed throttled to 380 $SPEED_UNITS_ALT)
  -t         Trap current shell and stop throttling on exit.
  -v         Display version.
  -h         Display this help and exit\n\n" "$(basename $0)"
}

# Exit if no value or argument is passed
if [[ $# -eq 0 ]]; then
	flegma_help
	exit 1
fi

# Get arguments
while getopts :hvt OPTS_OPTION; do
	case $OPTS_OPTION in
		h)
			flegma_help
			exit 0
			;;
		v)
			echo "$(basename $0) $VERSION"
			exit 0
			;;
		t)
			# We are in trapping mode
			IS_TRAPPED=true
			;;
		\?)
			flegma_help
			exit 1
			;;
	esac
done

# Get next set of arguments
shift $(($OPTIND - 1))

case $1 in
		"test")
			# Run Speed Test CLI if available
			if command -v speedtest_cli >/dev/null 2>&1; then
				speedtest_cli --server 2136
			else
				echo "Speed Test CLI not available."
			fi
		;;
		"stop")
			flegma_check_sudo
			flegma_stop
		;;
		"edge")
			flegma_check_sudo
			sudo ipfw pipe 1 config bw 90$SPEED_UNITS
			sudo ipfw add 1 pipe 1 tcp from any to me
			echo "Throttling speed to 90 $SPEED_UNITS_ALT."
		;;
		"3g")
			flegma_check_sudo
			sudo ipfw pipe 1 config bw 380$SPEED_UNITS
			sudo ipfw add 1 pipe 1 tcp from any to me
			echo "Throttling speed to 380 $SPEED_UNITS_ALT."
		;;
		*)
			# Exit if no value is passed
			if [[ -z "$1" ]]; then
				flegma_help
				exit 1
			fi
			flegma_check_sudo
			sudo ipfw pipe 1 config bw $1$SPEED_UNITS
			sudo ipfw add 1 pipe 1 tcp from any to me
			echo "Throttling speed to $1 $SPEED_UNITS_ALT."
		;;
esac

# If we are in trapping mode, run trapping sequence
if $IS_TRAPPED; then
	flegma_trap
fi
