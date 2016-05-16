class monitor {

  class {'nagios::server':
    engine             => 'icinga',
    pnp4nagios         => 1,
    pnp4nagios_rrdbase => "/data/pnp4nagios/",

    http_users         => {
      admin              => { 'password' => '$apr1$2iKzlV1B$LlWo.u77SHKaPiCq0CnEp0' },
    },

###################################################################################################################################
    nd => {
      "${::fqdn}" => {
        'ip'       => "${::ipaddress}",
        'domain'   => "${::domain}",
        'services' => {
          'Ping'                        => { check => 'check_ping!200.0,60%!500.0,95%'},
          'Load'                        => { check => 'check_nrpe!check_load!15 10 5 30 25 20'},
          'Procs'                       => { check => 'check_nrpe!check_total_procs!500 1000'},
          'Zombies'                     => { check => 'check_nrpe!check_zombie_procs!5 10'},
          'Connections'                 => { check => 'check_nrpe!check_conn!500 1000'},
          'Disk /'                      => { check => 'check_nrpe!check_disk!20% 10% /'},
          'Memory'                      => { check => 'check_nrpe!check_memory! 91 95'},
          'NTP Peer'                    => { check => 'check_nrpe!check_ntp_peer! 127.0.0.1 3 10'},
        }
      }
    }
  }
}

