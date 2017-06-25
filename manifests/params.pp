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
  $vmwaretools_reposerver = getvar('::vmwaretools_reposerver')
  if $vmwaretools_reposerver {
    $reposerver = $::vmwaretools_reposerver
  } else {
    $reposerver = 'http://packages.vmware.com'
  }

  $vmwaretools_repopath = getvar('::vmwaretools_repopath')
  if $vmwaretools_repopath {
    $repopath = $::vmwaretools_repopath
  } else {
    $repopath = '/tools'
  }

  $vmwaretools_repopriority = getvar('::vmwaretools_repopriority')
  if $vmwaretools_repopriority {
    $repopriority = $::vmwaretools_repopriority
  } else {
    $repopriority = '50'
  }

  $vmwaretools_repoprotect = getvar('::vmwaretools_repoprotect')
  if $vmwaretools_repoprotect {
    $repoprotect = $::vmwaretools_repoprotect
  } else {
    $repoprotect = '0'
  }

  $vmwaretools_gpgkey_url = getvar('::vmwaretools_gpgkey_url')
  if $vmwaretools_gpgkey_url {
    $gpgkey_url = $::vmwaretools_gpgkey_url
  } else {
    $gpgkey_url = "${reposerver}${repopath}/"
  }

  $vmwaretools_proxy = getvar('::vmwaretools_proxy')
  if $vmwaretools_proxy {
    $proxy = $::vmwaretools_proxy
  } else {
    $proxy = 'absent'
  }

  $vmwaretools_proxy_username = getvar('::vmwaretools_proxy_username')
  if $vmwaretools_proxy_username {
    $proxy_username = $::vmwaretools_proxy_username
  } else {
    $proxy_username = 'absent'
  }

  $vmwaretools_proxy_password = getvar('::vmwaretools_proxy_password')
  if $vmwaretools_proxy_password {
    $proxy_password = $::vmwaretools_proxy_password
  } else {
    $proxy_password = 'absent'
  }

  $vmwaretools_tools_version = getvar('::vmwaretools_tools_version')
  if $vmwaretools_tools_version {
    $tools_version = $::vmwaretools_tools_version
  } else {
    $tools_version = 'latest'
  }
  # Validate that tools version starts with a numeral.
  #validate_re($tools_version, '^[^3-9]\.[0-9]*')

  $vmwaretools_ensure = getvar('::vmwaretools_ensure')
  if $vmwaretools_ensure {
    $ensure = $::vmwaretools_ensure
  } else {
    $ensure = 'present'
  }

  $vmwaretools_package = getvar('::vmwaretools_package')
  if $vmwaretools_package {
    $package = $::vmwaretools_package
  } else {
    $package = undef
  }

  $vmwaretools_service_ensure = getvar('::vmwaretools_service_ensure')
  if $vmwaretools_service_ensure {
    $service_ensure = $::vmwaretools_service_ensure
  } else {
    $service_ensure = 'running'
  }

  $vmwaretools_service_name = getvar('::vmwaretools_service_name')
  if $vmwaretools_service_name {
    $service_name = $::vmwaretools_service_name
  } else {
    $service_name = undef
  }

  $vmwaretools_service_hasstatus = getvar('::vmwaretools_service_hasstatus')
  if $vmwaretools_service_hasstatus {
    $service_hasstatus = $::vmwaretools_service_hasstatus
  } else {
    $service_hasstatus = undef
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $vmwaretools_just_prepend_repopath = getvar('::vmwaretools_just_prepend_repopath')
  if $vmwaretools_just_prepend_repopath {
    $just_prepend_repopath = $::vmwaretools_just_prepend_repopath
  } else {
    $just_prepend_repopath = false
  }
  if is_string($just_prepend_repopath) {
    $safe_just_prepend_repopath = str2bool($just_prepend_repopath)
  } else {
    $safe_just_prepend_repopath = $just_prepend_repopath
  }

  $vmwaretools_manage_repository = getvar('::vmwaretools_manage_repository')
  if $vmwaretools_manage_repository {
    $manage_repository = $::vmwaretools_manage_repository
  } else {
    $manage_repository = true
  }
  if is_string($manage_repository) {
    $safe_manage_repository = str2bool($manage_repository)
  } else {
    $safe_manage_repository = $manage_repository
  }

  $vmwaretools_disable_tools_version = getvar('::vmwaretools_disable_tools_version')
  if $vmwaretools_disable_tools_version {
    $disable_tools_version = $::vmwaretools_disable_tools_version
  } else {
    $disable_tools_version = true
  }
  if is_string($disable_tools_version) {
    $safe_disable_tools_version = str2bool($disable_tools_version)
  } else {
    $safe_disable_tools_version = $disable_tools_version
  }

  $vmwaretools_autoupgrade = getvar('::vmwaretools_autoupgrade')
  if $vmwaretools_autoupgrade {
    $autoupgrade = $::vmwaretools_autoupgrade
  } else {
    $autoupgrade = false
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $vmwaretools_service_enable = getvar('::vmwaretools_service_enable')
  if $vmwaretools_service_enable {
    $service_enable = $::vmwaretools_service_enable
  } else {
    $service_enable = true
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  $vmwaretools_service_hasrestart = getvar('::vmwaretools_service_hasrestart')
  if $vmwaretools_service_hasrestart {
    $service_hasrestart = $::vmwaretools_service_hasrestart
  } else {
    $service_hasrestart = true
  }
  if is_string($service_hasrestart) {
    $safe_service_hasrestart = str2bool($service_hasrestart)
  } else {
    $safe_service_hasrestart = $service_hasrestart
  }

  $vmwaretools_scsi_timeout = getvar('::vmwaretools_scsi_timeout')
  if $vmwaretools_scsi_timeout {
    $scsi_timeout = $::vmwaretools_scsi_timeout
  } else {
    $scsi_timeout = '180'
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
          $repobasearch_4x = $::architecture
          $repobasearch_5x = $::architecture
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
