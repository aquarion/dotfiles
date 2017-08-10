#/usr/bin/bash -x

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

if [ "$(uname)" == "Darwin" ]; then
	ARCH="darwin-amd64";    
elif [[ `uname -i` -eq "x86_64" ]]; 
then 
	ARCH="linux-amd64";
elif [[ `uname -i` -eq "i686" ]]; 
then 
	ARCH="linux-386";
fi

######################################################################################################### Terraform

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi


HUBVERSION=$1
echo "Installing git/hub";
if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

wget https://github.com/github/hub/releases/download/v$HUBVERSION/hub-$ARCH-$HUBVERSION.tgz -O ~/scratch/hub-$ARCH-$HUBVERSION.tgz -o ~/scratch/hub-$ARCH-$HUBVERSION.log
tar zxf ~/scratch/hub-$ARCH-$HUBVERSION.tgz  -C ~/scratch/ >> ~/scratch/hub-$ARCH-$HUBVERSION.log
cp ~/scratch/hub-$ARCH-$HUBVERSION/bin/hub ~/bin/hub >> ~/scratch/hub-$ARCH-$HUBVERSION.log
rm -rf ~/scratch/hub-$ARCH-$HUBVERSION.tgz ~/scratch/hub-$ARCH-$HUBVERSION >> ~/scratch/hub-$ARCH-$HUBVERSION.log

git version >> ~/scratch/hub-$ARCH-$HUBVERSION.log

alias git=hub

git version >> ~/scratch/hub-$ARCH-$HUBVERSION.log
