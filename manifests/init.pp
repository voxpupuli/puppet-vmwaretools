# Class: vmwaretools
#
# This class handles installing the VMware Tools Operating System Specific
# Packages.  http://packages.vmware.com/
#
# Parameters:
#   $vmwaretools_esx_version - optional - 3.5latest|4.0|3.5u5|etc
#     default: 4.1latest
#
# Actions:
#   Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
#   Installs a vmware YUM repository, if needed.
#   Install the OSP or open vmware tools.
#   Starts the vmware-tools service.
#
# Requires:
#
# Sample Usage:
#   $vmwaretools_esx_version = '4.1latest'
#   include vmwaretools
#
class vmwaretools {
  case $::virtual {
    "vmware": {
      include vmwaretools::params

      $vmwaretools_esx_version_real = $::vmwaretools_esx_version ? {
        ''      => '4.1latest',
        default => "$::vmwaretools_esx_version",
      }

      $majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')

      # We use $::operatingsystem and not $::osfamily because certain things
      # (like Fedora) need to be excluded.
      case $::operatingsystem {
        "RedHat", "CentOS", "Scientific", "SLC", "Ascendos", "PSBM", "OracleLinux", "OVS", "OEL": {
          $yum_basearch = $::architecture ? {
            'i386'  => 'i686',
            default => "$::architecture",
          }

          yumrepo { "vmware-tools":
            descr    => "VMware Tools $vmwaretools_esx_version_real - RHEL${majdistrelease} ${yum_basearch}",
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/VMWARE-PACKAGING-GPG-KEY.pub",
            baseurl  => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${vmwaretools_esx_version_real}/rhel${majdistrelease}/${yum_basearch}/",
            priority => $vmwaretools::params::yum_priority,
            protect  => $vmwaretools::params::yum_protect,
          }
        }

        "SLES", "SLED", "OpenSuSE", "SuSE": {
          $yum_basearch = $::architecture ? {
            'i386'  => 'i586',
            default => "$::architecture",
          }

          yumrepo { "vmware-tools":
            descr    => "VMware Tools $vmwaretools_esx_version_real - SUSE${majdistrelease} ${yum_basearch}",
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/VMWARE-PACKAGING-GPG-KEY.pub",
            baseurl  => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${vmwaretools_esx_version_real}/suse${majdistrelease}/${yum_basearch}/",
            priority => $vmwaretools::params::yum_priority,
            protect  => $vmwaretools::params::yum_protect,
          }
        }

        default: { }
      }

      package { "VMwareTools":
        ensure => "absent",
        before => Package["vmware-tools"],
      }

      package { "vmware-tools":
        ensure  => "latest",
        name    => $::operatingsystem ? {
          Fedora  => "open-vm-tools",
          default => "vmware-tools-nox",
        },
        require => $::operatingsystem ? {
          Fedora  => Package ["VMwareTools"],
          default => [ Yumrepo["vmware-tools"], Package ["VMwareTools"], ],
        },
      }

      exec { "vmware-uninstall-tools":
        command => "/usr/bin/vmware-uninstall-tools.pl",
        path    => "/usr/bin:/usr/local/bin",
        onlyif  => "test -f /usr/bin/vmware-uninstall-tools.pl",
        before  => [ Package["vmware-tools"], Package["VMwareTools"], ],
      }

      exec { "vmware-uninstall-tools-local":
        command => "/usr/local/bin/vmware-uninstall-tools.pl",
        path    => "/usr/bin:/usr/local/bin",
        onlyif  => "test -f /usr/local/bin/vmware-uninstall-tools.pl",
        before  => [ Package["vmware-tools"], Package["VMwareTools"], ],
      }

      # tools.syncTime = "FALSE" should be in the guest's vmx file and NTP
      # should be in use on the guest.  http://kb.vmware.com/kb/1006427
      # TODO: split vmware-tools.syncTime out to the NTP module??
      exec { "vmware-tools.syncTime":
        command     => 'vmware-guestd --cmd "vmx.set_option synctime 1 0" || true',
        path        => "/usr/bin:/usr/local/bin",
        returns     => [ 0, 1, ],
        require     => Package["vmware-tools"],
        refreshonly => true,
      }

      service { "vmware-tools":
        name       => "vmware-tools",
        ensure     => "running",
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        pattern    => "vmware-guestd",
        require    => Package["vmware-tools"],
      }

    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
