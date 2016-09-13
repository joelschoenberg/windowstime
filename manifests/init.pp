# Class: windowstime
# ===========================
#
# Full description of class windowstime here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'windowstime':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Nicolas Corrarello <nicolas@puppet.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class windowstime (
  $servers = $windowstime::params::servers
) inherits windowstime::params {
  validate_hash($servers)
  $regvalue = maptoreg($servers)
  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
    ensure => present,
    type   => string,
    data   => $regvalue,
    notify => Exec['c:/Windows/System32/w32tm.exe /resync'],
  }
  exec { 'c:/Windows/System32/w32tm.exe /resync':
    refreshonly => true,
    notify      => Service['w32time'],
  }
  service { 'w32time':
    ensure => running,
    enable => true,
  }

}
