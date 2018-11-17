#/usr/bin/bash -x

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

if [[ "$(uname)" == "Darwin" ]]; then
	ARCH="darwin-amd64";    
elif [[ "`uname -m`" == "x86_64" ]]; 
then 
	ARCH="linux-amd64";
elif [[ "`uname -m`" == "i686" ]]; 
then 
	ARCH="linux-386";
elif [[ "`uname -m`" == "armv7l" ]]; 
then 
	ARCH="linux-arm";
fi

if [[ -z "$ARCH" ]];
then
	echo "No plaformed $(uname -m)"
	exit 5
fi


######################################################################################################### Terraform

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi


HUBVERSION=$1


if [[ -z "$1" ]];
then
	echo "Hub version not supplied"
	exit 5
fi

echo "Installing git/hub";
if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

# echo https://github.com/github/hub/releases/download/v$HUBVERSION/hub-$ARCH-$HUBVERSION.tgz

if hash wget 2>/dev/null; then
	wget https://github.com/github/hub/releases/download/v$HUBVERSION/hub-$ARCH-$HUBVERSION.tgz -O ~/scratch/hub-$ARCH-$HUBVERSION.tgz -o ~/scratch/hub-$ARCH-$HUBVERSION.log
elif hash curl 2>/dev/null; then
	curl -L https://github.com/github/hub/releases/download/v$HUBVERSION/hub-$ARCH-$HUBVERSION.tgz > ~/scratch/hub-$ARCH-$HUBVERSION.tgz 2> ~/scratch/hub-$ARCH-$HUBVERSION.log
else
	echo "No downloader program found. Install wget or curl"
	exit 5
fi


if [[ $? > 0 ]];
then
	echo "Download failed"
	exit 5
fi

tar zxf ~/scratch/hub-$ARCH-$HUBVERSION.tgz  -C ~/scratch/ >> ~/scratch/hub-$ARCH-$HUBVERSION.log
cp ~/scratch/hub-$ARCH-$HUBVERSION/bin/hub ~/bin/hub >> ~/scratch/hub-$ARCH-$HUBVERSION.log
rm -rf ~/scratch/hub-$ARCH-$HUBVERSION.tgz ~/scratch/hub-$ARCH-$HUBVERSION >> ~/scratch/hub-$ARCH-$HUBVERSION.log

git version >> ~/scratch/hub-$ARCH-$HUBVERSION.log

alias git=hub

git version >> ~/scratch/hub-$ARCH-$HUBVERSION.log
