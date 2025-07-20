function viewssl {
    PORT="${2:-443}"
    echo | openssl s_client -showcerts -servername $1 -connect $1:$PORT 2>/dev/null | openssl x509 -inform pem -noout -text
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
