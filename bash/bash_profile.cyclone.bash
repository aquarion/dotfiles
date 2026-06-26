#shellcheck shell=bash
# bash_profile.local.cyclone - Local customizations for bash profile
#source $MYDIR/ssh/bitwarden-agent-bridge.bash
source $MYDIR/bash/lib/kubenates.lib.sh

alias k=kubectl

if [[ -d /home/linuxbrew/.linuxbrew ]];
then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
