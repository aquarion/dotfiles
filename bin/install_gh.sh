#/usr/bin/bash -x

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

if [[ "$(uname)" == "Darwin" ]]; then
    if [[ `uname -m` == 'arm64' ]]; then
        ARCH="macOS_amd64";
    else
        ARCH="macOS_amd64";
    fi
elif [[ "`uname -m`" == "x86_64" ]];
then
	ARCH="linux_amd64";
elif [[ "`uname -m`" == "i686" ]];
then
	ARCH="linux_386";
elif [[ "`uname -m`" == "armv7l" ]];
then
	ARCH="linux_armv6";
fi

if [[ -z "$ARCH" ]];
then
	echo "No plaformed $(uname -m)"
	exit 5
fi

# https://github.com/cli/cli/releases/download/v2.2.0/gh_2.2.0_linux_386.deb
# https://github.com/cli/cli/releases/download/v2.2.0/gh_linux_amd64.tar.gz

######################################################################################################### Terraform

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi


VERSION=$1


if hash jq 2>/dev/null; then
	VERSION=`curl  -H "Accept: application/vnd.github+json" -s https://api.github.com/repos/cli/cli/releases | jq -r .[0].tag_name`
	VERSION=${VERSION##*v}
	echo "Latest version of Github CLI is $VERSION"

	URL=`curl -H "Accept: application/vnd.github+json" -s https://api.github.com/repos/cli/cli/releases | jq -r ".[0].assets.[] | select(.name | contains(\"${ARCH}\")).browser_download_url"`
else
	echo "jq not found. Please install jq"
	exit 5
fi

GHDIR=gh_${VERSION}_${ARCH}

echo "Installing github CLI $VERSION";
if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi


if hash curl 2>/dev/null; then
	echo curl -vL "$URL" > ~/scratch/$GHDIR.log
	curl -vv -L "$URL" > ~/scratch/$GHDIR.tgz #2>> ~/scratch/$GHDIR.log
	DLXIT=$?
elif hash wget 2>/dev/null; then
	wget $URL -O ~/scratch/$GHDIR.tgz -o ~/scratch/$GHDIR.log
	DLXIT=$?
else
	echo "No downloader program found. Install wget or curl"
	exit 5
fi

echo $URL;
echo $GHDIR;


if [[ $DLXIT > 0 ]];
then
	echo "Download failed: $URL"
	exit 5
fi

tar vxf ~/scratch/$GHDIR.tgz  -C ~/scratch/ >> ~/scratch/$GHDIR.log
cp ~/scratch/$GHDIR/bin/gh ~/bin/ >> ~/scratch/$GHDIR.log
rm -vrf ~/scratch/$GHDIR.tgz ~/scratch/$GHDIR >> ~/scratch/$GHDIR.log

