include vmwaretools
include vmwaretools::ntp
package { 'ntpd':
  ensure => 'present',
  notify => $::virtual ? {
    'vmware' => Class['vmwaretools::ntp'],
    default  => undef,
  },
}
