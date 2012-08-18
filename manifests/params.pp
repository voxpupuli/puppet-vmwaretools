# == Class: vmwaretools::params
#
# This class handles OS-specific configuration of the vmwaretools module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
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

# The following parameters should not need to be changed.

  # If we have a top scope variable defined, use it, otherwise fall back to a
  # hardcoded value.
  $tools_version = $::vmwaretools_tools_version ? {
    undef   => 'latest',
    default => $::vmwaretools_tools_version,
  }
  # Validate that tools version starts with a numeral.
  #validate_re($tools_version, '^[^3-9]\.[0-9]*')

  $ensure = $::vmwaretools_ensure ? {
    undef   => 'present',
    default => $::vmwaretools_ensure,
  }

  $package = $::vmwaretools_package ? {
    undef   => undef,
    default => $::vmwaretools_package,
  }

  $service_ensure = $::vmwaretools_service_ensure ? {
    undef   => 'running',
    default => $::vmwaretools_service_ensure,
  }

  $service_name = $::vmwaretools_service_name ? {
    undef   => undef,
    default => $::vmwaretools_service_name,
  }

  $service_hasstatus = $::vmwaretools_service_hasstatus ? {
    undef   => undef,
    default => $::vmwaretools_service_hasstatus,
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = $::vmwaretools_autoupgrade ? {
    undef   => false,
    default => $::vmwaretools_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $service_enable = $::vmwaretools_service_enable ? {
    undef   => true,
    default => $::vmwaretools_service_enable,
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  $service_hasrestart = $::vmwaretools_service_hasrestart ? {
    undef   => true,
    default => $::vmwaretools_service_hasrestart,
  }
  if is_string($service_hasrestart) {
    $safe_service_hasrestart = str2bool($service_hasrestart)
  } else {
    $safe_service_hasrestart = $service_hasrestart
  }

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          fail("Unsupported platform: ${::operatingsystem}")
          #$package_name = 'open-vm-tools'
          #$service_name = 'vmware-tools'
          #$service_hasstatus = false
        }
        default: {
          $package_name_4x = 'vmware-tools-nox'
          # TODO: OSP 5.0+ rhel5 i386 also has vmware-tools-esx-kmods-PAE
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
      $yum_basearch_4x = $::architecture ? {
        'i386'  => 'i686',
        'i586'  => 'i686',
        default => $::architecture,
      }
      $yum_basearch_5x = $::architecture ? {
        'i586'  => 'i386',
        'i686'  => 'i386',
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
      $yum_basearch_4x = $::architecture ? {
        'i386'  => 'i586',
        default => $::architecture,
      }
      $yum_basearch_5x = $::architecture ? {
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
