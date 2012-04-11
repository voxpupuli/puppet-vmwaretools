Puppet VMware Tools OSP Module
==============================

[![Build Status](https://secure.travis-ci.org/runningman/puppet-vmwaretools.png?branch=param_class)](http://travis-ci.org/runningman/puppet-vmwaretools)

Introduction
------------

This module manages the installation of the [VMware Operating System Specific Packages](http://packages.vmware.com/) for VMware tools.

Actions:

* Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
* Installs a vmware YUM repository, if needed.
* Installs the OSP or open vmware tools.
* Starts the vmware-tools service.

OS Support:

* RedHat family - tested on CentOS 5.5 and CentOS 6.2
* SuSE family   - untested (initial support for yumrepo)
* Ubuntu        - presently unsupported
* Debian        - presently unsupported

Class documentation is available via puppetdoc.

Examples
--------

    include vmwaretools

    class { 'vmwaretools': }

    class { 'vmwaretools':
      tools_version => '4.0u3',
      autoupgrade   => true,
    }

Notes
-----

* Only tested on CentOS 5.5 and CentOS 6.2.

Issues
------

* Does not yet work with version 5.0 OSP tools.
* Does not install Desktop (X Window) components.

TODO
----

* Support installation of Desktop packages.

Copyright
---------

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

