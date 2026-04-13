function viewssl {
	SERVER="$1"
	if [ -z "$SERVER" ]; then
		echo "Usage: viewssl <server> [port]"
		return 1
	fi
	PORT="${2:-443}"
	echo | openssl s_client -showcerts -servername "$SERVER" -connect "$SERVER:$PORT" 2>/dev/null | openssl x509 -inform pem -noout -text
}

function c {
	PROJECTDIR=$(find ~/code/ -maxdepth 1 \( -type l -or -type d \) -iname \*$1\* -print -quit)
	if [ "$PROJECTDIR" ]; then
		echo -n "🔍 "
		pushd "$PROJECTDIR" || return
	else
		echo "😞"
	fi
}
function p {
	PROJECTDIR=$(find ~/code/ -maxdepth 2 \( -type l -or -type d \) -iname \*$1\* -print -quit)
	if [ "$PROJECTDIR" ]; then
		echo -n "🔍 "
		pushd "$PROJECTDIR" || return
	else
		echo "😞"
	fi
}

function h {
	PROJECTDIR=$(find -L ~/hosts/ -maxdepth 3 \( -type l -or -type d \) -iname \*$1\* -print -quit)
	if [ "$PROJECTDIR" ]; then
		echo -n "🔍 "
		pushd "$PROJECTDIR" || return
	else
		echo "😞"
	fi
}

function f {
	FOUND=$(find -L . -iname "*$1*" -not -path '*/.*' -print -quit)
	if [ "$FOUND" ]; then
		if [[ -d "$FOUND" ]]; then
			echo -n "🔍 📁"
			pushd "$FOUND" || return
		else
			echo -n "🔍 📃"
			pushd "$(dirname "$FOUND")" || return
		fi
	else
		echo "😞"
	fi
}

function switchenv {

	if [[ $PWD == *"production"* ]]; then
		THIS_ENV="production"
		NEW_ENV="staging"
	elif [[ $PWD == *"staging"* ]]; then
		THIS_ENV="staging"
		NEW_ENV="production"
	else
		echo "Not in a production or staging directory"
		return
	fi

	if [[ $1 ]]; then
		NEW_ENV=$1
	fi

	echo "Switching from $THIS_ENV to $NEW_ENV"
	# NEW_PWD=$(echo $PWD | sed "s/$THIS_ENV/$NEW_ENV/")
	NEW_PWD=${PWD//$THIS_ENV/$NEW_ENV}
	if [[ ! -d $NEW_PWD ]]; then
		echo "Directory $NEW_PWD does not exist"
		return
	else
		echo "Changing directory to $NEW_PWD"
		pushd "$NEW_PWD" || return
	fi

}

function cdd {
	pushd "$(dirname "$1")" || exit 5
}

function ccd {
	echo "you mean cdd?"
}

## Find a file or directory by searching up the directory tree
function find-up {
	if [ -z "$1" ]; then
		echo "[Find-Up] Usage: find-up [filename] [start-directory?]"
		return 1
	fi
	STARTDIR=${2:-$(pwd)}
	FILENAME=${1}
	DIR=$STARTDIR

	# if [[ $(hash grealpath 2>/dev/null) ]]; then
	# 	realpath() {
	# 		grealpath "$@"
	# 	}
	# fi

	while [[ "$DIR" != "/" ]]; do
		if [[ -e "$DIR/$FILENAME" ]]; then
			grealpath --relative-to="$STARTDIR" "$DIR"
			return 0
		fi
		DIR=$(dirname "$DIR")
	done

	return 1
}

## Function to generate random words from /usr/share/dict/words
function random_words {
	COUNT=${1:-2}
	WORDLIST="/usr/share/dict/words"
	# Shuffle the wordlist, take the first $COUNT words,
	# replace newlines with spaces, and remove trailing space
	shuf -n "$COUNT" "$WORDLIST" | tr '\n' ' ' | sed 's/ $//'
}


## Exec a command in the docker container

function dockexec {
	if [ -z "$1" ]; then
		echo "Usage: dockexec <container> [command]"
		return 1
	fi
	CONTAINER_NAME="$1"
	CONTAINER_ID=$(docker ps | grep "$CONTAINER_NAME" | cut -d" " -f1)
	CONTAINER_WD="/var/www/hosts${PWD##*hosts/"$CONTAINER_NAME"}"
	# docker exec -w "$CONTAINER_WD" "$CONTAINER_ID" vendor/bin/composer update
	shift
	COMMAND="${*:-bash}"
	# shellcheck disable=SC2086
	docker exec -it -w "$CONTAINER_WD" "$CONTAINER_ID" $COMMAND
}

miscwebexec() {
	dockexec "miscweb" "$@"
}