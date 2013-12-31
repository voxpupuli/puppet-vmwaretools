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
# [*disable_tools_version*]
#   Whether to report the version of the tools back to vCenter/ESX.
#   Default: true (ie do not report)
#
# [*manage_repository*]
#   Whether to allow the yumrepo to be manged by the module or out of band (ie
#   RHN Satellite).
#   Default: true (ie let the module manage it)
#
# [*yum_server*]
#   The server which holds the YUM repository.  Customize this if you mirror
#   public YUM repos to your internal network.
#   Default: http://packages.vmware.com
#
# [*yum_path*]
#   The path on *yum_server* where the repository can be found.  Customize
#   this if you mirror public YUM repos to your internal network.
#   Default: /tools
#
# [*just_prepend_yum_path*]
#   Whether to prepend the overridden *yum_path* onto the default *yum_path*
#   or completely replace it.  Only works if *yum_path* is specified.
#   Default: 0 (false)
#
# [*priority*]
#   Give packages in this YUM repository a different weight.  Requires
#   yum-plugin-priorities to be installed.
#   Default: 50
#
# [*protect*]
#   Protect packages in this YUM repository from being overridden by packages
#   in non-protected repositories.
#   Default: 0 (false)
#
# [*proxy*]
#   The URL to the proxy server for this repository.
#   Default: absent
#
# [*proxy_username*]
#   The username for the proxy.
#   Default: absent
#
# [*proxy_password*]
#   The password for the proxy.
#   Default: absent
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
  $tools_version         = $vmwaretools::params::tools_version,
  $disable_tools_version = $vmwaretools::params::safe_disable_tools_version,
  $manage_repository     = $vmwaretools::params::safe_manage_repository,
  $yum_server            = $vmwaretools::params::yum_server,
  $yum_path              = $vmwaretools::params::yum_path,
  $just_prepend_yum_path = $vmwaretools::params::safe_just_prepend_yum_path,
  $priority              = $vmwaretools::params::yum_priority,
  $protect               = $vmwaretools::params::yum_protect,
  $proxy                 = $vmwaretools::params::proxy,
  $proxy_username        = $vmwaretools::params::proxy_username,
  $proxy_password        = $vmwaretools::params::proxy_password,
  $ensure                = $vmwaretools::params::ensure,
  $autoupgrade           = $vmwaretools::params::safe_autoupgrade,
  $package               = $vmwaretools::params::package,
  $service_ensure        = $vmwaretools::params::service_ensure,
  $service_name          = $vmwaretools::params::service_name,
  $service_enable        = $vmwaretools::params::safe_service_enable,
  $service_hasstatus     = $vmwaretools::params::service_hasstatus,
  $service_hasrestart    = $vmwaretools::params::safe_service_hasrestart
) inherits vmwaretools::params {

  $supported = $vmwaretools::params::supported

  # Validate our booleans
  validate_bool($manage_repository)
  validate_bool($disable_tools_version)
  validate_bool($just_prepend_yum_path)
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($service_hasrestart)
  validate_bool($supported)

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
      if $supported {
        $service_pattern = $tools_version ? {
          /3\..+/   => 'vmware-guestd',
          /(4.0).+/ => 'vmware-guestd',
          default   => 'vmtoolsd',
        }

        $rhel_upstart = $tools_version ? {
          /3\..+/   => false,
          /4\..+/   => false,
          /(5.0).*/ => false,
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

        if $manage_repository {
          class { 'vmwaretools::repo':
            ensure                => $ensure,
            tools_version         => $tools_version,
            yum_server            => $yum_server,
            yum_path              => $yum_path,
            just_prepend_yum_path => $just_prepend_yum_path,
            priority              => $priority,
            protect               => $protect,
            proxy                 => $proxy,
            proxy_username        => $proxy_username,
            proxy_password        => $proxy_password,
            before                => Package[$package_real],
          }
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

        file_line { 'disable-tools-version':
          path    => '/etc/vmware-tools/tools.conf',
          line    => $disable_tools_version ? {
            false    => 'disable-tools-version = "false"',
            default  => 'disable-tools-version = "true"',
          },
          match   => '^disable-tools-version\s*=.*$',
          require => Package[$package_real],
          notify  => Service[$service_name_real],
        }

        if ($::osfamily == 'RedHat') and ($vmwaretools::params::majdistrelease == '6') and ($rhel_upstart == true) {
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
    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
