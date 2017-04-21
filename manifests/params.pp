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
  # If we have a top scope variable defined, use it, otherwise fall back to a
  # hardcoded value.
  $reposerver = 'http://packages.vmware.com'

  $repopath = '/tools'

  $repopriority = '50'

  $repoprotect = '0'

  $gpgkey_url = "${reposerver}${repopath}/"

  $proxy = 'absent'

  $proxy_username = 'absent'

  $proxy_password = 'absent'

  $tools_version = 'latest'

  # Validate that tools version starts with a numeral.
  validate_re($tools_version, '^([^3-9]\.[0-9]*|latest)')

  $ensure = 'present'

  $package = undef

  $service_ensure = 'running'

  $service_name = undef

  $service_hasstatus = undef

  $just_prepend_repopath = false

  $manage_repository = true

  $disable_tools_version = true

  $autoupgrade = true

  $service_enable = true

  $service_hasrestart = true

  $scsi_timeout = '180'

  $majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Scientific': {
          case $majdistrelease {
            '3', '4', '5', '6': {
              $supported = true
            }
            default: {
              notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
              $supported = false
            }
          }
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
        default: {
          notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
          $supported = false
        }
      }
      $repobasearch_4x = $::architecture ? {
        'i386'  => 'i686',
        'i586'  => 'i686',
        default => $::architecture,
      }
      $repobasearch_5x = $::architecture ? {
        'i586'  => 'i386',
        'i686'  => 'i386',
        default => $::architecture,
      }
      $baseurl_string = 'rhel'  # must be lower case
    }
    'Suse': {
      case $::operatingsystem {
        'SLES', 'SLED': {
          # TODO: tools 3.5 and 4.x use either sles11 or sles11sp1 while tools >=5 use sles11.1
          if ($majdistrelease == '9') or  ($majdistrelease == '11') {
            $distrelease = $::operatingsystemrelease
          } else {
            $distrelease = $majdistrelease
          }
          case $majdistrelease {
            '9', '10', '11': {
              $supported = true
            }
            default: {
              notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
              $supported = false
            }
          }
          $package_name_4x = 'vmware-tools-nox'
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods-default',
          ]
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
          $repobasearch_4x = $::architecture ? {
            'i386'  => 'i586',
            default => $::architecture,
          }
          $repobasearch_5x = $::architecture ? {
            'i386'  => 'i586',
            default => $::architecture,
          }
          $baseurl_string = 'sles'  # must be lower case
        }
        default: {
          notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
          $supported = false
        }
      }
    }
    'Debian': {
      case $::operatingsystem {
        'Ubuntu': {
          case $::lsbdistcodename {
            'hardy', 'intrepid', 'jaunty', 'karmic', 'lucid', 'maverick', 'natty', 'oneric', 'precise': {
              $supported = true
            }
            default: {
              notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
              $supported = false
            }
          }
          $package_name_4x = 'vmware-tools-nox'
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods-3.8.0-29-generic',
            #"vmware-tools-esx-kmods-${::kernelrelease}",
          ]
          $repobasearch_4x = undef
          $repobasearch_5x = undef
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
          $baseurl_string = 'ubuntu'  # must be lower case
        }
        default: {
          notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
          $supported = false
        }
      }
    }
    default: {
      notice "Your operating system ${::operatingsystem} is unsupported and will not have the VMware Tools OSP installed."
      $supported = false
    }
  }
}
