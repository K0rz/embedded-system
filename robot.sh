#!/bin/bash
######################################################################################
function robotusage() {
    echo -e "Usage :\n   $0 start|stop|restart|status\n" >&2 ; exit 0
} 
######################################################################################
case "$1" in
    *) robotusage ;;
esac
######################################################################################

