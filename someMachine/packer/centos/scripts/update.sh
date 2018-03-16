#!/bin/sh -eux

PYTHON_VERSION="2.7.14"

### source https://wiki.centos.org/AdditionalResources/Repositories
yum -y --enablerepo=extras install epel-release 	# jemalloc is found in the extra packages enterprise linux-package
#yum install -y  centos-release-SCL 				# this if for the precompiled python 2.7 package
yum -y update;

# FK dependencies
yum install -y  nano ntp xfsprogs unzip tcpdump
yum install -y  httpd mod_ssl
yum install -y  ruby
yum install -y  clamav clamd





########## Python 2.7 install #####################
##make python 2.7 available as python27
#cat > /etc/profile.d/00-python-alias.sh << EOF
#source /opt/rh/python27/enable
#alias python27='python2.7'
#EOF
#echo "PROV==> Python alias set"

yum groupinstall -y 'development tools' #TODO, identify bloat!
yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel
yum install xz-libs

echo $PWD
wget --no-verbose "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz"
xz -d --quiet "Python-${PYTHON_VERSION}.tar.xz" # includes -d, no need for explicit delete
tar -xvf "Python-${PYTHON_VERSION}.tar"

cd Python-${PYTHON_VERSION}
./configure --prefix=/usr/local
make
make altinstall
export PATH="/usr/local/bin:$PATH"
cd ..

# Clean up
rm -f "~/Python-${PYTHON_VERSION}.tar"
rm -rf "~/Python-${PYTHON_VERSION}"

reboot;
sleep 60;
