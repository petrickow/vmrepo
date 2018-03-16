#!/bin/bash -eux

##########################
# Hardening accordig to FMS manual "server setup and 
# system hardening"
##########################

[ $(id -u) != "0" ] && exec sudo "$0" "$@" # root access
. /vagrant/config/hardening.cfg # import config as enviroment variables

echo "PROV==> set security profile script, timeout and passwd algo"
# 4.5 #### Login, idle timouts and pwd policy #############
SECURITY_SCRIPT_LOC="/etc/profile.d/security.sh"

echo "PASS_MIN_LEN=${PASS_MIN_LEN}" >> /etc/login.defs
echo "LOGIN_TIMEOUT=${LOGIN_TIMEOUT}" >> /etc/login.defs

authconfig --passalgo=sha512 --update 

if [ -f ${SECURITY_SCRIPT_LOC} ]; then
    chmod +x ${SECURITY_SCRIPT_LOC}
else
	touch ${SECURITY_SCRIPT_LOC}
	chmod +x ${SECURITY_SCRIPT_LOC}
    echo "$SECURITY_SCRIPT" > ${SECURITY_SCRIPT_LOC}
fi

echo "PROV==> setting banner"
# 4.6.5 # Banner #############
cat > /etc/issue << EOF
#################################################################
#          Welcome to some company some product!                #
# All connections are monitored and recorded, disconnect        #
# IMMEDIATELY if you are not an authorized user!                #
#                                                               #
# Evidence of unauthorized use collected during monitoring may  #
# be used for administrative, criminal or other adverse action. #
# Use of this system constitutes consent to monitoring for      #
# these purposes.                                               #
#################################################################
EOF

cp /etc/issue /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config


echo "PROV==> setting SSH config"
# 4.7 ##### SSH configuration #############
# TODO, what if the params are removed from the template? Check return values
sed -i 's/.*ClientAliveInterval\s[0-9]*/ClientAliveInterval 900/g' /etc/ssh/sshd_config ## TODO, parameterize?
sed -i 's/.*ClientAliveCountMax\s[0-9]*/ClientAliveCountMax 0/g' /etc/ssh/sshd_config

sed -i 's/.*PermitRootLogin.*yes/PermitRootLogin no/g' /etc/ssh/sshd_config

sed -i 's/.*AllowUsers.*/AllowUsers efield efieldadm/g' /etc/ssh/sshd_config
sed -i 's/.*PermitEmptyPasswords.*yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config


echo "PROV==> kernel tuning, selinux and firewall"
######### Kernel tuning #############
# overwrite
cat > /etc/sysctl.conf << EOF
"$SYSCTL_CONFIG"
EOF


########### SELinux ####################
sed -i 's/\(SELINUX\=\).*/\1enforcing/g' /etc/selinux/config

########### firewall #######################
# Flush all current rules from iptables
iptables -F

# Allow connections on tcp port 80, 8082, 443 (Apache2, OpenAM and FieldKeeper).
iptables -A INPUT -p tcp -m multiport --dports 80,8082,443 -j ACCEPT

# Allow VECTUS slow-stream connections on tcp port 7500 and 7501
iptables -A INPUT -p tcp -m multiport --dports 7500,7501 -j ACCEPT

# Allow VECTUS high-speed streaming connections on tcp port 10000 and 10001
iptables -A INPUT -p tcp -m multiport --dports 10000,10001 -j ACCEPT

# Allow connections directly to STORM UI (does not work well behind proxy)
iptables -A INPUT -p tcp --dport 8088 -j ACCEPT

# Allow SSH connections on tcp port 22, limit to 3 attempts per minute
iptables -A INPUT -p tcp --dport 22 --syn -m limit --limit 1/m --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 --syn -j ACCEPT

#Allow incoming and outgoing ping request
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT

# Set default policies for INPUT, FORWARD and OUTPUT chains
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Set access for localhost and “local LANs”
# When using vagrant eth0 is the mandatory nat device, eth1 public, eth2-4 local
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth2 -j ACCEPT
iptables -A INPUT -i eth3 -j ACCEPT
iptables -A INPUT -i eth4 -j ACCEPT

# Accept packets belonging to established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept

# Save settings
/sbin/service iptables save

# List rules
iptables -L -v


