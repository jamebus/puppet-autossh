# == Class: autossh::install
#
# This class initilises the runtime environment for the autossh package and
# should not be called directly as it is called from the class initialiser.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { autossh:
#  }
#
# === Authors
#
# Jason Ball <jason@ball.net>
# Gerard Castillo <gerardcl@gmail.com> -- forked from https://github.com/agronaught/puppet-autossh
#
# === Copyright
#
# Copyright 2014 Jason Ball.
#
class autossh::install {
  $user                      = $autossh::user
  $home_path                 = $autossh::home_path
  $autossh_package           = $autossh::autossh_package
  $ssh_reuse_established_connections =
    $autossh::ssh_reuse_established_connections
  $ssh_enable_compression    = $autossh::ssh_enable_compression
  $ssh_ciphers               = $autossh::ssh_ciphers
  $ssh_stricthostkeychecking = $autossh::ssh_stricthostkeychecking
  $ssh_tcpkeepalives         = $autossh::ssh_tcpkeepalives
  $server_alive_interval     = $autossh::server_alive_interval
  $server_alive_count_max    = $autossh::server_alive_count_max

  unless defined(File[$home_path]) {
    file { $home_path:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755'
    }
  }

  user { $user:
    managehome => false,
    home       => "${home_path}/${user}",
    comment    => 'autossh',
    system     => true,
    shell      => '/bin/false'
  }

  file { "${home_path}/${user}":
    ensure => 'directory',
    owner  => 'root',
    group  => $user,
    mode   => '0750'
  }

  file { "${home_path}/${user}/.ssh":
    ensure => 'directory',
    owner  => 'root',
    group  => $user,
    mode   => '0750'
  }

  case $::osfamily {
    /RedHat/: {

      # redhat-lsb-core is not supporte on rhel 7...
      case $::operatingsystemmajrelease {
        /5|6/: {
          if(!defined(Package['redhat-lsb-core'])) {
            package{'redhat-lsb-core':
              ensure => installed,
              before => Package['autossh'] }
          }
        } # case rhel 7

        default: {
        }
      }

      # required on all rhel platforms
      if(!defined(Package['openssh-clients'])) {
        package{'openssh-clients': ensure => installed }
      }

      package{'autossh': ensure => installed }
    } #case RedHat

    /Debian/: {
      package{ $autossh_package: ensure => installed }
    } # Debian

    default: {
      fail("Unsupported OS Family: ${::osfamily}")
    }
  } #case


  ## Configure reuse of established connections.
  ## Nice but little known feature of ssh.
  if $ssh_reuse_established_connections {
    file { "${home_path}/${user}/.ssh/sockets":
      ensure => 'directory',
      owner  => $user,
      group  => $user,
      mode   => '0700'
    }
  }

  ## Make sure known_hosts is writable
  file { "${home_path}/${user}/.ssh/known_hosts":
    ensure => 'present',
    owner  => $user,
    group  => $user,
    mode   => '0640'
  }

  ##
  ## ssh config file
  ##
  concat {"${home_path}/${user}/.ssh/config":
    owner => 'root',
    group => $user,
    mode  => '0640',
  }

  ##
  ## Global Settings
  ##
  $remote_ssh_host = '*'
  concat::fragment { "home_${user}_ssh_config_global":
    target  => "${home_path}/${user}/.ssh/config",
    content => template('autossh/config.erb'),
    order   => 10,
  }


}
