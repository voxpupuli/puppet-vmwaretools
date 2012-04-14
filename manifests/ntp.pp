# == Class: vmwaretools::ntp
#
# This class handles turning off syncTime via the vmware-tools API and should
# be accompanied by a running NTP client on the guest.
#
# === Parameters:
#
# None.
#
# === Actions:
#
# Disables VMware Tools periodic time synchronization (tools.syncTime = "0").
# http://kb.vmware.com/kb/1006427
#
# === Requires:
#
# Class['vmwaretools']
#
# === Sample Usage:
#
#   include vmwaretools::ntp
#   package { 'ntp':
#     notify => $virtual ? {
#       'vmware' => Exec['vmware-tools.syncTime'],
#       default  => undef,
#     },
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
class vmwaretools::ntp {
  include vmwaretools

  case $::virtual {
    'vmware': {
      # tools.syncTime = "FALSE" should be in the guest's vmx file and NTP
      # should be in use on the guest.  http://kb.vmware.com/kb/1006427
      exec { 'vmware-tools.syncTime':
        command     => $vmwaretools::service_pattern ? {
          'vmtoolsd' => 'vmware-toolbox-cmd timesync disable',
          default    => 'vmware-guestd --cmd "vmx.set_option synctime 1 0" || true',
        },
        path        => '/usr/bin:/usr/sbin',
        returns     => [ 0, 1, ],
        require     => Package['vmware-tools'],
        refreshonly => true,
      }
    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
