# == Class: vmwaretools::repo
#
# This class handles installing the VMware Tools Operating System Specific
# Packages software repository.  http://packages.vmware.com/
#
# === Parameters:
#
# [*tools_version*]
#   The version of VMware Tools to install.  Possible values can be found here:
#   http://packages.vmware.com/tools/esx/index.html
#   Default: latest
#
# [*reposerver*]
#   The server which holds the package repository.  Customize this if you mirror
#   public repos to your internal network.
#   Default: http://packages.vmware.com
#
# [*repopath*]
#   The path on *reposerver* where the repository can be found.  Customize
#   this if you mirror public repos to your internal network.
#   Default: /tools
#
# [*just_prepend_repopath*]
#   Whether to prepend the overridden *repopath* onto the default *repopath*
#   or completely replace it.  Only works if *repopath* is specified.
#   Default: 0 (false)
#
# [*gpgkey_url*]
#   The URL where the public GPG key resides for the repository NOT including
#   the GPG public key file itself (ending with a trailing /).
#   Default: ${reposerver}${repopath}/
#
# [*priority*]
#   Give packages in this repository a different weight.  Requires
#   yum-plugin-priorities to be installed.
#   Default: 50
#
# [*protect*]
#   Protect packages in this repository from being overridden by packages
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
# === Actions:
#
# Installs a vmware package repository.
# Imports a GPG signing key if needed.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'vmwaretools::repo':
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
class vmwaretools::repo (
  $tools_version         = $vmwaretools::params::tools_version,
  $reposerver            = $vmwaretools::params::reposerver,
  $repopath              = $vmwaretools::params::repopath,
  $just_prepend_repopath = $vmwaretools::params::safe_just_prepend_repopath,
  $priority              = $vmwaretools::params::repopriority,
  $protect               = $vmwaretools::params::repoprotect,
  $gpgkey_url            = $vmwaretools::params::gpgkey_url,
  $proxy                 = $vmwaretools::params::proxy,
  $proxy_username        = $vmwaretools::params::proxy_username,
  $proxy_password        = $vmwaretools::params::proxy_password,
  $ensure                = $vmwaretools::params::ensure
) inherits vmwaretools::params {
  # Validate our booleans
  validate_bool($just_prepend_repopath)

  case $ensure {
    /(present)/: {
      $repo_enabled = '1'
    }
    /(absent)/: {
      $repo_enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::virtual {
    'vmware': {
      $repobasearch = $tools_version ? {
        /3\..+/ => $vmwaretools::params::repobasearch_4x,
        /4\..+/ => $vmwaretools::params::repobasearch_4x,
        default => $vmwaretools::params::repobasearch_5x,
      }

      # We use $::operatingsystem and not $::osfamily because certain things
      # (like Fedora) need to be excluded.
      case $::operatingsystem {
        'RedHat', 'CentOS', 'Scientific', 'OracleLinux', 'OEL': {
          if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
            $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease}/${repobasearch}/"
          } else {
            $baseurl_url = "${reposerver}${repopath}/"
          }

          # gpgkey has to be a string value with an indented second line
          # per http://projects.puppetlabs.com/issues/8867
          if ( $gpgkey_url == $vmwaretools::params::gpgkey_url ) {
            if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
              $gpgkey = "${reposerver}${repopath}/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    ${reposerver}${repopath}/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            } else {
              $gpgkey = "${reposerver}${repopath}/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    ${reposerver}${repopath}/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            }
          } else {
            $gpgkey = "${gpgkey_url}VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    ${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub"
          }

          yumrepo { 'vmware-tools':
            descr          => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease} ${repobasearch}",
            enabled        => $repo_enabled,
            gpgcheck       => '1',
            gpgkey         => $gpgkey,
            baseurl        => $baseurl_url,
            priority       => $priority,
            protect        => $protect,
            proxy          => $proxy,
            proxy_username => $proxy_username,
            proxy_password => $proxy_password,
          }

          # Deal with the people who wipe /etc/yum.repos.d .
          file { '/etc/yum.repos.d/vmware-tools.repo':
            ensure => 'file',
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
          }
        }
        'SLES', 'SLED': {
          if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
            $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease}/${repobasearch}/"
          } else {
            $baseurl_url = "${reposerver}${repopath}/"
          }

          if ( $gpgkey_url == $vmwaretools::params::gpgkey_url ) {
            if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
              $gpgkey = "${reposerver}${repopath}/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            } else {
              $gpgkey = "${reposerver}${repopath}/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            }
          } else {
            $gpgkey = "${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub"
          }

          zypprepo { 'vmware-tools':
            descr       => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease} ${repobasearch}",
            enabled     => $repo_enabled,
            gpgcheck    => '1',
            gpgkey      => $gpgkey,
            baseurl     => $baseurl_url,
            priority    => $priority,
            autorefresh => 1,
            notify      => Exec['vmware-import-gpgkey'],
          }

          file { '/etc/zypp/repos.d/vmware-tools.repo':
            ensure => 'file',
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
          }

          exec { 'vmware-import-gpgkey':
            path        => '/bin:/usr/bin:/sbin:/usr/sbin',
            command     => "rpm --import ${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub",
            refreshonly => true,
          }
        }
        'Ubuntu': {
          if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
            $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}"
          } else {
            $baseurl_url = "${reposerver}${repopath}/"
          }

          if ( $gpgkey_url == $vmwaretools::params::gpgkey_url ) {
            if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
              $gpgkey = "${reposerver}${repopath}/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            } else {
              $gpgkey = "${reposerver}${repopath}/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
            }
          } else {
            $gpgkey = "${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub"
          }

          include '::apt'
          apt::source { 'vmware-tools':
            ensure      => $ensure,
            comment     => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string} ${::lsbdistcodename}",
            location    => $baseurl_url,
            key_source  => $gpgkey,
            #key         => '0xC0B5E0AB66FD4949',
            key         => '36E47E1CC4DCC5E8152D115CC0B5E0AB66FD4949',
            include_src => false,
          }
        }
        default: { }
      }
    }
    # If we are not on VMware, do not do anything.
    default: { }
  }
}
