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
  $reposerver = $::vmwaretools_reposerver ? {
    undef   => 'http://packages.vmware.com',
    default => $::vmwaretools_reposerver,
  }

  $repopath = $::vmwaretools_repopath ? {
    undef   => '/tools',
    default => $::vmwaretools_repopath,
  }

  $repopriority = $::vmwaretools_repopriority ? {
    undef   => '50',
    default => $::vmwaretools_repopriority,
  }

  $repoprotect = $::vmwaretools_repoprotect ? {
    undef   => '0',
    default => $::vmwaretools_repoprotect,
  }

  $gpgkey_url = $::vmwaretools_gpgkey_url ? {
    undef   => "${reposerver}${repopath}/",
    default => $::vmwaretools_gpgkey_url,
  }

  $proxy = $::vmwaretools_proxy ? {
    undef   => 'absent',
    default => $::vmwaretools_proxy,
  }

  $proxy_username = $::vmwaretools_proxy_username ? {
    undef   => 'absent',
    default => $::vmwaretools_proxy_username,
  }

  $proxy_password = $::vmwaretools_proxy_password ? {
    undef   => 'absent',
    default => $::vmwaretools_proxy_password,
  }

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
  $just_prepend_repopath = $::just_prepend_repopath ? {
    undef   => false,
    default => $::vmwaretools_just_prepend_repopath,
  }
  if is_string($just_prepend_repopath) {
    $safe_just_prepend_repopath = str2bool($just_prepend_repopath)
  } else {
    $safe_just_prepend_repopath = $just_prepend_repopath
  }

  $manage_repository = $::manage_repository ? {
    undef   => true,
    default => $::vmwaretools_manage_repository,
  }
  if is_string($manage_repository) {
    $safe_manage_repository = str2bool($manage_repository)
  } else {
    $safe_manage_repository = $manage_repository
  }

  $disable_tools_version = $::vmwaretools_disable_tools_version ? {
    undef   => true,
    default => $::vmwaretools_disable_tools_version,
  }
  if is_string($disable_tools_version) {
    $safe_disable_tools_version = str2bool($disable_tools_version)
  } else {
    $safe_disable_tools_version = $disable_tools_version
  }

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

  if $::operatingsystemmajrelease { # facter 1.7+
    $majdistrelease = $::operatingsystemmajrelease
  } elsif $::lsbmajdistrelease {    # requires LSB to already be installed
    $majdistrelease = $::lsbmajdistrelease
  } elsif $::os_maj_version {       # requires stahnma/epel
    $majdistrelease = $::os_maj_version
  } else {
    $majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')
  }

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
