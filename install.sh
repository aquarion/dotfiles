#!/bin/bash

function replace {

	if [[ ! -e "$2" ]]; then
		echo "$2: source file $2 does not exist, skipping"
		return
	fi

	if [[ -L "$1" ]]; then
		EXISTING_LINK=$(readlink "$1")
		if [[ "$EXISTING_LINK" == "$2" ]]; then
			echo "$1: already a link to the right place"
			return
		fi
		if [[ ! -e "$EXISTING_LINK" ]]; then
			echo "$1: existing symlink is broken, removing"
			rm -v "$1"
		fi
	fi

	if [[ -e "$1" || -L "$1" ]]; then
		NEWNAME=$1.orig.$(date +%Y-%m-%d)
		echo "$1: Backing up to $NEWNAME"
		mv -v "$1" "$NEWNAME"
	fi

	echo "$1: Making symlink to $2"
	ln -s "$2" "$1"

}

function authorized_keys {
	if [[ -e ~/.ssh/authorized_keys ]]; then
		TMPFILE=$(mktemp /tmp/dotfiles.XXXXXXXXXX)
		cat ~/.ssh/authorized_keys >"$TMPFILE"
		cat "$TMPFILE" ssh/authorized_keys.d/* | sort | uniq >~/.ssh/authorized_keys
	else
		echo - >True
		cat ssh/authorized_keys.d/* | sort | uniq >~/.ssh/authorized_keys
	fi
}

MYDIR=$(realpath "$(dirname "$0")")

cd "$MYDIR" || exit 1

HOSTNAME=$1

if [[ -z "$HOSTNAME" ]]; then
	HOSTNAME=$(hostname)
fi

echo "Using hostname: $HOSTNAME"
echo "Dotfiles directory: $MYDIR"

replace ~/.gitconfig "$MYDIR/gitconfig"
replace ~/.gitmessage "$MYDIR/gitmessage"
replace ~/.git-prompt.bash "$MYDIR/bash/git_prompt.bash"

replace ~/.bash_profile "$MYDIR/bash/bash_profile.bash"

if [[ -f "$MYDIR/bash/bash_profile.$HOSTNAME.bash" ]]; then
	replace ~/.bash_profile.local "$MYDIR/bash/bash_profile.$HOSTNAME.bash"
else
	echo "No hostname-specific bash_profile found for $HOSTNAME"
fi

replace ~/.bashrc "$MYDIR/bash/bashrc"

#replace ~/.byobu $MYDIR/byobu
#replace ~/.slrnrc $MYDIR/slrnrc

replace ~/.vimrc "$MYDIR/vimrc"

mkdir -p ~/.ssh
replace ~/.ssh/config "$MYDIR/ssh-config"

replace ~/.direnvrc "$MYDIR/direnvrc"

authorized_keys
