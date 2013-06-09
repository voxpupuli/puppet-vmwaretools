#!/usr/bin/env rspec

require 'spec_helper'

describe 'vmwaretools', :type => 'class' do

  context 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect do
        subject
      end.to raise_error(Puppet::Error, /Unsupported platform: foo/)
    end
  end

  redhatish = ['RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM', 'OracleLinux', 'OVS', 'OEL']
  fedoraish = ['Fedora']
  suseish   = ['SLES', 'SLED', 'OpenSuSE', 'SuSE']

  context 'on a supported osfamily, non-vmware platform' do
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'foo'
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
      end
    end
  end

  context 'on a supported osfamily, vmware platform' do
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'vmware'
        }
        end
        it { should contain_class('vmwaretools::repo').with(
          :tools_version         => 'latest',
          :yum_server            => 'http://packages.vmware.com',
          :yum_path              => '/tools',
          :just_prepend_yum_path => 'false',
          :priority              => '50',
          :protect               => '0',
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
      end
    end

    redhatish.each do |os|
      describe "for operating system #{os} with tools_version 3.5u3" do
        let(:params) {{ :tools_version => '3.5u3' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-nox') }
        it { should contain_service('vmware-tools').with_pattern('vmware-guestd') }
      end

      describe "for operating system #{os} with tools_version 4.0latest" do
        let(:params) {{ :tools_version => '4.0latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-nox') }
        it { should contain_service('vmware-tools').with_pattern('vmware-guestd') }
      end

      describe "for operating system #{os} with tools_version 4.1latest" do
        let(:params) {{ :tools_version => '4.1latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-nox') }
        it { should contain_service('vmware-tools').with_pattern('vmtoolsd') }
      end

      describe "for operating system #{os} with tools_version 5.0u1" do
        let(:params) {{ :tools_version => '5.0u1' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-esx-nox') }
        it { should contain_package('vmware-tools-esx-kmods') }
        it { should contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
        it { should_not contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
      end

      describe "for operating system #{os} with tools_version 5.1" do
        let(:params) {{ :tools_version => '5.1' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-esx-nox') }
        it { should contain_package('vmware-tools-esx-kmods') }
        it { should_not contain_service('vmware-tools-services').with_pattern('vmtoolsd') }
        it { should contain_service('vmware-tools-services').with_start('/sbin/start vmware-tools-services') }
      end
    end

    fedoraish.each do |os|
      describe "for operating system #{os} with tools_version 4.1latest" do
        let(:params) {{ :tools_version => '4.1latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'Redhat',
          :operatingsystemrelease => '16',
          :architecture           => 'x86_64',
          :operatingsystem        => os
        }
        end
        it 'should fail' do
          expect do
            subject
          end.to raise_error(Puppet::Error, /Unsupported platform: Fedora/)
        end
      end
    end

    suseish.each do |os|
      describe "for operating system #{os} with tools_version 4.0latest" do
        let(:params) {{ :tools_version => '4.0latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'SuSE',
          :operatingsystemrelease => '10',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_package('vmware-tools-nox') }
      end
    end
  end

  context 'on a supported operatingsystem, custom parameters' do
    let :facts do {
      :virtual                => 'vmware',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.1',
      :architecture           => 'x86_64'
    }
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
