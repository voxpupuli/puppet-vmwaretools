class vmwaretools::params {
  $yum_server   = 'http://packages.vmware.com'
  $yum_path     = '/tools'
  $yum_priority = '50'
  $yum_protect  = '0'

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          $package_name = 'open-vm-tools'
          $service_name = 'vmware-tools'
          $yum_basearch = $::architecture ? {
            'i386'  => 'i686',
            default => $::architecture,
          }
        }
        default: {
          $package_name = 'vmware-tools-nox'
          $service_name = 'vmware-tools'
          $yum_basearch = $::architecture ? {
            'i386'  => 'i686',
            default => $::architecture,
          }
        }
      }
    }
    'Suse': {
      $package_name = 'vmware-tools-nox'
      $service_name = 'vmware-tools'
      $yum_basearch = $::architecture ? {
        'i386'  => 'i586',
        default => $::architecture,
      }
    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
