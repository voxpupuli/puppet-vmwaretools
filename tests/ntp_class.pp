class { 'vmwaretools':
  tools_version => '4.0',
  autoupgrade   => true,
}
class { 'vmwaretools::ntp': }
package { 'ntpd':
  ensure => 'present',
  notify => $::virtual ? {
    'vmware' => Class['vmwaretools::ntp'],
    default  => undef,
  },
}
