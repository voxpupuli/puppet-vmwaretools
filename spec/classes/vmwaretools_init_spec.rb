#!/usr/bin/env rspec

require 'spec_helper'

describe 'vmwaretools', :type => 'class' do

  context 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily               => 'foo',
      :operatingsystem        => 'foo',
      :operatingsystemrelease => '1.0',
      :lsbmajdistrelease      => '1',
      :operatingsystemmajrelease => '1',
      :architecture           => 'x86_64',
      :virtual                => 'foo'
    }
    end
    it { should_not contain_class('vmwaretools::repo') }
    it { should_not contain_package('vmware-tools') }
    it { should_not contain_package('vmware-tools-nox') }
    it { should_not contain_package('vmware-tools-esx-nox') }
    it { should_not contain_package('vmware-tools-esx-kmods') }
    it { should_not contain_exec('vmware-uninstall-tools') }
    it { should_not contain_exec('vmware-uninstall-tools-local') }
    it { should_not contain_file_line('disable-tools-version') }
    it { should_not contain_service('vmware-tools') }
    it { should_not contain_service('vmware-tools-services') }
    it { should_not contain_file('/etc/udev/rules.d/99-vmware-scsi-udev.rules') }
    it { should_not contain_exec('udevrefresh') }
  end

  context 'on a supported osfamily, non-vmware platform' do
    let(:params) {{}}
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '1.0',
      :lsbmajdistrelease      => '1',
      :operatingsystemmajrelease => '1',
      :architecture           => 'x86_64',
      :virtual                => 'foo'
    }
    end
    it { should_not contain_class('vmwaretools::repo') }
    it { should_not contain_package('vmware-tools') }
    it { should_not contain_package('vmware-tools-nox') }
    it { should_not contain_package('vmware-tools-esx-nox') }
    it { should_not contain_package('vmware-tools-esx-kmods') }
    it { should_not contain_exec('vmware-uninstall-tools') }
    it { should_not contain_exec('vmware-uninstall-tools-local') }
    it { should_not contain_file_line('disable-tools-version') }
    it { should_not contain_service('vmware-tools') }
    it { should_not contain_service('vmware-tools-services') }
    it { should_not contain_file('/etc/udev/rules.d/99-vmware-scsi-udev.rules') }
    it { should_not contain_exec('udevrefresh') }
  end

  context 'on a supported osfamily, vmware platform, non-supported operatingsystem' do
    describe "for operating system Fedora" do
      let :facts do {
        :virtual                => 'vmware',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'Fedora',
        :operatingsystemrelease => '1.0',
        :lsbmajdistrelease      => '1',
        :operatingsystemmajrelease => '1',
        :architecture           => 'x86_64'
      }
      end
      it { should_not contain_class('vmwaretools::repo') }
      it { should_not contain_package('vmware-tools') }
      it { should_not contain_package('vmware-tools-nox') }
      it { should_not contain_package('vmware-tools-esx-nox') }
      it { should_not contain_package('vmware-tools-esx-kmods') }
      it { should_not contain_exec('vmware-uninstall-tools') }
      it { should_not contain_exec('vmware-uninstall-tools-local') }
      it { should_not contain_file_line('disable-tools-version') }
      it { should_not contain_service('vmware-tools') }
      it { should_not contain_service('vmware-tools-services') }
      it { should_not contain_file('/etc/udev/rules.d/99-vmware-scsi-udev.rules') }
      it { should_not contain_exec('udevrefresh') }
    end
  end

  context 'on a supported osfamily, vmware platform, default parameters' do
    let(:params) {{}}
    let :facts do {
      :virtual                   => 'vmware',
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemmajrelease => '6',
      :architecture              => 'x86_64'
    }
    end
    it { should contain_class('vmwaretools::repo').with(
      :tools_version         => 'latest',
      :reposerver            => 'http://packages.vmware.com',
      :repopath              => '/tools',
      :just_prepend_repopath => 'false',
      :priority              => '50',
      :protect               => '0',
      :gpgkey_url            => 'http://packages.vmware.com/tools/',
      :proxy                 => 'absent',
      :proxy_username        => 'absent',
      :proxy_password        => 'absent',
      :ensure                => 'present'
    )}
    it 'should remove Package[VMwareTools]' do
      should contain_package('VMwareTools').with_ensure('absent')
    end
    it { should contain_exec('vmware-uninstall-tools').with_command('/usr/bin/vmware-uninstall-tools.pl && rm -rf /usr/lib/vmware-tools') }
    it { should contain_exec('vmware-uninstall-tools-local').with_command('/usr/local/bin/vmware-uninstall-tools.pl && rm -rf /usr/local/lib/vmware-tools') }
    it { should contain_file_line('disable-tools-version').with(
      :path => '/etc/vmware-tools/tools.conf',
      :line => 'disable-tools-version = "true"'
    )}
    it { should contain_package('vmware-tools-esx-nox') }

    describe 'for osfamily RedHat and operatingsystem RedHat 5' do
      let :facts do {
        :virtual                   => 'vmware',
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemrelease    => '5.5',
        :lsbmajdistrelease         => '5',
        :operatingsystemmajrelease => '5',
        :architecture              => 'x86_64'
      }
      end
      it { should contain_class('vmwaretools::repo').with(
        :before => [ 'Package[vmware-tools-esx-nox]', 'Package[vmware-tools-esx-kmods]' ]
      )}
      it { should contain_package('vmware-tools-esx-kmods') }
      it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
      it { should contain_file('/etc/udev/rules.d/99-vmware-scsi-udev.rules').with(
        :content => "#\n# VMware SCSI devices Timeout adjustment\n#\n# Modify the timeout value for VMware SCSI devices so that\n# in the event of a failover, we don't time out.\n# See Bug 271286 for more information.\n\n\nACTION==\"add\", SUBSYSTEMS==\"scsi\", ATTRS{vendor}==\"VMware  \", ATTRS{model}==\"Virtual disk    \", RUN+=\"/bin/sh -c 'echo 180 >/sys$DEVPATH/timeout'\"\nACTION==\"add\", SUBSYSTEMS==\"scsi\", ATTRS{vendor}==\"VMware, \", ATTRS{model}==\"VMware Virtual S\", RUN+=\"/bin/sh -c 'echo 180 >/sys$DEVPATH/timeout'\"\n\n"
      ) }
      it { should contain_exec('udevrefresh').with(
        :refreshonly => true,
        :command     => '/sbin/udevcontrol reload_rules && /sbin/start_udev'
      ) }
    end

    describe 'for osfamily RedHat and operatingsystem RedHat 6' do
      let(:params) {{ :scsi_timeout => '14400' }}
      let :facts do {
        :virtual                   => 'vmware',
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemrelease    => '6.1',
        :lsbmajdistrelease         => '6',
        :operatingsystemmajrelease => '6',
        :architecture              => 'x86_64'
      }
      end
      it { should contain_class('vmwaretools::repo').with(
        :before => [ 'Package[vmware-tools-esx-nox]', 'Package[vmware-tools-esx-kmods]' ]
      )}
      it { should contain_package('vmware-tools-esx-kmods') }
      it { should_not contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
      it { should contain_file('/etc/udev/rules.d/99-vmware-scsi-udev.rules').with(
        :content => "#\n# VMware SCSI devices Timeout adjustment\n#\n# Modify the timeout value for VMware SCSI devices so that\n# in the event of a failover, we don't time out.\n# See Bug 271286 for more information.\n\n\nACTION==\"add\", SUBSYSTEMS==\"scsi\", ATTRS{vendor}==\"VMware  \", ATTRS{model}==\"Virtual disk    \", RUN+=\"/bin/sh -c 'echo 14400 >/sys$DEVPATH/timeout'\"\nACTION==\"add\", SUBSYSTEMS==\"scsi\", ATTRS{vendor}==\"VMware, \", ATTRS{model}==\"VMware Virtual S\", RUN+=\"/bin/sh -c 'echo 14400 >/sys$DEVPATH/timeout'\"\n\n"
      ) }
      it { should contain_exec('udevrefresh').with(
        :refreshonly => true,
        :command     => '/sbin/udevadm control --reload-rules && /sbin/udevadm trigger --action=add --subsystem-match=scsi'
      ) }

    end

    describe 'for osfamily SuSE and operatingsystem SLES' do
      let :facts do {
        :virtual                => 'vmware',
        :osfamily               => 'SuSE',
        :operatingsystem        => 'SLES',
        :operatingsystemrelease => '11.1',
        :lsbmajdistrelease      => '11',
        :operatingsystemmajrelease => '11',
        :architecture           => 'x86_64'
      }
      end
      it { should contain_class('vmwaretools::repo').with(
        :before => [ 'Package[vmware-tools-esx-nox]', 'Package[vmware-tools-esx-kmods-default]' ]
      )}
      it { should contain_package('vmware-tools-esx-kmods-default') }
      it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end

    describe 'for osfamily Debian and operatingsystem Ubuntu' do
      let :facts do {
        :os                     => {
          :family  => 'Debian',
          :name    => 'Ubuntu',
          :release => {
            :full => '12.04'
          }
        },
        :virtual                => 'vmware',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '12.04',
        :operatingsystemmajrelease => '12',
        :architecture           => 'amd64',
        :lsbdistcodename        => 'precise',
        :lsbdistid              => 'Ubuntu',
        :puppetversion          => Puppet.version
      }
      end
      it { should contain_class('vmwaretools::repo').with(
        :before => [ 'Package[vmware-tools-esx-nox]', 'Package[vmware-tools-esx-kmods-3.8.0-29-generic]' ]
      )}
      it { should contain_package('vmware-tools-esx-kmods-3.8.0-29-generic') }
      it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end
  end

  context 'on a supported operatingsystem, vmware platform, custom parameters' do
    let :facts do {
      :virtual                   => 'vmware',
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.1',
      :operatingsystemmajrelease => '6',
      :architecture              => 'x86_64'
    }
    end

    describe 'tools_version => 3.5u3' do
      let(:params) {{ :tools_version => '3.5u3' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('3.5u3') }
      it { should contain_package('vmware-tools-nox') }
      it { should contain_service('vmware-tools').with_pattern('vmware-guestd') }
    end

    describe 'tools_version => 4.0u4' do
      let(:params) {{ :tools_version => '4.0u4' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('4.0u4') }
      it { should contain_package('vmware-tools-nox') }
      it { should contain_service('vmware-tools').with_pattern('vmware-guestd') }
    end

    describe 'tools_version => 4.1' do
      let(:params) {{ :tools_version => '4.1' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('4.1') }
      it { should contain_package('vmware-tools-nox') }
      it { should contain_service('vmware-tools').with_pattern('vmtoolsd') }
    end

    describe 'tools_version => 5.0 and operatingsystem => RedHat 6' do
      let(:params) {{ :tools_version => '5.0' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('5.0') }
      it { should contain_package('vmware-tools-esx-nox') }
      it { should contain_package('vmware-tools-esx-kmods') }
      it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end

    describe 'tools_version => 5.1 and operatingsystem => RedHat 6' do
      let(:params) {{ :tools_version => '5.1' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('5.1') }
      it { should contain_package('vmware-tools-esx-nox') }
      it { should contain_package('vmware-tools-esx-kmods') }
      it { should_not contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end

    describe 'tools_version => 5.5p02 and operatingsystem => RedHat 6' do
      let(:params) {{ :tools_version => '5.5p02' }}
      it { should contain_class('vmwaretools::repo').with_tools_version('5.5p02') }
      it { should contain_package('vmware-tools-esx-nox') }
      it { should contain_package('vmware-tools-esx-kmods') }
      it { should_not contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end

    describe 'tools_version => 5.1 and operatingsystem => SLES' do
      let(:params) {{ :tools_version => '5.1' }}
      let :facts do {
        :virtual                => 'vmware',
        :osfamily               => 'SuSE',
        :operatingsystem        => 'SLES',
        :operatingsystemrelease => '11.1',
        :lsbmajdistrelease      => '11',
        :operatingsystemmajrelease => '11',
        :architecture           => 'x86_64'
      }
      end
      it { should contain_class('vmwaretools::repo').with_tools_version('5.1') }
      it { should contain_package('vmware-tools-esx-nox') }
      it { should contain_package('vmware-tools-esx-kmods-default') }
      it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
      it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
    end

    describe 'disable_tools_version => false' do
      let(:params) {{ :disable_tools_version => false }}
      it { should contain_file_line('disable-tools-version').with(
        :path => '/etc/vmware-tools/tools.conf',
        :line => 'disable-tools-version = "false"'
      )}
    end

    describe 'manage_repository => false' do
      let(:params) {{ :manage_repository => false }}
      it { should_not contain_class('vmwaretools::repo') }
    end

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_class('vmwaretools::repo').with_ensure('absent') }
      it { should contain_package('vmware-tools-esx-nox').with_ensure('absent') }
      it { should contain_package('vmware-tools-esx-kmods').with_ensure('absent') }
      it { should contain_file_line('disable-tools-version') }
      it { should contain_service('vmware-tools-services').with_ensure('stopped') }
    end
  end

end
