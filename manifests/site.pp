node default {

# configuration

  $lampuser     = 'isv'
  $lamppassword = 'do5KaeLau1iex1fo'
  $lamprootpw   = 'phohnac4muYoov1e'

# preparing disks

  file { '/data':
    ensure => 'directory',
  }

  file { '/db':
    ensure => 'directory',
  }

  if $::blockdevices =~ /vdb/ {
    mkfs::device {'/dev/vdb':
      dest    => '/data/',
      require => File['/data'],
    }
  }

  if $::blockdevices =~ /vdc/ {
    mkfs::device {'/dev/vdc':
      dest    => '/db/',
      require => File['/db'],
    }
  }

# preparing accounts
# ssh-keygen -t rsa -f modules/lamp/files/root.key
# ssh-keygen -t rsa -f modules/lamp/files/cloud.key

  include lamp::user

# preparing ntp

  class { '::ntp':
    servers => [ '0.de.pool.ntp.org', '1.de.pool.ntp.org' ],
  }

# preparing database


  if $::osfamily =~ /Debian/  {
    apparmor::profile{'usr.sbin.mysqld':
      ensure => enforced,
      source => 'puppet:///modules/lamp/usr.sbin.mysqld',
    }
  } 

  file {'/usr/share/mysql':
    ensure  => 'link',
    target  => '/usr/share/mariadb',
    force   => true,
  }

  file {'/var/lib/mysql':
    ensure => symlink,
    target => '/db/mysql',
  } ->

  file {'/db/mysql':
    ensure  => 'directory',
  }

  $override_options = {
    'mysqld' => {
      'datadir' => '/db/mysql',
    }
  }

  class { '::mysql::server':
    root_password           => "${lamprootpw}",
    remove_default_accounts => true,
    override_options        => $override_options,
    require                 => File['/db/mysql'],
  }

  mysql::db { "${lampuser}":
    user     => $lampuser,
    password => $lamppassword,
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  }

# preparing haproxy
# openssl req   -x509 -nodes -days 365   -newkey rsa:1024 -keyout mycert.pem -out modules/lamp/files/cloud.pem

  class { 'haproxy': }

  file { '/etc/haproxy/cloud.pem':
    ensure  => 'file',
    source  => 'puppet:///modules/lamp/cloud.pem',
    require => Package['haproxy'],
  }


  haproxy::listen { 'puppet00':
    mode    => 'tcp',
    options => {
      'option'  => [
        'tcplog',
        'httpchk',
      ],
      'balance' => 'roundrobin',
    },
    bind    => {
      '0.0.0.0:443' => ['ssl', 'crt', '/etc/haproxy/cloud.pem'],
    },
  }

  haproxy::balancermember { 'master01':
    listening_service => 'puppet00',
    server_names      => "${::hostname}",
    ipaddresses       => '127.0.0.1',
    ports             => '80',
    options           => 'check',
  }


# preparing webserver

  package {'php5-mysql':
    ensure => installed,
  }

  apache::vhost { 'lamp.ref.app.cloud':
    port    => '80',
    docroot => '/data/www/',
  }


# preparing application
#

  file { '/data/www/index.php':
    ensure  => 'present',
    content => template('lamp/index.erb'),
  }

# preparing monitoring
  import 'nagios.pp'
  include monitor
  class {'nagios::nrpe':
    nrpe_allowed_hosts   => ['127.0.0.1',"${::ipaddress}"],
    timeserver           => '01.de.pool.ntp.org',
    nrpe_conf_overwrite  => 0,
    monitor_puppet_agent => 1,
  }
}
