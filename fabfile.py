from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm

env.user = "aquarion"

env.hosts = ['cenote.water.gkhs.net', 'atoll.water.gkhs.net', "ubuntu@mechan.istic.net"]

def upgrade():
    sudo("apt-get update -qqy")
    sudo("apt-get upgrade -qy")

def distupgrade():
    sudo("apt-get dist-upgrade -qy")