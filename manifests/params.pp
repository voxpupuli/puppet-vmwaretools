class vmwaretools::params {
  # Customize these values if you (for example) mirror public YUM repos to your
  # internal network.
  $yum_server   = 'http://packages.vmware.com'
  $yum_path     = '/tools'
  $yum_priority = '50'
  $yum_protect  = '0'

# These should not need to be changed.
  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          $package_name = 'open-vm-tools'
          $service_name = 'vmware-tools'
        }
        default: {
          $package_name = 'vmware-tools-nox'
          $service_name = 'vmware-tools'
        }
      }
      $yum_basearch = $::architecture ? {
        'i386'  => 'i686',
        default => $::architecture,
      }
      $baseurl_string = 'rhel'  # must be lower case
    }
    'Suse': {
      $package_name = 'vmware-tools-nox'
      $service_name = 'vmware-tools'
      $yum_basearch = $::architecture ? {
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
