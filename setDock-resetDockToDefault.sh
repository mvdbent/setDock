#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# version 1.0
# Written by: Mischa van der Bent
#
# Permission is granted to use this code in any way you want.
# Credit would be nice, but not obligatory.
# Provided "as is", without warranty of any kind, express or implied.
#
# DESCRIPTION
# This script resets the users docks back to factory defaults
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Collect importend user information
# get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# get uid logged in user
uid=$(id -u "${currentUser}")

# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
runAsUser() {  
	if [ "${currentUser}" != "loginwindow" ]; then
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	else
		echo "no user logged in"
		exit 1
	fi
}

# reset Dock to default
runAsUser defaults delete com.apple.dock
echo "reset to default dock"
sleep 5

runAsUser killall cfprefsd

# Kill dock to reset it
killall Dock

exit 0