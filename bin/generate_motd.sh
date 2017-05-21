#!/bin/bash

sudo apt-get install -qqy figlet

if [[ ! -f /usr/share/figlet/weird.flf ]]
then
	sudo su -c "curl -s http://www.figlet.org/fonts/weird.flf > /usr/share/figlet/weird.flf"
fi

cat << ENDDOC | sudo tee /etc/motd

************** $(figlet `hostname -s` -f weird | sed "5s/$/.`hostname -d`/")
**************
`hostname -s` is owned and operated by Nicholas 'Aquarion' Avenell,
he can be reached at nicholas@aquarionics.com, or on +447909 547 990
ENDDOC


if [[ -f /etc/motd.local ]]
then
	sudo su -c "cat /etc/motd.local >> /etc/motd"
	cat /etc/motd.local
fi
