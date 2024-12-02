#!/bin/sh
#

screenshot() {
	case $1 in
	full)
		scrot -m -F "$HOME/Képek/Képernyőképek/%F-%H%M%S_\$wx\$h.png"
		;;
	window)
		sleep 1
		scrot -s -F "$HOME/Képek/Képernyőképek/%F-%H%M%S_\$wx\$h.png"
		;;
	*)
		;;
	esac;
}

screenshot $1
