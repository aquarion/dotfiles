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

TERRAFORMVERSION=0.9.2

######################################################################################################### Terraform

echo -ne "[Terraform]  Clearing old versions\r"
if [[ -e ~/bin/terraform ]]; then rm  ~/bin/terraform; 	fi
if stat -t ~/bin/terraform-* >/dev/null 2>&1; then
    rm  ~/bin/terraform-*;
fi

echo -ne "\r[Terraform]  Downloading... $TERRAFORMVERSION"

echo -ne "\r[Terraform]  Downloading...          "
URL=https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_$ARCH.zip

wget $URL -O ~/scratch/terraform.zip -o ~/scratch/terraform.log || exit 5

echo -ne "\r[Terraform]  Extracting ...          "
unzip -o ~/scratch/terraform.zip -d ~/bin/ >> ~/scratch/terraform.log || exit 5
# echo -ne "\r[Terraform]  Installing ...          "
# cp -v ~/scratch/hub-$ARCH-$HUBVERSION/bin/hub ~/bin/hub >> ~/scratch/terraform.log
echo -ne "\r[Terraform]  Cleaning up ...          "
rm -vrf ~/scratch/terraform.zip >> ~/scratch/terraform.log

~/bin/terraform version >> ~/scratch/terraform.log || exit 5

echo -e "\r[Terraform]  Installed $TERRAFORMVERSION          "
