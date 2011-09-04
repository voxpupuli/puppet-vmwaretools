# Class: vmware-tools
#
# This module handles installing the VMware Tools Operating System Specific
# Packages.  http://packages.vmware.com/
#
# Parameters:
#
# Actions:
#   Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
#   Installs a vmware YUM repository, if needed.
#   Install the OSP or open vmware tools.
#   Starts the vmware-tools service.
#
# Requires:
#   $vmwarever         - optional - 4.0latest|3.5u5|5.0|etc, default: latest
#   $lsbmajdistrelease - required - fact
#
# Sample Usage:
#
class vmware-tools {
  $vmwarever_real = $vmwarever ? {
    ''      => 'latest',
    default => "$vmwarever",
  }

  case $productname {
    'VMware Virtual Platform': {
      package { "VMwareTools":
        ensure  => "absent",
        before => Package["vmware-tools"],
      }

      package { "vmware-tools":
        ensure  => "latest",
        name    => $operatingsystem ? {
          Fedora  => "open-vm-tools",
          default => "vmware-tools-nox",
        },
        require => $operatingsystem ? {
          Fedora  => Package ["VMwareTools"],
          default => [ Yumrepo["vmware"], Package ["VMwareTools"], ],
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

      # tools.syncTime = "TRUE" should be in the guest's vmx file.
      # http://kb.vmware.com/kb/1006427
      exec { "vmware-tools.syncTime":
        command     => 'vmware-guestd --cmd "vmx.set_option synctime 1 0" || true',
        path        => "/usr/bin:/usr/local/bin",
        returns     => [ 0, 1, ],
        require     => Package["vmware-tools"],
        refreshonly => true,
      }

      $yum_basearch = $architecture ? {
        'i386'  => 'i686',
        default => "$architecture",
      }

      case $operatingsystem {
        CentOS, RedHat, OEL: {
          yumrepo { "vmware":
            descr    => "VMware Tools $vmwarever_real - rhel${lsbmajdistrelease} ${yum_basearch}",
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => "http://packages.vmware.com/tools/VMWARE-PACKAGING-GPG-KEY.pub",
            baseurl  => "http://packages.vmware.com/tools/esx/${vmwarever_real}/rhel${lsbmajdistrelease}/${yum_basearch}/",
            priority => 10,
            protect  => 0,
           #require  => [ Package["yum-priorities"], Package["yum-protectbase"], ],
          }
        }
        default: { }
      }

      service { "vmware-tools":
        name       => $operatingsystem ? {
          default => "vmware-tools",
        },
        ensure     => "running",
        enable     => "true",
        hasrestart => "true",
        hasstatus  => "true",
        require    => Package["vmware-tools"],
      }

    }
    default: { }

  }
}
