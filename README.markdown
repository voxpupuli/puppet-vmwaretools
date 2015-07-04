#VMware Tools Operating System Specific Packages

[![Build Status](https://secure.travis-ci.org/razorsedge/puppet-vmwaretools.png?branch=master)](http://travis-ci.org/razorsedge/puppet-vmwaretools)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with this module](#setup)
    * [What this module affects](#what-this-module-affects)
    * [What this module requires](#requirements)
    * [Beginning with this module](#beginning-with-this module)
    * [Upgrading](#upgrading)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
    * [OS Support](#os-support)
    * [Notes](#notes)
    * [Issues](#issues)
6. [Development - Guide for contributing to the module](#development)

##Overview

This Puppet module manages the installation and configuration of the [Operating System Specific Packages](http://packages.vmware.com/) for VMware Tools.  This allows you to use your operating system's native tools to install and update the VMware Tools.

##Module Description

This Puppet module manages the installation and configuration of the [Operating System Specific Packages](http://packages.vmware.com/) for VMware Tools.  OSPs are an alternative to the existing mechanism used to install VMware Tools through the VMware vSphere™ Client. With OSPs you can use the native update mechanisms of your operating system to download, install, and manage VMware Tools. With OSPs you can manage VMware Tools from the virtual machine as you would other standard software. VMware Tools OSPs occupy a smaller amount of disk space than the tar installer used with vSphere Client, which makes package installation or uninstallation fast.

##Setup

###What this module affects

* Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
* Installs a VMware package repository (defaults to the 'latest' package repository).
* Installs the OSP VMware Tools.
* Starts the vmware-tools service.

###Requirements

You need to be running a virtual machine on the VMware platform and on an operating system supported by VMware's OSPs for this module to do anything.

###Beginning with this module

It is safe for all nodes to use this declaration.  Any non-VMware or unsupported system will skip installtion of the tools.
```puppet
include ::vmwaretools
```

###Upgrading

####Deprecation Warning

The parameters `yum_server`, `yum_path`, and `just_prepend_yum_path` will be renamed to be `reposerver`, `repopath`, and `just_prepend_repopath` respectively in version 5.0.0 of this module.  Please be aware that your manifests may need to change to account for the new syntax.

This:

```puppet
class { '::vmwaretools':
  yum_server            => 'http://server.example.lan',
  yum_path              => '/dir/v2.3.0',
  just_prepend_yum_path => true,
}
```

would become this:

```puppet
class { '::vmwaretools':
  reposerver            => 'http://server.example.lan',
  repopath              => '/dir/v2.3.0',
  just_prepend_repopath => true,
}
```

##Usage

All interaction with the vmwaretools module can be done through the main vmwaretools class. This means you can simply toggle the options in ::vmwaretools to have full functionality of the module.

To set the version to install, set the following parameter:

```puppet
class { '::vmwaretools':
  tools_version => '4.0u3',
}
```

Mirror packages.vmware.com to a local host and point the vmwaretools class at it.

```puppet
class { '::vmwaretools':
  reposerver            => 'http://server.example.lan',
  repopath              => '/dir/v2.3.0',
  just_prepend_repopath => true,
}
```

Turn off configuration of the software repository so that some other tool (ie RHN Satellite) or class can take care of it.

```puppet
class { '::vmwaretools':
  manage_repository => false,
}
```

##Reference

###Classes

####Public Classes

* vmwaretools: Installs the VMware Tools Operating System Specific Packages.
* vmwaretools::ntp: Turns off syncTime via the vmware-tools API and should be accompanied by a running NTP client on the guest.

####Private Classes

* vmwaretools::repo: Installs the VMware Tools software repository.

###Parameters

The following parameters are available in the vmwaretools module:

####`ensure`

Ensure if present or absent.
Default: present

####`autoupgrade`

Upgrade package automatically, if there is a newer version.
Default: false

####`package`

Name of the package.  Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

####`service_ensure`

Ensure if service is running or stopped.
Default: running

####`service_name`

Name of openvmtools service.  Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

####`service_enable`

Start service at boot.
Default: true

####`service_hasstatus`

Service has status command.  Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

####`service_hasrestart`

Service has restart command.
Default: true

####`tools_version`

The version of VMware Tools to install.  Possible values can be found here: http://packages.vmware.com/tools/esx/index.html
Default: latest

####`disable_tools_version`

Whether to report the version of the tools back to vCenter/ESX.
Default: true (ie do not report)

####`manage_repository`

Whether to allow the repo to be manged by the module or out of band (ie RHN Satellite).
Default: true (ie let the module manage it)

####`reposerver`

The server which holds the YUM repository.  Customize this if you mirror public YUM repos to your internal network.
Default: http://packages.vmware.com

####`repopath`

The path on *reposerver* where the repository can be found.  Customize this if you mirror public YUM repos to your internal network.
Default: /tools

####`just_prepend_repopath`

Whether to prepend the overridden *repopath* onto the default *repopath* or completely replace it.  Only works if *repopath* is specified.
Default: 0 (false)

####`gpgkey_url`
The URL where the public GPG key resides for the repository NOT including the GPG public key file itself (ending with a trailing /).
Default: ${reposerver}${repopath}/

####`priority`

Give packages in this YUM repository a different weight.  Requires yum-plugin-priorities to be installed.
Default: 50

####`protect`

Protect packages in this YUM repository from being overridden by packages in non-protected repositories.
Default: 0 (false)

####`proxy`

The URL to the proxy server for this repository.
Default: absent

####`proxy_username`

The username for the proxy.
Default: absent

####`proxy_password`

The password for the proxy.
Default: absent

##Limitations

###OS Support:

VMware Tools Operating System Specific Packages official [supported guest operating systems](http://packages.vmware.com/) are available for these operating systems:

* Community ENTerprise Operating System (CentOS)
  * 4.0 through 6.x
* Red Hat Enterprise Linux
  * 3.0 through 6.x
* SUSE Linux Enterprise Server
  * 9 through 11
* SUSE Linux Enterprise Desktop
  * 10 through 11
* Ubuntu Linux
  * 8.04 through 12.04

###Notes:

* Only tested on CentOS 5.5+ and CentOS 6.2+ x86_64 with 4.0latest.
* Not supported on Fedora or Debian as these distros are not supported by the OSP.
* Not supported on RHEL/CentOS/OEL 7+ or SLES 12 as VMware is [recommending
  open-vm-tools](http://kb.vmware.com/kb/2073803) instead.  Use
  [razorsedge/openvmtools](https://forge.puppetlabs.com/razorsedge/openvmtools)
  instead.
* Supports repo proxy, proxy_username, proxy_password, priorities, yum repo
  protection, and using a local mirror for the reposerver and repopath.
* Supports not managing the repo configuration via `manage_repository => false`.
* No other VM tools (ie [Open Virtual Machine
  Tools](http://open-vm-tools.sourceforge.net/)) will be supported.

###Issues:

* Does not install Desktop (X Window) components.
* Does not handle RHEL5 i386 PAE kernel on OSP 5.0+.

##Development

Please see [DEVELOP.md](DEVELOP.md) for information on how to contribute.

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

Licensed under the Apache License, Version 2.0.

[razorsedge/puppet-vmwaretools on GitHub](https://github.com/razorsedge/puppet-vmwaretools)

[razorsedge/vmwaretools on Puppet Forge](https://forge.puppetlabs.com/razorsedge/vmwaretools)

