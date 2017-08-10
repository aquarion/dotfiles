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
	TERRAFORMVERSION=0.9.2
else
	TERRAFORMVERSION=$1
fi
######################################################################################################### Terraform



if [[ -e ~/bin/terraform_$TERRAFORMVERSION ]]; then 
	if [[ "$(readlink ~/bin/terraform)" = "$(realpath ~/bin/terraform_$TERRAFORMVERSION)" ]]
	then
		echo "[Terraform]  Already running $TERRAFORMVERSION...          "
	else
		rm ~/bin/terraform; 
		ln -s ~/bin/terraform_$TERRAFORMVERSION ~/bin/terraform;
		echo "[Terraform]  Switched to version $TERRAFORMVERSION...          "
	fi
	exit 0
fi

if [[ -e ~/bin/terraform ]]; then 
	rm ~/bin/terraform; 
fi

echo -ne "\r[Terraform]  Downloading... $TERRAFORMVERSION"

echo -ne "\r[Terraform]  Downloading...          "
URL=https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_$ARCH.zip

wget $URL -O ~/scratch/terraform.zip -o ~/scratch/terraform.log || exit 5

echo -ne "\r[Terraform]  Extracting ...          "

TMPDIR=`mktemp -d`

unzip -o ~/scratch/terraform.zip -d $TMPDIR >> ~/scratch/terraform.log || exit 5

echo -ne "\r[Terraform]  Installing ...          "
mv $TMPDIR/terraform ~/bin/terraform_$TERRAFORMVERSION
ln -s ~/bin/terraform_$TERRAFORMVERSION ~/bin/terraform
	

# echo -ne "\r[Terraform]  Installing ...          "
# cp -v ~/scratch/hub-$ARCH-$HUBVERSION/bin/hub ~/bin/hub >> ~/scratch/terraform.log
echo -ne "\r[Terraform]  Cleaning up ...          "
rm -vrf ~/scratch/terraform.zip >> ~/scratch/terraform.log

~/bin/terraform version >> ~/scratch/terraform.log || exit 5

echo -e "\r[Terraform]  Installed $TERRAFORMVERSION          "
