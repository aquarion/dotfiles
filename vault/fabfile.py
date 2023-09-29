from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm

env.user = "aquarion"

env.hosts = ['cenote.water.gkhs.net', 'archipelago.water.gkhs.net', 'millpond.treacle.mine.nu']

def upgrade():
    sudo("apt-get update -qqy")
    sudo("apt-get upgrade -qy")
    sudo("apt-get autoremove -q")

def distupgrade():
    sudo("apt-get dist-upgrade -qy")
    sudo("apt-get autoremove -q")