#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# THE SCRIPTS ARE PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
# I BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
# THE POSSIBILITY OF SUCH DAMAGE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# version 1.0
# Written by: Mischa van der Bent
#
# DESCRIPTION
# This script configures users docks using docktutil
# source dockutil https://github.com/kcrawford/dockutil/
# 
# REQUIREMENTS
# Deploy dockutil binary to /usr/local/bin/
# Compatible with Mac OS X 10.9.x thru 10.15 and on Big Sure macOS 11.x
#
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Check if Python is installed.
if which python > /dev/null 2>&1;
then
	echo "Python is installed"
else
	echo "Python is not installed, please install Python to run this script"
	exit 1
fi

# get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

#Current User home folder - do it this way in case the folder isn't in /Users
userHome=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)

# get uid logged in user
uid=$(id -u "${currentUser}")

# path to plist
plist="${userHome}/Library/Preferences/com.apple.dock.plist"

# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
runAsUser() {  
	if [ "${currentUser}" != "loginwindow" ]; then
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	else
		echo "no user logged in"
		# uncomment the exit command
		# to make the function exit with an error when no user is logged in
		exit 1
	fi
}

# Locate dockutil
if [ -x "/usr/local/bin/dockutil" ]; then
	dockutil="/usr/local/bin/dockutil"
else
	echo "cannot find dockutil, exiting"
	exit 1
fi

#dockutil Version
dockutilVersion=$(${dockutil} --version)
echo "Dockutil version = ${dockutilVersion}"

# reset Dock to Apple default
#runAsUser defaults delete com.apple.dock; killall Dock
#echo "Reset to Apple default dock"

# Create a clean Dock
$dockutil --remove all --no-restart
echo "clean-out the Dock"

# Setup dock, in various examples
$dockutil --add /System/Applications/Launchpad.app --position 1 --no-restart
$dockutil --add /Applications/zoom.us.app --position 2 --no-restart
$dockutil --add /Applications/Microsoft\ Teams.app --position end --no-restart
$dockutil --add /Applications/Google\ Chrome.app --position end  --no-restart
$dockutil --add /Applications/Microsoft\ Outlook.app --after 'Google Chrome' --no-restart
$dockutil --add /Applications/Microsoft\ Word.app --after 'Microsoft Outlook' --no-restart
$dockutil --add /Applications/Microsoft\ Excel.app --after 'Microsoft Word' --no-restart
$dockutil --add /Applications/Microsoft\ PowerPoint.app --after 'Microsoft Excel' --no-restart
$dockutil --add /Applications/BBEdit.app --after 'Microsoft PowerPoint' --no-restart
$dockutil --add /Applications/Self\ Service.app --position end --no-restart
$dockutil --add /System/Applications/System Preferences.app --before 'Self Service' --no-restart
$dockutil --add '/Applications' --view grid --display folder --sort name --no-restart
$dockutil --add '~/Downloads' --view list --display stack --sort dateadded --no-restart

echo "Created Default Dock"

# Disable show recent
runAsUser defaults write com.apple.dock show-recents -bool FALSE
echo "Hide show recent"

sleep 3

# Kill dock to reset it
killall -KILL Dock
echo "Restarted the Dock"

exit 0