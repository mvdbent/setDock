#!/bin/zsh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# version 2.0
# Written by: Mischa van der Bent
#
# Permission is granted to use this code in any way you want.
# Credit would be nice, but not obligatory.
# Provided "as is", without warranty of any kind, express or implied.
#
# DESCRIPTION
# This script configures users docks using docktutil
# source dockutil https://github.com/kcrawford/dockutil/
# 
# REQUIREMENTS
# dockutil Version 3.0.0 or higher installed to /usr/local/bin/
# Compatible with macOS 11.x and higher
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# VARIABLES
# $4 = -- Required -- Application, Files and Folder Path ( /System/Applications/TextEdit.app )
# $5 = Position ( index_number - beginning - end - middle )
# $6 = View ( grid - fan - list - auto )
# $7 = Display ( folder - stack )
# $8 = Sort ( name - dateadded - datemodified - datecreated - kind )

if [[ $1 == '/' ]]; then
    # when $1 is /, then use the variables from Jamf 
    appPath="$4"
    position="$5"
    view="$6"
    display="$7"
    sort="$8"
else
    # default values for testing
    appPath="/Applications/Safari.app"
    position="2"
    view=""
    display="folder"
    sort=""
fi

# COLLECT IMPORTANT USER INFORMATION
# get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# get uid logged in user
uid=$(id -u "${currentUser}")

#Current User home folder - do it this way in case the folder isn't in /Users
userHome=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)

#path to plist
plist="${userHome}/Library/Preferences/com.apple.dock.plist"

# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
runAsUser() {  
	if [[ "${currentUser}" != "loginwindow" ]]; then
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	else
		echo "no user logged in"
		exit 1
	fi
}

# Check if dockutil is installed
if [[ -x "/usr/local/bin/dockutil" ]]; then
    dockutil="/usr/local/bin/dockutil"
else
    echo "dockutil not installed in /usr/local/bin, exiting"
    exit 1
fi

# Version dockutil
dockutilVersion=$(${dockutil} --version)
echo "Dockutil version = ${dockutilVersion}"

arguments=( )

#Jamf Pro Parameter value checks
if [[ ${appPath} != "" ]]; then
	arguments+=("--add" "${appPath}")
else
    echo "no appPath set"
    exit 1
fi

if [[ ${position} != "" ]]; then
	arguments+=("--position" "${position}")
fi

if [[ ${view} != "" ]]; then
	arguments+=("--view" "${view}")
fi

if [[ ${display} != "" ]]; then
	arguments+=("--display" "${display}")
fi

if [[ ${sort} != "" ]]; then
	arguments+=("--sort" "${sort}")
fi

# Add Application our Files and Documents to the Dock
if [[ -e ${appPath} ]]; then
	echo "Run command runAsUser ${dockutil} ${arguments} ${plist}"
    runAsUser "${dockutil}" ${arguments} ${plist}
else
	echo "${appPath} no valid Application, Files or Folder path"
	exit 2
fi
