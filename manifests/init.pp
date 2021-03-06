# Class: windowstime
# ===========================
#
# A module to manage windows time configuration.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * 'servers'
# A hash of time servers, including the configuration flags as follows:
#
# 0x01 SpecialInterval
# 0x02 UseAsFallbackOnly
# 0x04 SymmatricActive
# 0x08 Client
# The Params class contains some sane defaults:
#   $servers = { 'pool.ntp.org'     => '0x01',
#               'time.windows.com' => '0x01',
#               'time.nist.gov'    => '0x02',
#  }
# Examples
# --------
#
# @example
#    class { 'windowstime':
#      servers => { 'pool.ntp.org'     => '0x01',
#                   'time.windows.com' => '0x01',
#                 }
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
  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type':
    ensure => present,
    type   => string,
    data   => 'NTP'
  }
  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
    ensure => present,
    type   => string,
    data   => $regvalue,
    notify      => Service['w32time'],
  }
  exec { 'c:/Windows/System32/w32tm.exe /resync':
    refreshonly => true,
  }
  service { 'w32time':
    ensure => running,
    enable => true,
    notify => Exec['c:/Windows/System32/w32tm.exe /resync'],
  }

}
