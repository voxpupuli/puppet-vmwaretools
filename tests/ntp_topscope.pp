$vmwaretools_tools_version = '4.1'
$vmwaretools_autoupgrade = true
include 'vmwaretools'
include 'vmwaretools::ntp'
package { 'ntpd':
  ensure => 'present',
  notify => $::virtual ? {
    'vmware' => Class['vmwaretools::ntp'],
    default  => undef,
  },
}
