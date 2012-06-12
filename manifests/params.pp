# == Class: vmwaretools::params
#
# This class handles OS-specific configuration of the vmwaretools module.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
# Geoff Davis <gadavis@ucsd.edu>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
# Copyright (C) 2012 The Regents of the University of California
#
class vmwaretools::params {
  # Customize these values if you (for example) mirror public YUM repos to your
  # internal network.
  $yum_server   = 'http://packages.vmware.com'
  $yum_path     = '/tools'
  $yum_priority = '50'
  $yum_protect  = '0'

# These should not need to be changed.
  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          fail("Unsupported platform: ${::operatingsystem}")
          $package_name_4x = 'open-vm-tools'
          $package_name_5x = $package_name
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = false
        }
        default: {
          $package_name_4x = 'vmware-tools-nox'
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods',
          ]
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
        }
      }
      $yum_basearch = $::architecture ? {
        'i386'  => 'i686',
        default => $::architecture,
      }
      $baseurl_string = 'rhel'  # must be lower case
    }
    'Suse': {
      $package_name_4x = 'vmware-tools-nox'
      $package_name_5x = 'vmware-tools-esx-nox'
      $service_name_4x = 'vmware-tools'
      $service_name_5x = 'vmware-tools-services'
      $service_hasstatus_4x = false
      $service_hasstatus_5x = true
      $yum_basearch = $::architecture ? {
        'i386'  => 'i586',
        default => $::architecture,
      }
      $baseurl_string = 'suse'  # must be lower case
    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
