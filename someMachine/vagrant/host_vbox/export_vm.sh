#!/bin/bash
### VirtualBox export

. ../targetConfig/efieldnode4 # TODO decouple this

echo "Make sure the machine is standing still"
vboxmanage controlvm "$VM_NAME" poweroff

echo "Remove audio hw"
vboxmanage modifyvm "$VM_NAME" --audio none

echo "Remove the vagrant shared folder"
vboxmanage sharedfolder remove "$VM_NAME" --name "vagrant"

echo "Create OVA file"
vboxmanage export "$VM_NAME" -o "$OVA_FNAME"
