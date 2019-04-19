#!/bin/bash
######################################################################################
directory="." ; filename="Programme.py" ; mkdir ~/.robot/ > /dev/null 2>&1
sha_1_robot_works=~/.robot/sha-1-robot-works  ; touch $sha_1_robot_works
sha_1_robot_error=~/.robot/sha-1-robot-error  ; touch $sha_1_robot_error
######################################################################################
function robotusage() {
    echo -e "Usage :\n   $0 auto|start|stop|restart|status\n" >&2 ; exit 0
} 
######################################################################################
function robotstatus() {
    if (pgrep -f "$filename") > /dev/null ; then
        echo "- Le robot est en fonctionnement." ; return 0
    else
        echo "- Le robot n'est pas en fonctionnement." ; return 1
    fi
}
######################################################################################
function robotstart() {
    if ! robotstatus > /dev/null ; then
        $(nohup python "$directory/$filename" > /dev/null 2>&1 &) ; sleep 1
        if robotstatus > /dev/null ; then
            echo "- Le robot a été démarré."
            echo $(git -C $directory rev-parse HEAD) > $sha_1_robot_works
        else 
            echo "- Le robot n'a pas pu être démarré."
            echo $(git -C $directory rev-parse HEAD) > $sha_1_robot_error
        fi
    else
        sleep 1 ; echo "- Le robot a été déjà démarré."
    fi
}
function robotstop() {
    if robotstatus > /dev/null ; then
        pkill -f "$dorectory/$filename" > /dev/null 2>&1 ; sleep 1
        echo "- Le robot a été arrêté."
    else
        sleep 1 ; echo "- Le robot a été déjà arrêté."
    fi
}
######################################################################################
function checkupdate() {
    git -C $directory fetch origin > /dev/null 2>&1
    results=$(git -C $directory log HEAD..origin/master --oneline) > /dev/null 2>&1
    if [ "${results}" != "" ] ; then
        if [ "$(cat $sha_1_robot_works)" == "" ] ; then 
            echo "+ Mise à jour du robot disponible." ; return 0
        fi
        if [ "$(git -C $directory rev-parse HEAD)" != "$(cat $sha_1_robot_error)" ] ; then
            echo "+ Mise à jour du robot disponible." ; return 0
        fi
    fi
    echo "+ Mise à jour du robot non disponsible." ; return 1
}
function cancelupdate() {
    sleep 1; echo "+ Suppression de la mise à jour.";
    git -C $directory reset --hard $(cat $sha_1_robot_works) > /dev/null 2>&1
}
function applyupdate() {
    sleep 1; echo "- Application de la mise à jour.";
    git -C $directory merge origin/master > /dev/null 2>&1
}
######################################################################################
function autoupdate() {
    robotstop > /dev/null ; robotstart | tr - + ;
    while true ; do
        if checkupdate ; then
            echo -n "  "; robotstop
            echo -n "  "; applyupdate
            echo -n "  "; robotstart ; sleep 1
            if ! robotstatus > /dev/null ; then
                echo -n "  "; cancelupdate
                echo -n "    "; robotstart
            fi
        fi
        sleep 3
    done
}
######################################################################################
case "$1" in
       stop) robotstop ;;
       auto) autoupdate ;;
      start) robotstart ;;
     status) robotstatus ;;
    restart) robotstop; robotstart ;;
          *) robotusage ;;
esac
######################################################################################
