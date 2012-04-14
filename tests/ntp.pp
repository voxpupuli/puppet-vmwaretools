include vmwaretools::ntp
#package { 'ntp': notify => Exec['vmware-tools.syncTime'], }
package { 'ntp':
  notify => $::virtual ? {
    'vmware' => Exec['vmware-tools.syncTime'],
    default  => undef,
  },
}
