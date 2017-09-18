#/usr/bin/bash

. $DOTFILES/bash/bash_colours


NOTCONF=''
CONF=''

function status_line {
	THING="$1"
	STATUS="$2"

	CONF+="`printf \"$IWhite % 10s: $Green %s $Color_Off\n\" \"$THING\" \"$STATUS\"`"
	CONF+=$'\n'
}


if hash byobu 2>/dev/null; then
  status_line "VTerm" "Byobu" 
  alias screen="byobu"
else
  status_line "VTerm" "Screen"
fi



export WORKON_HOME=$HOME/.virtualenvs
if [[ -e /usr/local/bin/virtualenvwrapper.sh ]];
then
	status_line "VEnv" "`virtualenv --version`"
	source /usr/local/bin/virtualenvwrapper.sh
elif [[ -e /usr/bin/virtualenvwrapper.sh ]];
then
	status_line "VEnv" "`virtualenv --version`"
	source /usr/bin/virtualenvwrapper.sh
elif [[ -e /etc/bash_completion.d/virtualenvwrapper ]];
then
	status_line "VEnv" "`virtualenv --version`"
else
	NOTCONF="${NOTCONF}Virtualenv, "
fi

if [[ -e $HOME/Development/pear/bin ]];
then
	status_line "Pear" "Available"
	export PATH=$PATH:/Users/aquarion/Development/pear/bin
else
	NOTCONF="${NOTCONF}Pear, "
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
	status_line "Composer" "$(composer -V | cut -d" " -f 3)"
        export PATH=$PATH:$HOME/.composer/vendor/bin
else
	NOTCONF="${NOTCONF}Composer, "
fi

if [[ -s "/usr/local/heroku" ]];
then
	status_line "Heroku" "`heroku --version | tail -1 | cut -c 12- | cut -d" " -f 1`"
	export PATH="/usr/local/heroku/bin:$PATH"
else
	NOTCONF="${NOTCONF}Heroku, "
fi

if [[ -e ~/.bashrc.local ]];
then
	~/.bashrc.local
fi

HUBVERSION=2.3.0-pre10


if ! hash git 2> /dev/null; then
   NOTCONF="${NOTCONF}Git, "
elif hash hub 2>/dev/null; then
	HUBVERSION_INSTALLED=`hub version | tail -1 | cut -d" " -f 3-`
	GITVERSION_INSTALLED=`git version | head -1 | cut -d" " -f 3-`

	if [[ "$HUBVERSION" != "$HUBVERSION_INSTALLED" ]]; then
		echo " $HUBVERSION != $HUBVERSION_INSTALLED"
		$DOTFILES/bin/install_hub.sh $HUBVERSION
	fi

	status_line "Git/Hub" $GITVERSION_INSTALLED/$HUBVERSION

else

    $DOTFILES/bin/install_hub.sh $HUBVERSION

    alias git=hub
    
    git version >> ~/scratch/hub-linux-amd64-$HUBVERSION.log

	status_line "Git/Hub" $GITVERSION/$HUBVERSION
    
fi

if `which dropbox > /dev/null`;
then
	status_line "Dropbox" "$(dropbox status)"
else
	NOTCONF="${NOTCONF}Dropbox, "
fi

if `which direnv > /dev/null`;
then
	eval "$(direnv hook bash)"
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
	status_line "Ansible" "`ansible --version | head -1 | cut -c 9-` "
else
	NOTCONF="${NOTCONF}ansible, "
fi

CONF=`echo "$CONF" | sort`
echo "$CONF" | column 
echo "Not Available: ${NOTCONF}" | sed 's/..$//' | sed 's/\(.*\),/\1 \&/'