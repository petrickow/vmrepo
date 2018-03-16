#!/bin/bash -eux

. /vagrant/config/system.cfg
. /vagrant/config/os.cfg # for domainname

############# Proxy #############


############# Software #############
yum update  -y
echo "PROV==> Yum update complete"

########### ntp time setup #################


########## anti virus ######################
### requires clam to be preinstalledd
/etc/init.d/clamd on
chkconfig clamd on
/etc/init.d/clamd start

chmod -R 777 /var/log/clamav/
chmod -R 777 /var/lib/clamav/

cat > /opt/manual_clamscan << EOF
$SCAN_SCRIPT
EOF

chmod +x /opt/manual_clamscan
