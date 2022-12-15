

function viewssl {
	echo | openssl s_client -showcerts -servername $1 -connect $1:443 2>/dev/null | openssl x509 -inform pem -noout -text
}
function c {
    PROJECTDIR=$(find ~/code/ -maxdepth 1 \( -type l -or -type d \) -iname \*$1\* -print -quit);
    if [ $PROJECTDIR ];
    then
        echo -n "🔍 "
        pushd $PROJECTDIR
    else
        echo "😞"
    fi
}
function p {
    PROJECTDIR=$(find ~/code/ -maxdepth 2 \( -type l -or -type d \) -iname \*$1\* -print -quit);
    if [ $PROJECTDIR ];
    then
        echo -n "🔍 "
        pushd $PROJECTDIR
    else
        echo "😞"
    fi
}

function h {
    PROJECTDIR=$(find -L ~/hosts/ -maxdepth 3 \( -type l -or -type d \) -iname \*$1\* -print -quit);
    if [ $PROJECTDIR ];
    then
        echo -n "🔍 "
        pushd $PROJECTDIR
    else
        echo "😞"
    fi
}

function f {
    FOUND=$(find -L . -type f -iname \*$1\* -print -quit);
    if [ $FOUND ];
    then
        echo -n "🔍 "
        pushd `dirname $FOUND`
    else
        echo "😞"
    fi
}

function tower {
    if [[ $1 ]];
    then
        pushd `dirname $1`
    fi
    GITDIR=$(git rev-parse --show-toplevel)
    GITDIRFAIL=$?

    if [[ $GITDIRFAIL -gt 0 ]]
    then
        echo "$GITDIR Not a git directory"
        return
    fi


    gittower $GITDIR
}

function dailyphoto_convert {
    echo "> Resize $1 to become $2"
    convert "$1" -resize 2000x "$2"
    echo "> Squish $2 (This will take a while)"
    guetzli "$2" "$2"
    echo "Done!"

}




# If you use #'s for defer and start dates, you'll need to escape the #'s or
# quote the whole string.

function task () {
  if [[ $# -eq 0 ]]; then
        echo "Usage: some task! @context ::project #defer #due //note"
    #oapen -a "OmniFocus"
  elif hash osascript 2>/dev/null; then
    osascript <<EOT
    tell application "OmniFocus"
      parse tasks into default document with transport text "$@"
    end tell
EOT
  elif [[ -d ~/Dropbox/File\ Transfer ]]; then
    echo "Send to Dropbox"
    if [[ ! -d ~/Dropbox/File\ Transfer/Omnifocus ]]; then
        mkdir ~/Dropbox/File\ Transfer/Omnifocus
    fi
    echo "$@" >> ~/Dropbox/File\ Transfer/Omnifocus/`hostname`-tasks.txt
  else
    echo "Need either to be on OSX or have Dropbox available"
  fi
}