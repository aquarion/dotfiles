#/usr/bin/bash

. $DOTFILES/bash/bash_colours

CHECKPOINT_DISABLE=true # Stop hashicorp products phoning home

NOTCONF=''
CONF=''

GHVERSION=2.2.0


function status_line {
	THING="$1"
	STATUS="$2"

	CONF+="`printf \"$IWhite % 10s: $Green %s $Color_Off\n\" \"$THING\" \"$STATUS\"`"
	CONF+=$'\n'
}


# if hash byobu 2>/dev/null; then
#   status_line "VTerm" "Byobu"
#   alias screen="byobu"
# else
#   status_line "VTerm" "Screen"
# fi


if hash aws 2>/dev/null; then
  status_line "AWS" "`aws --version 2>&1 | cut -c 9- | cut -d' ' -f 1`"
else
	NOTCONF="${NOTCONF}aws, "
fi

if hash eb 2>/dev/null; then
  status_line "Elastic BS" "`eb --version 2>&1 | cut -c 8-15`"
else
	NOTCONF="${NOTCONF}eb, "
fi

if hash ruby 2>/dev/null; then
	status_line "Ruby" "`ruby --version | cut -d" " -f2`"
else
	NOTCONF="${NOTCONF}Ruby, "
fi

if hash python 2>/dev/null; then
	status_line "Python" "`python --version 2>&1 | cut -d" " -f 2`"
else
	NOTCONF="${NOTCONF}Python?!, "
fi

#if hash virtualenv 2>/dev/null; then
#	status_line "VEnv" "`virtualenv --version | cut -d" " -f2`"
#else
#	NOTCONF="${NOTCONF}Virtualenv, "
#fi

if hash php 2>/dev/null; then
	status_line "PHP" "`php --version | head -1 | cut -d" " -f2`"

	if [[ -e $HOME/Development/pear/bin ]];
	then
		status_line "Pear" "Available"
		export PATH=$PATH:/Users/aquarion/Development/pear/bin
	else
		NOTCONF="${NOTCONF}Pear, "
	fi

else
	NOTCONF="${NOTCONF}PHP, "
fi


if [[ -s "$HOME/.rvm/scripts/rvm" ]]
then
	. "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
	status_line "RVM" "`rvm --version 2> /dev/null | cut -d" " -f2`"
	if [[ -s "$HOME/.rvm/bin" ]];
	then
		export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
	fi
else
	NOTCONF="${NOTCONF}RVM, "
fi

if hash composer 2> /dev/null
then
	COMVER=`composer -V | cut -d" " -f 2`
	if [[ $COMVER == "version" ]]
	then
		COMVER=`composer -V | cut -d" " -f 3`
	fi
	status_line "Composer" $COMVER
        export PATH=$PATH:$HOME/.composer/vendor/bin
else
	NOTCONF="${NOTCONF}Composer, "
fi

if [[ -s "/usr/local/heroku" ]];
then
	status_line "Heroku" "`heroku --version | tail -1 | cut -c 12- | cut -d" " -f 1`"
	export PATH="/usr/local/heroku/bin:$PATH"
else
	true
	# NOTCONF="${NOTCONF}Heroku, "
fi

if [[ -e ~/.bashrc.local ]];
then
	~/.bashrc.local
fi

if ! hash git 2> /dev/null; then
   NOTCONF="${NOTCONF}Git, "
elif hash gh 2>/dev/null; then
	GITVERSION_INSTALLED=`git version | head -1 | cut -d" " -f 3-`
	status_line "Git" $GITVERSION_INSTALLED
else

	GITVERSION_INSTALLED=`git version | head -1 | cut -d" " -f 3-`
	GHVERSION_INSTALLED=`hub version | tail -1 | cut -d" " -f 3-`

	status_line "Git" $GITVERSION_INSTALLED
	status_line "Github CLI" $GHVERSION

fi

if `which dropbox > /dev/null`;
then
	status_line "Dropbox" "$(dropbox status)"
elif [[ "$(uname)" == "Darwin" ]]; then
	true;
	# No Dropbox CLI on macOS
else
	NOTCONF="${NOTCONF}Dropbox, "
fi

if `which direnv > /dev/null`;
then
	status_line "Direnv" "`direnv version`"
else
	NOTCONF="${NOTCONF}Direnv, "
fi

if `which packer > /dev/null`;
then
	status_line "Packer" "`packer -v`"
else
	NOTCONF="${NOTCONF}Packer, "
fi

if `which terraform > /dev/null`;
then
	status_line "Terraform" "`terraform version | head -1 | cut -d" " -f2-` "
else
	NOTCONF="${NOTCONF}terraform, "
fi

if `which ansible > /dev/null`;
then
	status_line "Ansible (Global)" "`ansible --version | head -1 | cut -c 9-` "
else
	NOTCONF="${NOTCONF}ansible, "
fi

if `which wp > /dev/null`;
then
	status_line "WP CLI" "`wp --version | cut -d" " -f2`"
fi

CONF=`echo "$CONF" | sort`

echo "$CONF" | grep -v '^$'
export NOTCONF=`echo "Not Available: ${NOTCONF}" | sed 's/..$//' | sed 's/\(.*\),/\1 \&/'`
