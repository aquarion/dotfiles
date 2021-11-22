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
GHDIR=gh_${VERSION}_${ARCH}


if [[ -z "$1" ]];
then
	echo "Github CLI version not supplied"
	exit 5
fi

echo "Installing github CLI $VERSION";
if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

URL=https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_${ARCH}.tar.gz
UNZIPDIR==https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_${ARCH}.tar.gz

if hash curl 2>/dev/null; then
	curl -L $URL > ~/scratch/$GHDIR.tgz 2> ~/scratch/$GHDIR.log
elif hash wget 2>/dev/null; then
	wget $URL -O ~/scratch/$GHDIR.tgz -o ~/scratch/$GHDIR.log
else
	echo "No downloader program found. Install wget or curl"
	exit 5
fi


if [[ $? > 0 ]];
then
	echo "Download failed: $URL"
	exit 5
fi

tar zxf ~/scratch/$GHDIR.tgz  -C ~/scratch/ >> ~/scratch/$GHDIR.log
cp ~/scratch/$GHDIR/bin/gh ~/bin/ >> ~/scratch/$GHDIR.log
rm -rf ~/scratch/$GHDIR.tgz ~/scratch/$GHDIR >> ~/scratch/$GHDIR.log

