# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
#umask 022

# shellcheck shell=bash
# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

if hash gsed 2>/dev/null; then
	alias sed=gsed
fi

if [[ -d ~/code/dotfiles ]]; then
	MYDIR=~/code/dotfiles
else
	MYDIR=$(find ~ -name dotfiles -type d -print -quit)
fi

export MYDIR=$MYDIR

# shellcheck source=git_completion.lib.bash
. "$MYDIR/bash/git_completion.lib.bash"
# shellcheck source=lib/colours.lib.bash
. "$MYDIR/bash/lib/colours.lib.bash"
# shellcheck source=lib/functions.lib.bash
. "$MYDIR/bash/lib/functions.lib.bash"

if [ "$(uname)" == "Darwin" ]; then
	export ARCH="darwin-amd64"
elif [[ $(uname -i) = "x86_64" ]]; then
	export ARCH="linux-amd64"
elif [[ $(uname -i) = "i686" ]]; then
	export ARCH="linux-386"
fi

if [ -d /home/linuxbrew/.linuxbrew ]; then
	PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
fi

if hash brew 2>/dev/null; then
	if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
		HAS_BREW=Yes
	fi
fi

if [[ $HAS_BREW = "Yes" ]]; then
	. "$(brew --prefix)/etc/bash_completion"
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
elif [ -f "$HOME/.git_bash_completion" ]; then
	. "$HOME/.git_bash_completion"
elif [ -f "$MYDIR/bash/git_completion.bash" ]; then
	. "$MYDIR/bash/git_completion.bash"
fi

if [ -f "$HOME/.git-prompt.bash" ]; then
	. "$HOME/.git-prompt.bash"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin:${PATH}"
fi

if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:${PATH}"
fi

# do the same with MANPATH
if [ -d "$HOME/man" ]; then
	MANPATH="$HOME/man${MANPATH:-:}"
	export MANPATH
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
	export EDITOR="code -w"
elif hash vim 2>/dev/null; then
	export EDITOR=vim
fi

# shellcheck disable=SC2034
GIT_PS1_SHOWDIRTYSTATE=true

export LS_OPTIONS='--color=auto'
export CLICOLOR='Yes'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

function ps1_git_state {

	if hash __git_ps1 2>/dev/null; then
		true
	else
		return
	fi

	local GITSTATE=""
	GITSTATE=$(__git_ps1 " (🪾 %s)")

	if [[ $GITSTATE =~ \*\)$ ]]; then
		echo -e "\001$Yellow\002$GITSTATE"
	elif [[ $GITSTATE =~ \+\)$ ]]; then
		echo -e "\001$Purple\002$GITSTATE"
	else
		echo -e "\001$Cyan\002$GITSTATE"
	fi
}

function __kube_ps1() {
	if [[ ! -f ~/.kube/config ]]; then
		return
	fi
	local CONTEXT
	CONTEXT=$(awk '/^current-context:/ {gsub(/"/, "", $2); print $2; exit}' ~/.kube/config 2>/dev/null)
	if [ -n "$CONTEXT" ]; then
		echo "[🧊${CONTEXT}]"
	fi
}

function gcloud_ps1 {
	local config_dir="$HOME/.config/gcloud"
	local active_config="default"
	if [[ -f "$config_dir/active_config" ]]; then
		active_config=$(<"$config_dir/active_config")
	fi
	local config_file="$config_dir/configurations/config_${active_config}"
	if [[ ! -f "$config_file" ]]; then
		return
	fi
	local project
	project=$(awk -F'=' '/^\s*project\s*=/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$config_file")
	if [[ -n "$project" ]]; then
		echo "[🇬-$project]"
	fi
}

__AWS_PS1_CACHE=""
__AWS_PS1_CACHE_TIME=0
__AWS_PS1_CACHE_PROFILE=""
__AWS_PS1_TTL=30

function __aws_ps1() {
	if [[ ! -f "$MYDIR/aws/aws_session__ps1.py" || ! -d "$MYDIR/aws/.direnv" ]]; then
		return
	fi
	local now="${EPOCHSECONDS:-$(date +%s)}"
	local profile="${AWS_PROFILE:-default}"
	if [[ "$profile" == "$__AWS_PS1_CACHE_PROFILE" ]] && ((now - __AWS_PS1_CACHE_TIME < __AWS_PS1_TTL)); then
		echo "$__AWS_PS1_CACHE"
		return
	fi
	PYTHONS=("$MYDIR/aws/.direnv/python-"*/bin/python3)
	__AWS_PS1_CACHE=$("${PYTHONS[0]}" "$MYDIR/aws/aws_session__ps1.py")
	__AWS_PS1_CACHE_TIME=$now
	__AWS_PS1_CACHE_PROFILE=$profile
	echo "$__AWS_PS1_CACHE"
}

export PROMPT_DIRTRIM=1

# export PS1="\[$Cyan\]\u\[$White\]@\[$Green\]\h \[$Blue\]\w\[$White\]\$(ps1_git_state):\[$Color_Off\] "
export PS1="\[$Cyan\]\u\[$White\]@\[$Green\]\h \[$White\]\$(__kube_ps1) \[$Blue\]\$(gcloud_ps1) \$(__aws_ps1)\$(ps1_git_state)\n\[$Blue\]\w \$\[$Color_Off\] "

alias ll='ls -lah'
alias gg='git status -s'
alias gr='cd $(git root)'

export NVM_DIR="$HOME/.nvm"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"    # This loads RVM into a shell session.
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

if [[ -d "$HOME/.rvm/bin" ]]; then
	# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
	export PATH="$PATH:$HOME/.rvm/bin"
fi

if [[ -e /usr/local/bin/virtualenvwrapper.sh && -e /usr/local/bin/python3 ]]; then
	export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
	source /usr/local/bin/virtualenvwrapper.sh
fi
#`echo $- | grep -qs i` && byobu-launcher && exit 0

# MacPorts Installer addition on 2014-02-25_at_12:26:12: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

if [ -d /Applications/Visual\ Studio\ Code.app ]; then
	PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

if [ -d "$HOME/Library/Python/2.7/bin" ]; then
	PATH="$PATH:$HOME/Library/Python/2.7/bin"
fi

if [ -d "$HOME/.config/composer/vendor/bin" ]; then
	PATH="$PATH:$HOME/.config/composer/vendor/bin"
fi

if [ -d "$HOME/.local/lib/aws/bin" ]; then
	PATH="$PATH:$HOME/.local/lib/aws/bin"
	complete -C "$HOME/.local/lib/aws/bin/aws_completer" aws
fi

if [[ -d /opt/homebrew ]]; then # New Homebrew directory
	PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
	MANPATH="$MANPATH:/opt/homebrew/manpages"
	export MANPATH
fi

export PATH=$PATH:$MYDIR/bin

# export PATH=$PATH:vendor/bin:node_modules/.bin

export ORIGINAL_PATH=$PATH

# Remove duplicates from PATH

function clean_path {
	ARG=$1
	if [[ -z $ARG ]]; then
		ARG=$PATH
	fi

	declare -a DEDUPED_PATH=()

	local oldIFS=$IFS
	local IFS=: # Set the Internal Field Separator to :
	set -f      # Disable glob expansion
	# shellcheck disable=SC2206
	local DIRTY_PATH=($ARG) # Deliberately unquoted to split on IFS

	for DIR in "${DIRTY_PATH[@]}"; do
		if [[ -d "$DIR" ]] && [[ ":${DEDUPED_PATH[*]}:" != *":$DIR:"* ]]; then
			DEDUPED_PATH+=("$DIR")
			# echo accepted $DIR >/dev/stderr
			# else
			# echo Rejected $DIR >/dev/stderr
		fi
	done

	local NEW_PATH
	NEW_PATH=$(
		IFS=:
		echo "${DEDUPED_PATH[*]}"
	)
	IFS=$oldIFS # Reset the IFS
	echo $NEW_PATH

	# echo $ARG | sed -e $'s/:/\\\n/g' | awk '!x[$0]++' | xargs -I "{}" bash -c 'test -s "{}" && echo -n "{}":' | sed 's/:$//'

}

# If global composer vendor bin directory exists, add it to PATH
if [[ -d $HOME/.config/composer/vendor/bin ]]; then
	PATH=$HOME/.config/composer/vendor/bin:$PATH
fi

hash npm 2>/dev/null && PS1_CACHE_NPM=1 || PS1_CACHE_NPM=
hash composer 2>/dev/null && PS1_CACHE_COMPOSER=1 || PS1_CACHE_COMPOSER=

function do_prompt_command {
	# echo "ANTP"
	# echo clean: $CLEAN_PATH
	# CLEAN_PATH=$PATH

	local CLEANED_PATH=""
	local GITDIR=""
	local GITDIRFAIL=""
	local NEW_PATH=""
	local COMPOSERDIR=""
	local COMPOSERBIN=""
	local NPMBIN=""

	GITDIR=$(git rev-parse --show-toplevel 2>/dev/null)
	GITDIRFAIL=$?

	if [[ $GITDIRFAIL -gt 0 ]]; then
		unset GITDIR
	fi

	if hash pre-commit 2>/dev/null; then
		if [[ -d $GITDIR && -f $GITDIR/.pre-commit-config.yaml ]]; then
			if [[ ! -f $GITDIR/.git/hooks/pre-commit ]]; then
				echo "Installing pre-commit hooks for $GITDIR"
				pre-commit install --install-hooks
			fi
		fi
	fi
	NEW_PATH=$PATH
	#NEW_PATH=$CLEAN_PATH
	if [ ! -z $VIRTUAL_ENV ]; then
		# echo "VE $VIRTUAL_ENV"
		NEW_PATH=$VIRTUAL_ENV/bin:$NEW_PATH
	fi
	if [[ -n $PS1_CACHE_NPM ]]; then
		NPMBIN=$(npm bin)
		if [ -d "$NPMBIN" ]; then
			echo "NPM $NPMBIN "
			NEW_PATH=$NPMBIN:$NEW_PATH
		fi
	fi
	if [[ -n $PS1_CACHE_COMPOSER ]]; then
		if [[ -d $GITDIR && -f $GITDIR/composer.json ]]; then
			COMPOSERDIR=$GITDIR
		elif [[ -f ./composer.json ]]; then
			COMPOSERDIR=.
		elif [[ $COMPOSERDIR ]]; then
			unset COMPOSERDIR
		fi

		if [[ $COMPOSERDIR ]]; then
			COMPOSERBIN=$(composer --working-dir=$COMPOSERDIR config bin-dir)
			if [ -d "$COMPOSERDIR/$COMPOSERBIN" ]; then
				NEW_PATH=$COMPOSERDIR/$COMPOSERBIN:$NEW_PATH
			fi
		fi

	fi

	CLEANED_PATH=$(clean_path "$NEW_PATH")
	if [[ $CLEANED_PATH ]]; then
		export NEW_PATH=$CLEANED_PATH
	else
		echo Path clean failed on $NEW_PATH
	fi

	if [[ "$NEW_PATH" != "$LAST_PATH" ]]; then
		if hash wdiff 2>/dev/null; then
			tmpone=$(mktemp)
			tmptwo=$(mktemp)
			echo -ne "Path change:"
			echo $LAST_PATH | sed -e $'s/:/\\\t/g' >$tmpone
			echo $NEW_PATH | sed -e $'s/:/\\\t/g' >$tmptwo
			if hash colordiff 2>/dev/null; then
				wdiff --no-common $tmpone $tmptwo | colordiff | grep -v '===' | grep -v "^$"
			else
				wdiff --no-common $tmpone $tmptwo | grep -v '===' | grep -v "^$"
			fi
			#rm $tmpone $tmptwo
		fi
	fi

	export PATH=$NEW_PATH
	export LAST_PATH=$PATH
}

HISTSIZE=100000
HISTFILESIZE=200000

PROMPT_COMMAND=do_prompt_command

function cpstat() {

	tar -cf - "${@:1:$#-1}" |
		pv -s "$(gdu -cs -BK --apparent-size "${@:1:$#-1}" |
			tail -n 1 |
			cut -d "$(echo -e "\t")" -f 1)" |
		(
			cd "${@:$#}" || exit
			tar -xf -
		)

}

########## Start ngrok

if command -v ngrok &>/dev/null; then
	eval "$(ngrok completion)"
fi

########## End ngrok

########## Start Direnv

if command -v direnv >/dev/null; then
	eval "$(direnv hook bash)"
else
	NOTCONF="${NOTCONF}Direnv, "
fi

########## End Direnv

########## Start Virtualenv

export WORKON_HOME=$HOME/.virtualenvs

########## End Virtualenv

if [[ -e /usr/local/bin/virtualenvwrapper.sh ]]; then
	source /usr/local/bin/virtualenvwrapper.sh
elif [[ -e /usr/bin/virtualenvwrapper.sh ]]; then
	source /usr/bin/virtualenvwrapper.sh
elif [[ -e /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]]; then
	source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi


# If the user has a local bash profile, source it to allow them to override settings
if [[ -e ~/.bash_profile.local ]]; then
	source ~/.bash_profile.local
fi

# If laravel installer is available, add its shell completion
if [[ $(which laravel) ]]; then
	eval "$(laravel shell-completion bash)"
fi

if [[ $ARCH == "darwin-amd64" ]]; then
	LOCALE="en_GB.UTF-8"
else
	LOCALE="en_GB.utf8"
fi
LOCALELINE="$LOCALE UTF-8"
LOCALETEMP=$(mktemp)

locale -a >"$LOCALETEMP"
if grep -i "$LOCALE" "$LOCALETEMP" >/dev/null; then
	export LC_ALL=$LOCALE
	export LANG=$LOCALE
	export LANGUAGE=$LOCALE
else
	echo "Couldn't set Locale to $LOCALE"
	echo "sudo su -c \"echo $LOCALELINE >> /etc/locale.gen && locale-gen\""
fi

rm "$LOCALETEMP"

# export AWS_DEFAULT_REGION=eu-west-1

CLEAN_PATH=$(clean_path)
export CLEAN_PATH
LAST_PATH=$CLEAN_PATH
export LAST_PATH
