#!/bin/bash

##########################
# Install virtualbox 5.1.x and Vagrant 2.0.0
# on centos 6.x.
# Requires reboot + "/sbin/vboxconfig" to start vbox
##########################

[ $(id -u) != "0" ] && exec sudo "$0" "$@"
. /vagrant/config/system.cfg
. /vagrant/config/os.cfg

virtualboxVersion="5.1"
############# Requirements and update #############
wget --quiet http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
mv virtualbox.repo /etc/yum.repos.d/
yum update -y

yum install -y gcc make
yum install -y kernel-devel dkms VirtualBox-5.1
#yum install kernel-devel-$(uname -r )

# reboot
# /sbin/vboxconfig ## requires reboot
vagrantVersion="2.0.0"

usermod -a -G vboxusers "$USER_USR_NAME"

wget --quiet "https://releases.hashicorp.com/vagrant/$vagrantVersion/vagrant_$vagrantVersion_x86_64.rpm"
chmod u+x "vagrant_$vagrantVersion_x86_64.rpm"
rpm -i "vagrant_$vagrantVersion_x86_64.rpm"
rm "vagrant_$vagrantVersion_x86_64.rpm"

echo "VirtualBox and Vagrant have been installed, please reboot and run 'vboxconfig' as root to finish setup"
