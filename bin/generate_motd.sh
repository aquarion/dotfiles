#!/bin/bash

if ! hash figlet >/dev/null; then
	echo "Installing figlet"
	sudo apt-get install -qqy figlet
fi

#if [[ ! -f /usr/share/figlet/weird.flf ]]
#then
#	sudo su -c "curl -s http://www.figlet.org/fonts/weird.flf > /usr/share/figlet/weird.flf"
#fi

FILE=/etc/motd

if hash update-motd >/dev/null; then
	FILE=/etc/motd
	UPDATE_MOTD=0
else
	FILE=/etc/update-motd.d/00-gkhs
	UPDATE_MOTD=1
fi

cat <<ENDDOC | sudo tee "$FILE"

**************
$(figlet "$(hostname -s)" | sed "5s/$/.$(hostname -d)/")
**************
$(hostname -s) is owned and operated by Nicholas 'Aquarion' Avenell,
he can be reached at nicholas@aquarionics.com, or on +447909 547 990
ENDDOC

if [[ -f /etc/motd.local && $UPDATE_MOTD == 0 ]]; then
	sudo su -c "cat /etc/motd.local >> /etc/motd"
	cat /etc/motd.local
fi

if [[ $UPDATE_MOTD ]]; then
	sudo update-motd
fi
