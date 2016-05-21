LAMP on Openstack
=================
This project will deploy under the help with Puppet Apache/PHP/MySQL on a Virtual Machine (VM) 
under the help of most of the standard Puppetlabs puppet modules. It's easy to adapt and to see, 
how it could work in an example: 
 

Features
--------

- install generated user account / ssh keys
- format and mount additional volumes
- set ntp client
- install MySQL Server with database and user
- install and configure Haproxy as SSL-Termination (needs >v1.5)
- provides ssl cert
- install apache with PHP and configured vhost
- install test web page
- provide monitoring with Nagios/Icinga (include pnp4nagios & SMS + Voice notification with Twilio service)
- builds a configuration package (deb/rpm) with fpm (using build.sh)


Requirements
------------
- Virtual Linux Machine (Ubuntu 14.04 trusty)
- 1 Floating IP
- 2 attached volumes (vdb,vdc)

- Puppet client (at least version 3)


Usage
-----

Install server with all defaults (otherwise edit site.pp before apply puppet)

as package:

    dpkg -i lamp-conf_01-master-1435250897-1_amd64.db
	cd /etc/puppet
	puppet apply manifests/site.pp

as git repo:

    rm -rf /etc/puppet
    git clone https://github.com/eumel8/lamp.git /etc/puppet
    cd /etc/puppet
    git submodule init
    git submodule update

Testing
-------

Developed for Ubuntu, works partly for OpenSUSE 13.2 (beside apparmor, ntp, Apache on 32bit systems)
Will be expand. Sometimes only small changes are necessary (e.g. service 'ntpd' instead 'ntp').

Example Ubuntu 12.04:
---------------------

Install new puppet version

    wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb; dpkg -i puppetlabs-release-precise.deb
    apt-get update
    apt-get -y install puppet

Add repo for haproxy-1.5

    apt-get -y install software-properties-common
    add-apt-repository -y ppa:vbernat/haproxy-1.5
    apt-get update

Example Ubuntu 14.04:
---------------------

Add repo for haproxy-1.5

    apt-get -y install software-properties-common
    add-apt-repository -y ppa:vbernat/haproxy-1.5
    apt-get update


Remarks Ubuntu 14.04:
---------------------

pnp4nagios is not available, you can disable the option in nagios.pp
puppet-mysql is not working correctly at the moment


Remarks OpenSuSE 13.2: (tested here)
------------------------------------

SSL certificate problem: unable to get local issuer certificate
if git clone https://github.com/eumel8/lamp.git
solution: 

    export GIT_SSL_NO_VERIFY=true

package monitoring-plugins-nrpe is missing
solution:

    zypper addrepo http://download.opensuse.org/repositories/server:monitoring/openSUSE_13.2/server:monitoring.repo
    zypper refresh

package apache2-mod_php53 is missing

solution: define it in side.pp

    class {'apache::mod::php':
      package_name  => 'apache2-mod_php5',
    }

installing mysql fails with:
Notice: /Stage[main]/Mysql::Server::Installdb/Exec[mysql_install_db]/returns: FATAL ERROR: Could not find /fill_help_tables.sql

solution: link shared files in the right directory

    file {'/usr/share/mysql':
      ensure  => 'link',
      target  => '/usr/share/mariadb',
      force   => true,
    }

apache won't start due the obselete modules in apache 2.4:
httpd2: Syntax error on line 41 of /etc/apache2/httpd.conf: Syntax error on line 1 of /etc/apache2/mods-enabled/authz_default.load: Cannot load /usr/lib64/apache2-prefork/mod_authz_default.so into server: /usr/lib64/apache2-prefork/mod_authz_default.so: cannot open shared object file: No such file or directory

solution: declare apache_version

    class {'apache':
      mpm_module       => 'prefork',
      apache_version   => '2.4',
    }

httpd2: Syntax error on line 185 of /etc/apache2/httpd.conf: Could not open configuration file /etc/apache2/sysconfig.d/include.conf: No such file or directory

solution: create missing config file:

    file {'/etc/apache2/sysconfig.d/include.conf':
      ensure => present,
    }

 Failed at step NAMESPACE spawning /usr/sbin/start_apache2: Permission denied

solution

set in /etc/systemd/system/httpd.service

    PrivateTmp=false
    NoNewPrivileges=yes

and make

    systemctl daemon-reload


Syntax error on line 38 of /etc/apache2/httpd.conf: Syntax error on line 1 of /etc/apache2/mods-enabled/access_compat.load: module access_compat_module is built-in and can't be loaded


solution

in modules/apache/manifests/default_mods.pp comment out

     ::apache::mod { 'access_compat': }

load /usr/lib64/apache2-prefork/libphp5.so into server: /usr/lib64/apache2-prefork/libphp5.so: cannot open shared object file: No such file or directory

solution

dunno, there is no libphp5.so in OpenSuSE 13.2. Use another apache module like https://github.com/eumel8/puppet-apache

Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_markup`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_markup`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait

WARNING
-------

In this project are generated keys for ssh and ssl. Don't use this on your own site! There are ways described
in the manifest how to generate new keys.

