# == Class: vmwaretools
#
# This class handles installing the VMware Tools Operating System Specific
# Packages.  http://packages.vmware.com/
#
# === Parameters:
#
# [*tools_version*]
#   The version of VMware Tools to install.  Possible values can be found here:
#   http://packages.vmware.com/tools/esx/index.html
#   Default: latest
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
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
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
#   class { 'vmwaretools':
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
  $tools_version      = $vmwaretools::params::tools_version,
  $ensure             = $vmwaretools::params::ensure,
  $autoupgrade        = $vmwaretools::params::safe_autoupgrade,
  $package            = $vmwaretools::params::package,
  $service_ensure     = $vmwaretools::params::service_ensure,
  $service_name       = $vmwaretools::params::service_name,
  $service_enable     = $vmwaretools::params::safe_service_enable,
  $service_hasstatus  = $vmwaretools::params::service_hasstatus,
  $service_hasrestart = $vmwaretools::params::safe_service_hasrestart
) inherits vmwaretools::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($service_hasrestart)

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

      $rhel_upstart = $tools_version ? {
        /3\..+/   => false,
        /4\..+/   => false,
        /(5.0).+/ => false,
        default   => true,
      }

      $package_real = $package ? {
        undef   => $tools_version ? {
          /3\..+/ => $vmwaretools::params::package_name_4x,
          /4\..+/ => $vmwaretools::params::package_name_4x,
          default => $vmwaretools::params::package_name_5x,
        },
        default => $package,
      }

      $service_name_real = $service_name ? {
        undef   => $tools_version ? {
          /3\..+/ => $vmwaretools::params::service_name_4x,
          /4\..+/ => $vmwaretools::params::service_name_4x,
          default => $vmwaretools::params::service_name_5x,
        },
        default => $service_name,
      }

      $service_hasstatus_real = $service_hasstatus ? {
        undef   => $tools_version ? {
          /3\..+/ => $vmwaretools::params::service_hasstatus_4x,
          /4\..+/ => $vmwaretools::params::service_hasstatus_4x,
          default => $vmwaretools::params::service_hasstatus_5x,
        },
        default => $service_hasstatus,
      }

      $yum_basearch = $tools_version ? {
        /3\..+/ => $vmwaretools::params::yum_basearch_4x,
        /4\..+/ => $vmwaretools::params::yum_basearch_4x,
        default => $vmwaretools::params::yum_basearch_5x,
      }

      # We use $::operatingsystem and not $::osfamily because certain things
      # (like Fedora) need to be excluded.
      case $::operatingsystem {
        'RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM',
        'OracleLinux', 'OVS', 'OEL', 'SLES', 'SLED', 'OpenSuSE',
        'SuSE': {
          $majdistrelease = $::lsbmajdistrelease ? {
            ''      => regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1'),
            default => $::lsbmajdistrelease,
          }
          yumrepo { 'vmware-tools':
            descr    => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${majdistrelease} ${yum_basearch}",
            enabled  => 1,
            gpgcheck => 1,
            # gpgkey has to be a string value with an indented second line
            # per http://projects.puppetlabs.com/issues/8867
            gpgkey   => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    ${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
            baseurl  => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${majdistrelease}/${yum_basearch}/",
            priority => $vmwaretools::params::yum_priority,
            protect  => $vmwaretools::params::yum_protect,
            before   => Package[$package_real],
          }
        }
        default: { }
      }

      package { 'VMwareTools':
        ensure => 'absent',
        before => Package[$package_real],
      }

      exec { 'vmware-uninstall-tools':
        command => '/usr/bin/vmware-uninstall-tools.pl && rm -rf /usr/lib/vmware-tools',
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif  => 'test -f /usr/bin/vmware-uninstall-tools.pl',
        before  => [ Package[$package_real], Package['VMwareTools'], ],
      }

      # TODO: remove Exec["vmware-uninstall-tools-local"]?
      exec { 'vmware-uninstall-tools-local':
        command => '/usr/local/bin/vmware-uninstall-tools.pl && rm -rf /usr/local/lib/vmware-tools',
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif  => 'test -f /usr/local/bin/vmware-uninstall-tools.pl',
        before  => [ Package[$package_real], Package['VMwareTools'], ],
      }

      package { $package_real :
        ensure  => $package_ensure,
      }

      if ($::osfamily == 'RedHat') and ($majdistrelease == '6') and ($rhel_upstart == true) {
        # VMware-tools 5.1 on EL6 is now using upstart and not System V init.
        # http://projects.puppetlabs.com/issues/11989#note-7
        service { $service_name_real :
          ensure     => $service_ensure_real,
          hasrestart => true,
          hasstatus  => true,
          start      => "/sbin/start ${service_name_real}",
          stop       => "/sbin/stop ${service_name_real}",
          status     => "/sbin/status ${service_name_real} | grep -q 'start/'",
          restart    => "/sbin/restart ${service_name_real}",
          require    => Package[$package_real],
        }
      } else {
        service { $service_name_real :
          ensure     => $service_ensure_real,
          enable     => $service_enable,
          hasrestart => $service_hasrestart,
          hasstatus  => $service_hasstatus_real,
          pattern    => $service_pattern,
          require    => Package[$package_real],
        }
      }

    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
