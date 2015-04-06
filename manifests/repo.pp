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
# === Actions:
#
# Installs a vmware YUM repository.
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
  $yum_server            = $vmwaretools::params::yum_server,
  $yum_path              = $vmwaretools::params::yum_path,
  $just_prepend_yum_path = $vmwaretools::params::safe_just_prepend_yum_path,
  $priority              = $vmwaretools::params::yum_priority,
  $protect               = $vmwaretools::params::yum_protect,
  $proxy                 = $vmwaretools::params::proxy,
  $proxy_username        = $vmwaretools::params::proxy_username,
  $proxy_password        = $vmwaretools::params::proxy_password,
  $ensure                = $vmwaretools::params::ensure
) inherits vmwaretools::params {
  # Validate our booleans
  validate_bool($just_prepend_yum_path)

  case $ensure {
    /(present)/: {
      $yumrepo_enabled = '1'
    }
    /(absent)/: {
      $yumrepo_enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::virtual {
    'vmware': {
      $yum_basearch = $tools_version ? {
        /3\..+/ => $vmwaretools::params::yum_basearch_4x,
        /4\..+/ => $vmwaretools::params::yum_basearch_4x,
        default => $vmwaretools::params::yum_basearch_5x,
      }

      # We use $::operatingsystem and not $::osfamily because certain things
      # (like Fedora) need to be excluded.
      case $::operatingsystem {
        'RedHat', 'CentOS', 'Scientific', 'OracleLinux', 'OEL': {
          if ( $yum_path == $vmwaretools::params::yum_path ) or ( $just_prepend_yum_path == true ) {
            $gpgkey_url  = "${yum_server}${yum_path}/keys/"
            $baseurl_url = "${yum_server}${yum_path}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease}/${yum_basearch}/"
          } else {
            $gpgkey_url  = "${yum_server}${yum_path}/"
            $baseurl_url = "${yum_server}${yum_path}/"
          }

          yumrepo { 'vmware-tools':
            descr          => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease} ${yum_basearch}",
            enabled        => $yumrepo_enabled,
            gpgcheck       => '1',
            # gpgkey has to be a string value with an indented second line
            # per http://projects.puppetlabs.com/issues/8867
            gpgkey         => "${gpgkey_url}VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    ${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub",
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
          if ( $yum_path == $vmwaretools::params::yum_path ) or ( $just_prepend_yum_path == true ) {
            $gpgkey_url  = "${yum_server}${yum_path}/keys/"
            $baseurl_url = "${yum_server}${yum_path}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease}/${yum_basearch}/"
          } else {
            $gpgkey_url  = "${yum_server}${yum_path}/"
            $baseurl_url = "${yum_server}${yum_path}/"
          }

          zypprepo { 'vmware-tools':
            descr       => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease} ${yum_basearch}",
            enabled     => $yumrepo_enabled,
            gpgcheck    => '1',
            gpgkey      => "${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub",
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
          if ( $yum_path == $vmwaretools::params::yum_path ) or ( $just_prepend_yum_path == true ) {
            $gpgkey_url  = "${yum_server}${yum_path}/keys/"
            $baseurl_url = "${yum_server}${yum_path}/esx/${tools_version}/${vmwaretools::params::baseurl_string}"
          } else {
            $gpgkey_url  = "${yum_server}${yum_path}/"
            $baseurl_url = "${yum_server}${yum_path}/"
          }

          include '::apt'
          apt::source { 'vmware-tools':
            ensure      => $ensure,
            comment     => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string} ${::lsbdistcodename}",
            location    => $baseurl_url,
            key_source  => "${gpgkey_url}VMWARE-PACKAGING-GPG-RSA-KEY.pub",
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
