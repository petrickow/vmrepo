#!/bin/bash -eux

###################
# Users and groups
# OS memory parameters
# firewall
###################

#[ $(id -u) != "0" ] && exec sudo "$0" "$@"
. /vagrant/config/os.cfg

hostname ${HOSTNAME}.${DOMAINNAME}
domainname ${DOMAINNAME}

sed -i "s/HOSTNAME.*/HOSTNAME=$(hostname)/" /etc/sysconfig/network

# 4.6 ###### Users and groups #############
userdel shutdown
userdel halt
userdel games
userdel operator
userdel ftp
userdel gopher

# create group for users and apps
groupadd "$USER_GROUP_NAME"
groupadd "$APPS_GROUP_NAME"

# create standard user
echo "Adding $USER_USR_NAME"
useradd "$USER_USR_NAME" -m -G "$USER_GROUP_NAME" -p "$USER_PASSWORD"

#create admin user
echo "Adding $ADM_USR_NAME"
useradd "$ADM_USR_NAME" -p "$USER_PASSWORD" # this creates group "efieldadm"
usermod -a -G "$APPS_GROUP_NAME" "$ADM_USR_NAME"

echo "Adding $WEB_USER_NAME"
useradd $WEB_USER_NAME
usermod -a -G "$APPS_GROUP_NAME" $WEB_USER_NAME

# create application specific users
for user in "${APP_USER_LIST[@]}"
do
    useradd -g "$APPS_GROUP_NAME" -r "$user"
done

########### security limits and priority ############
echo "@$USER_USR_NAME hard priority 10" >> /etc/security/limits.conf
echo "%$ADM_USR_NAME ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR="tee -a" visudo
