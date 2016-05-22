#!/bin/sh
#
# install LAMP stack in lXD container

# add extra repo for monitoring packages
zypper addrepo  http://download.opensuse.org/repositories/server:monitoring/openSUSE_13.2/server:monitoring.repo
zypper --gpg-auto-import-keys refresh

# install puppet and git
zypper --non-interactive --no-gpg-checks --quiet install  puppet vim git

# copy git repo
rm -rf /etc/puppet/
export GIT_SSL_NO_VERIFY=true
git clone -b opensuse-13.2 https://github.com/eumel8/lamp.git /etc/puppet
cd /etc/puppet
git submodule update --init

# install lamp
puppet apply /etc/puppet/manifests/site.pp

# hotfixes against systemd
sed -i 's/PrivateTmp=true/PrivateTmp=false\nNoNewPrivileges=yes/' /etc/systemd/system/httpd.service
sed -i 's/PrivateTmp=true/PrivateTmp=false\nNoNewPrivileges=yes/' /etc/systemd/system/multi-user.target.wants/apache2.service
systemctl daemon-reload
systemctl restart httpd.service

echo "done"

