require 'spec_helper'

describe 'vmwaretools' do

  describe 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect do
        subject
      end.should raise_error(/Unsupported platform: foo/)
    end
  end

  describe 'on a supported osfamily, non-vmware platform' do
    let(:params) {{}}
    let :facts do {
      :osfamily => 'Redhat',
      :virtual  => 'foo'
    }
    end
    it { should_not contain_yumrepo('vmware-tools') }
    it { should_not contain_package('vmware-tools') }
    it { should_not contain_exec('vmware-uninstall-tools') }
    it { should_not contain_exec('vmware-uninstall-tools-local') }
    it { should_not contain_service('vmware-tools') }
  end

  describe 'on a supported osfamily, vmware platform' do
    let(:params) {{}}
    let :facts do {
      :osfamily => 'Redhat',  #TODO
      :virtual  => 'vmware'
    }
    end

    it 'should remove Package[VMwareTools]' do
      should contain_package('VMwareTools').with_ensure('absent')
    end
    #it { should contain_package('vmware-tools').with_name('vmware-tools-nox') }
    it { should contain_exec('vmware-uninstall-tools').with_command('/usr/bin/vmware-uninstall-tools.pl') }
    it { should contain_exec('vmware-uninstall-tools-local').with_command('/usr/local/bin/vmware-uninstall-tools.pl') }
    it { should contain_service('vmware-tools') }

    #redhatish = ['RedHat']
    redhatish = ['RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM', 'OracleLinux', 'OVS', 'OEL']
    fedoraish = ['Fedora']
    suseish = ['SLES', 'SLED', 'OpenSuSE', 'SuSE']

    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{}}
        let :facts do {
          :virtual => 'vmware',
          :osfamily => 'RedHat',
#          :operatingsystemrelease => '6',
          :operatingsystem => os
        }
        end

        it { should contain_yumrepo('vmware-tools') }
        it { should contain_package('vmware-tools').with_name('vmware-tools-nox') }
      end
    end

    describe 'for operating system Fedora' do
      let(:params) {{}}
      let :facts do {
        :virtual => 'vmware',
        :osfamily        => 'Redhat',
        :operatingsystem => 'Fedora'
      }
      end
      it { should_not contain_yumrepo('vmware-tools') }
      it { should contain_package('vmware-tools').with_name('open-vm-tools') }
    end

#    describe 'on redhat based os' do
#      let :facts do {
#        :osfamily        => 'Redhat',
#        :operatingsystem => 'Redhat'
#      }
#      end
#      it { should contain_yumrepo('vmware-tools') }
#      it { should contain_yumrepo('vmware-tools').with(
#        :desc => 'VMware Tools 4.1latest - RHEL6 x86_64',
#        :enabled => '1',
#        :gpgcheck => '1',
#        :gpgkey => 'http://packages.vmware.com/tools/VMWARE-PACKAGING-GPG-KEY.pub',
#        :baseurl => 'http://packages.vmware.com/tools/esx/4.1latest/rhel6/x86_64/',
#        :priority => '50',
#        :protect => '0'
#      )}
#    end
#
#    describe 'on suse os' do
#      let :facts do
#        {:osfamily => 'SuSE'}
#      end
#      it { should contain_yumrepo('vmware-tools') }
##      it { should contain_yumrepo('vmware-tools').with(
##        :desc => "VMware Tools ${vmwaretools_esx_version_real} - SUSE${majdistrelease} ${yum_basearch}",
##        :enabled => '1',
##        :gpgcheck => '1',
##        :gpgkey => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/VMWARE-PACKAGING-GPG-KEY.pub",
##        :baseurl => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${vmwaretools_esx_version_real}/suse${majdistrelease}/${yum_basearch}/",
##        :priority => '50',
##        :protect => '0'
##      )}
#    end

  end

end
#    it { should contain_package('vmware-tools').with(
#      :name => 'vmware-tools-nox',
#      :ensure => 'latest'
#    )}
