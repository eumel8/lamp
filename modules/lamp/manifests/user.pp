class lamp::user {

  user { 'isv':
    ensure     => present,
    uid        => '2000',
    gid        => '2000',
    managehome => true,
  }

  group { "isv":
    gid        => '2000',
  }

  file { '/home/isv/.ssh':
    ensure  => 'directory',
    require => User['isv'],
    owner   => 'isv',
    mode    => '0700',
  }

  file { '/home/isv/.ssh/authorized_keys':
    ensure  => 'file',
    source  => 'puppet:///modules/lamp/cloud.key.pub',
    require => [User['isv'],File['/home/isv/.ssh']],
    owner   => 'isv',
  }

  file { '/root/.ssh':
    ensure => 'directory',
    mode   => '0700'
  }

  file { '/root/.ssh/authorized_keys':
    ensure  => 'file',
    source  => 'puppet:///modules/lamp/root.key.pub',
    require => File['/root/.ssh'],
    owner   => 'root',
  }

  package { 'sudo':
    ensure => present,
  }

  file { '/etc/sudoers.d/isv':
    ensure  => file,
    content => "%isv ALL=(ALL) NOPASSWD: ALL",
    force   => true,
    owner   => root,
    group   => root,
    mode    => '0440',
    require => Package['sudo'],
  }

}
