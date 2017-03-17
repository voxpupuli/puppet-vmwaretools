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
#   include vmwaretools
#   include vmwaretools::ntp
#   package { 'ntpd':
#     ensure => 'present',
#     notify => $::virtual ? {
#       'vmware' => Class['vmwaretools::ntp'],
#       default  => undef,
#     },
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
# Geoff Davis <gadavis@ucsd.edu>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
# Copyright (c) 2012 The Regents of the University of California
#
class vmwaretools::ntp {

  case $::virtual {
    'vmware': {
      if $::vmwaretools::package_real == '' {
        fail('The class vmwaretools must be declared in the catalog in order to use this class')
      }
      # tools.syncTime = "FALSE" should be in the guest's vmx file and NTP
      # should be in use on the guest.  http://kb.vmware.com/kb/1006427
      # This nasty if/elseif/else statement comes from the inability to determine
      ## The value of synctime when using vmware-guestd. :-(
      if $::vmwaretools::service_pattern == 'vmtoolsd' {
        exec { 'vmware-tools.syncTime':
          command  => 'vmware-toolbox-cmd timesync disable',
          onlyif   => 'vmware-toolbox-cmd timesync status',
          path        => '/usr/bin:/usr/sbin',
          require     => Package[$::vmwaretools::package_real],
        }
      } elsif $::vmwaretools::service_pattern == 'vmware-guestd' {
        exec { 'vmware-tools.syncTime':
          command => 'vmware-guestd --cmd "vmx.set_option synctime 1 0" || true',
          path        => '/usr/bin:/usr/sbin',
          returns     => [ 0, 1, ],
          subscribe   => Package[$::vmwaretools::package_real],
          refreshonly => true,
        }
      } else {
        # Do nothing.
      }
    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
