Puppet VMware Tools OSP Module
==============================

master branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-vmwaretools.png?branch=master)](http://travis-ci.org/razorsedge/puppet-vmwaretools)
develop branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-vmwaretools.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-vmwaretools)

Introduction
------------

This module manages the installation of the [Operating System Specific Packages](http://packages.vmware.com/) for VMware Tools.  This allows you to use your operating system's native tools to install and update the VMware Tools.

Actions:

* Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
* Installs a VMware YUM repository (defaults to the 'latest' package repository).
* Installs the OSP VMware Tools.
* Starts the vmware-tools service.

OS Support:

* RedHat family - tested on CentOS 5.5+, CentOS 6.2+, RHEL 5.9, RHEL 6.4, and OEL 5.5+
* SuSE family   - untested (initial support for yumrepo) (patches welcome)
* Ubuntu        - presently unsupported (patches welcome)

Class documentation is available via puppetdoc.

Examples
--------

Top Scope variable (i.e. via Dashboard):

    $vmwaretools_tools_version = '4.1'
    $vmwaretools_autoupgrade = true
    include 'vmwaretools'

Parameterized Class:

    class { 'vmwaretools':
      tools_version => '4.0u3',
      autoupgrade   => true,
    }

Mirror packages.vmware.com to a local host and point the vmwaretools class at it.

    class { 'vmwaretools':
      yum_server            => 'http://yumserver.example.lan',
      yum_path              => '/yumdir/v2.3.0',
      just_prepend_yum_path => true,
    }

Turn off configuration of the software repository so that some other tool (ie RHN Satellite) or class can take care of it.

    class { 'vmwaretools':
      manage_repository => false,
    }

Notes
-----

* Only tested on CentOS 5.5+ and CentOS 6.2+ x86_64 with 4.0latest.
* Not supported on Fedora or Debian as these distros are not supported by the OSP.
* Supports yumrepo proxy, proxy_username, proxy_password, yum priorities, yum repo
  protection, and using a local mirror for the yum_server and yum_path.
* Supports not managing the yumrepo configuration via `manage_repository => false`.
* No other VM tools (ie [Open Virtual Machine Tools](http://open-vm-tools.sourceforge.net/)) will be supported.

Issues
------

* Does not install Desktop (X Window) components.

TODO
----

* Support installation of Desktop (X Window) packages.
* Add logic to handle RHEL5 i386 PAE kernel on OSP 5.0+.

Contributing
------------

Please see DEVELOP.md for contribution information.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-vmwaretools on GitHub](https://github.com/razorsedge/puppet-vmwaretools)

[razorsedge/vmwaretools on Puppet Forge](http://forge.puppetlabs.com/razorsedge/vmwaretools)

