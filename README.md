Puppet VMware Tools OSP Module
==============================

Introduction
------------

This module manages the installation of the [VMware Operating System Specific Packages](http://packages.vmware.com/) for VMware tools.

Actions:

* Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
* Installs a vmware YUM repository, if needed.
* Installs the OSP or open vmware tools.
* Starts the vmware-tools service.

Class documentation is available via puppetdoc.

Examples
--------

    include vmware-tools

Issues
------

* ??

Copyright
---------

Copyright (C) 2011 Mike Arnold <mike@razorsedge.org>

