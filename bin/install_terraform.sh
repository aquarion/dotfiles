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
	print "Supply a terraform version. usage: $0 [VERSION]"
	exit 5
else
	TERRAFORMVERSION=$1
fi
######################################################################################################### Terraform

if [[ -e "$HOME/bin/terraform_$TERRAFORMVERSION" ]]; then
	if [[ "$(readlink "$HOME/bin/terraform")" = "$(realpath "$HOME/bin/terraform_$TERRAFORMVERSION")" ]]; then
		echo "[Terraform]  Already running $TERRAFORMVERSION...          "
	else
		rm "$HOME/bin/terraform"
		ln -s "$HOME/bin/terraform_$TERRAFORMVERSION" "$HOME/bin/terraform"
		echo "[Terraform]  Switched to version $TERRAFORMVERSION...          "
	fi
	exit 0
fi

echo -ne "\r[Terraform]  Downloading... $TERRAFORMVERSION"

echo -ne "\r[Terraform]  Downloading...          "
URL=https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_$ARCH.zip

wget "$URL" -O "$HOME/scratch/terraform.zip" -o "$HOME/scratch/terraform.log" || exit 5

echo -ne "\r[Terraform]  Extracting ...          "

TMPDIR=$(mktemp -d)

unzip -o "$HOME/scratch/terraform.zip" -d "$TMPDIR" >>"$HOME/scratch/terraform.log" || exit 5

echo -ne "\r[Terraform]  Installing ...          "
mv "$TMPDIR/terraform" "$HOME/bin/terraform_$TERRAFORMVERSION"

if [[ -e "$HOME/bin/terraform" ]]; then
	rm "$HOME/bin/terraform"
fi

ln -s "$HOME/bin/terraform_$TERRAFORMVERSION" "$HOME/bin/terraform"
# echo -ne "\r[Terraform]  Installing ...          "
# cp -v "$HOME/scratch/hub-$ARCH-$HUBVERSION/bin/hub" "$HOME/bin/hub" >> "$HOME/scratch/terraform.log"
echo -ne "\r[Terraform]  Cleaning up ...          "
rm -vrf "$HOME/scratch/terraform.zip" >>"$HOME/scratch/terraform.log" || exit 5
rm -rf "$TMPDIR"
"$HOME/bin/terraform" version >>"$HOME/scratch/terraform.log" || exit 5

echo -e "\r[Terraform]  Installed $TERRAFORMVERSION          "
