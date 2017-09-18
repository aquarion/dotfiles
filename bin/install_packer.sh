#/usr/bin/bash -x

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; 	fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; 	fi

if [ "$(uname)" == "Darwin" ]; then
	ARCH="darwin_amd64";    
elif [[ `uname -i` -eq "x86_64" ]]; 
then 
	ARCH="linux_amd64";
elif [[ `uname -i` -eq "i686" ]]; 
then 
	ARCH="linux_386";
fi

if [[ -z $1 ]]
then
	PACKERVERSION=1.0.4
else
	PACKERVERSION=$1
fi

######################################################################################################### Packer


echo -ne "[Packer     Clearing old versions\r"
if [[ -e ~/bin/packer ]]; then rm  ~/bin/packer; 	fi
if compgen -G "~/bin/packer-*" > /dev/null; then
    rm  ~/bin/packer-*;
fi

echo -n "\r[Packer]     Downloading... $PACKERVERSION"

echo -ne "\r[Packer]     Downloading...          "
URL=https://releases.hashicorp.com/packer/${PACKERVERSION}/packer_${PACKERVERSION}_${ARCH}.zip || exit 5

wget $URL -O ~/scratch/packer.zip -o ~/scratch/packer.log || exit 5

echo -ne "\r[Packer     Extracting ...          "
unzip -o ~/scratch/packer.zip -d ~/bin/ >> ~/scratch/packer.log || exit 5
# echo -ne "\r[packer]  Installing ...          "
# cp -v ~/scratch/hub-$ARCH-$HUBVERSION/bin/hub ~/bin/hub >> ~/scratch/packer.log
echo -ne "\r[Packer]     Cleaning up ...          "
rm -vrf ~/scratch/packer.zip >> ~/scratch/packer.log || exit 5

~/bin/packer version >> ~/scratch/packer.log || exit 5

echo -e "\r[Packer]     Installed $PACKERVERSION                "
