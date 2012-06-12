# == Class: vmwaretools
#
# This class handles installing the VMware Tools Operating System Specific
# Packages.  http://packages.vmware.com/
#
# === Parameters:
#
# [*tools_version*]
#   The version of VMware Tools to install.
#   Default: 4.1latest
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# [*package*]
#   Name of the package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_name*]
#   Name of VMware Tools service
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
#
# [*service_hasstatus*]
#   Service has status command.
#   Default: true
#
# [*service_hasrestart*]
#   Service has restart command.
#   Default: true
#
# === Actions:
#
# Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
# Installs a vmware YUM repository.
# Installs the OSP.
# Starts the vmware-tools service.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { vmwaretools':
#     tools_version => '4.0u3',
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
# Copyright (C) 2012 The Regents of the University of California
#
class vmwaretools (
  $tools_version      = '4.1latest',
  $ensure             = 'present',
  $autoupgrade        = false,
  $package            = $vmwaretools::params::package_name,
  $service_ensure     = 'running',
  $service_name       = undef,
  $service_enable     = true,
  $service_hasstatus  = undef,
  $service_hasrestart = true
) inherits vmwaretools::params {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }

      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::virtual {
    'vmware': {
      $service_pattern = $tools_version ? {
        /3\..+/   => 'vmware-guestd',
        /(4.0).+/ => 'vmware-guestd',
        default   => 'vmtoolsd',
      }

      $package_name = $tools_version ? {
        /3\..+/ => $package_name_4x,
        /4\..+/ => $package_name_4x,
        default => $package_name_5x,
      }

      $service_name_real = $service_name ? {
        undef => $tools_version ? {
          /3\..+/ => $service_name_4x,
          /4\..+/ => $service_name_4x,
          default => $service_name_5x,
        },
        default => $service_name,
      }

      $service_hassstatus_real = $service_hasstatus ? {
        undef => $tools_version ? {
          /3\..+/ => $service_hasstatus_4x,
          /4\..+/ => $service_hasstatus_4x,
          default => $service_hasstatus_5x,
        },
        default => $service_hasstatus,
      }

      $majdistrelease = $::lsbmajdistrelease ? {
        ''      => regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1'),
        default => $::lsbmajdistrelease,
      }

      # We use $::operatingsystem and not $::osfamily because certain things
      # (like Fedora) need to be excluded.
      case $::operatingsystem {
        'RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM', 'OracleLinux', 'OVS', 'OEL', 'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
          yumrepo { 'vmware-tools':
            descr    => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${majdistrelease} ${vmwaretools::params::yum_basearch}",
            enabled  => 1,
            gpgcheck => 1,
            # gpgkey has to be a string value with an indented second line
            # per http://projects.puppetlabs.com/issues/8867
            gpgkey   => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub
    ${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
            baseurl  => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${majdistrelease}/${vmwaretools::params::yum_basearch}/",
            priority => $vmwaretools::params::yum_priority,
            protect  => $vmwaretools::params::yum_protect,
            before   => Package[$package_name],
          }
        }
        default: { }
      }

      package { 'VMwareTools':
        ensure => 'absent',
        before => Package[$package_name],
      }

      exec { 'vmware-uninstall-tools':
        command => '/usr/bin/vmware-uninstall-tools.pl && rm -rf /usr/lib/vmware-tools',
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif  => 'test -f /usr/bin/vmware-uninstall-tools.pl',
        before  => [ Package[$package_name], Package['VMwareTools'], ],
      }

      # TODO: remove Exec["vmware-uninstall-tools-local"]
      exec { 'vmware-uninstall-tools-local':
        command => '/usr/local/bin/vmware-uninstall-tools.pl && rm -rf /usr/local/lib/vmware-tools',
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif  => 'test -f /usr/local/bin/vmware-uninstall-tools.pl',
        before  => [ Package[$package_name], Package['VMwareTools'], ],
      }

      package { $package_name :
        ensure  => $package_ensure,
      }

      service { $service_name_real :
        ensure     => $service_ensure_real,
        enable     => $service_enable,
        hasrestart => $service_hasrestart,
        hasstatus  => $service_hasstatus_real,
        pattern    => $service_pattern,
        require    => Package[$package_name],
      }

    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
