#shellcheck shell=bash
# bash_profile.local.cyclone - Local customizations for bash profile
#source $MYDIR/ssh/bitwarden-agent-bridge.bash
#source $MYDIR/bash/lib/kubernetes.lib.bash
source $MYDIR/bash/lib/linuxbrew.lib.bash
export PATH=/home/linuxbrew/.linuxbrew/share/google-cloud-sdk/bin:"$PATH"

# bash_profile.bash's own direnv hook check runs before this file is sourced,
# so on Linuxbrew machines direnv isn't on PATH yet and that check silently
# no-ops. Install the hook here instead, now that linuxbrew.lib.bash has put
# direnv on PATH.
if command -v direnv >/dev/null; then
	eval "$(direnv hook bash)"
fi
