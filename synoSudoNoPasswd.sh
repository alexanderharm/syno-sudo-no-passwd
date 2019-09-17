#!/bin/bash

# check if run as root
if [ $(id -u "$(whoami)") -ne 0 ]; then
	echo "SynoSudoNoPasswd needs to run as root!"
	exit 1
fi

# check if git is available
if command -v /usr/bin/git > /dev/null; then
	git="/usr/bin/git"
elif command -v /usr/local/git/bin/git > /dev/null; then
	git="/usr/local/git/bin/git"
elif command -v /opt/bin/git > /dev/null; then
	git="/opt/bin/git"
else
	echo "Git not found therefore no autoupdate. Please install the official package \"Git Server\", SynoCommunity's \"git\" or Entware's."
	git=""
fi

# check for arguments
if [ -z $1 ]; then
	echo "No rules (\"user:command\") passed to SynoSudoNoPasswd!"
	exit 1
else
	echo "This was passed: $*."
	rules=( "$@" )
fi

# save today's date
today=$(date +'%Y-%m-%d')

# self update run once daily
if [ ! -z "${git}" ] && [ -d "$(dirname "$0")/.git" ] && [ -f "$(dirname "$0")/autoupdate" ]; then
	if [ ! -f /tmp/.synoSudoNoPasswdUpdate ] || [ "${today}" != "$(date -r /tmp/.synoSudoNoPasswdUpdate +'%Y-%m-%d')" ]; then
		echo "Checking for updates..."
		# touch file to indicate update has run once
		touch /tmp/.synoSudoNoPasswdUpdate
		# change dir and update via git
		cd "$(dirname "$0")" || exit 1
		$git fetch
		commits=$($git rev-list HEAD...origin/master --count)
		if [ $commits -gt 0 ]; then
			echo "Found a new version, updating..."
			$git pull --force
			echo "Executing new version..."
			exec "$(pwd -P)/synoSudoNoPasswd.sh" "$@"
			# In case executing new fails
			echo "Executing new version failed."
			exit 1
		fi
		echo "No updates available."
	else
		echo "Already checked for updates today."
	fi
fi

# empty file
> /etc/sudoers.d/synoSudoNoPasswd

# loop through passed rules for users
for (( i=0; i<${#rules[@]}; i++ )); do

	echo "User_Alias USERS_$i = $(echo ${rules[$i]} | cut -d ':' -f 1)" >> /etc/sudoers.d/synoSudoNoPasswd

done

# loop through passed rules for commands
for (( i=0; i<${#rules[@]}; i++ )); do

	echo "Cmnd_Alias CMNDS_$i = $(echo ${rules[$i]} | cut -d ':' -f 2)" >> /etc/sudoers.d/synoSudoNoPasswd

done

# bringing it together
for (( i=0; i<${#rules[@]}; i++ )); do

	echo "USERS_$i ALL=(ALL) NOPASSWD: CMNDS_$i" >> /etc/sudoers.d/synoSudoNoPasswd

done

# exit
exit 0