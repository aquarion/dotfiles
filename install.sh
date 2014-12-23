#!/bin/bash

function replace {

	if [[ -L $1 && "$(readlink $1)" = "$2" ]]
	then
		echo "$1: already a link to the right place"
		return
	fi

	if [[ -e $1 || -L $1 ]];
	then
		NEWNAME=$1.orig.`date +%Y-%m-%d`
		echo "$1: Backing up to $NEWNAME"
		mv -v $1 $NEWNAME
	fi

	echo "$1: Making symlink to $2"
	ln -s $2 $1

}

MYDIR=`dirname $0`
MYDIR=$( cd $(dirname $0) ; pwd -P )

replace ~/.gitconfig $MYDIR/gitconfig

replace ~/.bash_profile $MYDIR/bash/bash_profile

replace ~/.bashrc $MYDIR/bash/bashrc

replace ~/.byobu $MYDIR/byobu

replace ~/.slrnrc $MYDIR/slrnrc
