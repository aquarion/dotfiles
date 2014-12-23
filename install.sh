#!/bin/bash

function replace {

	if [[ -e $1 || -L $1 ]];
	then
		mv -v $1 $1.orig.`date +%Y-%m-%d`
	fi

	ln -vs $2 $1

}

MYDIR=`dirname $0`
MYDIR=$( cd $(dirname $0) ; pwd -P )

replace ~/.gitconfig $MYDIR/gitconfig

replace ~/.bash_profile $MYDIR/bash/bash_profile

replace ~/.bashrc $MYDIR/bash/bashrc

replace ~/.byobu $MYDIR/byobu

replace ~/.slrnrc $MYDIR/slrnrc
