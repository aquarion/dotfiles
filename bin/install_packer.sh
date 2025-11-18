#!/usr/bin/bash -x

if [[ ! -d ~/scratch ]]; then mkdir ~/scratch; fi
if [[ ! -d ~/bin ]]; then mkdir ~/bin; fi

if [ "$(uname)" == "Darwin" ]; then
	ARCH="darwin_amd64"
elif [[ $(uname -i) = "x86_64" ]]; then
	ARCH="linux_amd64"
elif [[ $(uname -i) = "i686" ]]; then
	ARCH="linux_386"
fi

if [[ -z $1 ]]; then
	PACKERVERSION=1.0.4
else
	PACKERVERSION=$1
fi

######################################################################################################### Packer

echo -ne "[Packer     Clearing old versions\r"
if [[ -e "$HOME/bin/packer" ]]; then rm "$HOME/bin/packer"; fi
if compgen -G "$HOME/bin/packer-*" >/dev/null; then
	rm "$HOME/bin/packer-"*
fi

echo -n "\r[Packer]     Downloading... $PACKERVERSION"

echo -ne "\r[Packer]     Downloading...          "
URL=https://releases.hashicorp.com/packer/${PACKERVERSION}/packer_${PACKERVERSION}_${ARCH}.zip || exit 5

wget "$URL" -O "$HOME/scratch/packer.zip" -o "$HOME/scratch/packer.log" || exit 5

echo -ne "\r[Packer     Extracting ...          "
unzip -o "$HOME/scratch/packer.zip" -d "$HOME/bin/" >>"$HOME/scratch/packer.log" || exit 5
# echo -ne "\r[packer]  Installing ...          "
# cp -v "$HOME/scratch/hub-$ARCH-$HUBVERSION/bin/hub" "$HOME/bin/hub" >> "$HOME/scratch/packer.log"
echo -ne "\r[Packer]     Cleaning up ...          "
rm -vrf ~/scratch/packer.zip >>~/scratch/packer.log || exit 5

~/bin/packer version >>~/scratch/packer.log || exit 5

echo -e "\r[Packer]     Installed $PACKERVERSION                "
