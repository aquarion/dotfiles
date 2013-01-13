#!/bin/bash

. /etc/bash_completion
. ~/.bash_colours

git_dirty_flag() {
  return `git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) printf "%s", "!"}'`
}

#parse_git_branch
GIT_PS1_SHOWDIRTYSTATE=Yes
GITSTATUS=`__git_ps1 | tr -d ' '`

WD=$PWD
SHORTWD=`echo $PWD | sed -e"s#$HOME#~#"`
SHORTHOST=`hostname -s`;
#GITSTATUS=`git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) printf "%s", "!"}'`
#echo -en "$LIGHT_GREEN$SHORTHOST:$LIGHT_BLUE$SHORTWD$CYAN$GITSTATUS$NO_COLOUR"
echo -en "$SHORTHOST:$SHORTWD$GITSTATUS"
