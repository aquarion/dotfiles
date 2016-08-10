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

TERRAFORMVERSION=0.7.0
PACKERVERSION=0.10.1

######################################################################################################### Terraform

echo -n "[Terraform]  Clearing old versions"
if [[ -e ~/bin/terraform ]]; then rm  ~/bin/terraform; 	fi
if stat -t ~/bin/terraform-* >/dev/null 2>&1; then
    rm  ~/bin/terraform-*;
fi

echo -n "[Terraform]  Downloading... $TERRAFORMVERSION"

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

######################################################################################################### Packer


echo -n "[Packer     Clearing old versions"
if [[ -e ~/bin/packer ]]; then rm  ~/bin/packer; 	fi
if compgen -G "~/bin/packer-*" > /dev/null; then
    rm  ~/bin/packer-*;
fi

echo -n "[Packer]     Downloading... $PACKERVERSION"

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
