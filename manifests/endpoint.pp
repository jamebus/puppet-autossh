# == Class: autossh::endpoint
#
# Creates the endpoint files (authorized_keys) for an ssh tunnel.  This 
# class should be run on any 'target' hosts for ssh tunnels.
#
# This class:
#   * creates the receiving account (user account).
#   * creates the authorized_keys file.
# 
# === Parameters
#
# $user = The local user account to use to terminate the ssh tunnel.
# $host = the host name to use to filter the tunnel_endpoint exported resources
# .  This should match the 'host' used on the initiating node.
#
# === Variables
#
# === Examples
#
#  autossh::endpoint  { 'createtunnels': 
#    user   => 'autossh',
#    host   => 'server1.foo.bar',
#  }
#
# === Authors
#
# Jason Ball <jason@ball.net>
#
# === Copyright
#
# Copyright 2014 Jason Ball.
define autossh::endpoint(
  $host,
  $user      = $autossh::user,
  $home_path = $autossh::home_path
)
{
  concat { "${home_path}/${user}/.ssh/authorized_keys":
    owner => root,
    group => $user,
    mode  => '0640',
  }
  Autossh::Tunnel_endpoint <<| host == $host |>>
}
