require 'spec_helper'

describe 'vmwaretools' do

  describe 'on vmware virtual' do
    let(:facts) { { :virtual => 'vmware' } }

    it { should include_class('vmwaretools::params') }

    describe 'on redhat os' do
      let :facts do {
        :operatingsystem => 'Redhat',
        :architecture    => 'x86_64'
      }
      end
#      it { should contain_yumrepo('vmware-tools') }
#      it { should contain_yumrepo('vmware-tools').with(
#        :desc     => 'VMware Tools 4.1latest - RHEL6 x86_64',
#        :enabled  => '1',
#        :gpgcheck => '1',
#        :gpgkey   => 'http://packages.vmware.com/tools/VMWARE-PACKAGING-GPG-KEY.pub',
#        :baseurl  => 'http://packages.vmware.com/tools/esx/4.1latest/rhel6/x86_64/',
#        :priority => '50',
#        :protect  => '0'
#      )}
    end

    describe 'on suse os' do
      let :facts do
        {:operatingsystem => 'SuSE'}
      end
#      it { should contain_yumrepo('vmware-tools') }
#      it { should contain_yumrepo('vmware-tools').with(
#        :desc     => "VMware Tools ${vmwaretools_esx_version_real} - SUSE${majdistrelease} ${yum_basearch}",
#        :enabled  => '1',
#        :gpgcheck => '1',
#        :gpgkey   => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/VMWARE-PACKAGING-GPG-KEY.pub",
#        :baseurl  => "${vmwaretools::params::yum_server}${vmwaretools::params::yum_path}/esx/${vmwaretools_esx_version_real}/suse${majdistrelease}/${yum_basearch}/",
#        :priority => '50',
#        :protect  => '0'
#      )}
    end

    describe 'on any other os' do
      let :facts do
        {:operatingsystem => 'foo'}
      end
      it 'should not fail' do
      end
    end

    it 'should remove Package[VMwareTools]' do
      should contain_package('VMwareTools').with_ensure('absent')
    end 

    it { should contain_package('vmware-tools').with(
      :name   => 'vmware-tools-nox',
      :ensure => 'latest'
    )}

    it { should contain_exec('vmware-uninstall-tools').with(
      :command => '/usr/bin/vmware-uninstall-tools.pl'
    )}

    it { should contain_exec('vmware-uninstall-tools-local').with(
      :command => '/usr/local/bin/vmware-uninstall-tools.pl'
    )}

    it { should contain_service('vmware-tools') }

  end

  describe 'on non-vmware platform' do
    let(:facts) { { :virtual => 'foo' } }
    it { should_not include_class('vmwaretools::params') }
    it { should_not contain_yumrepo('vmware-tools') }
    it { should_not contain_package('vmware-tools') }
    it { should_not contain_exec('vmware-uninstall-tools') }
    it { should_not contain_exec('vmware-uninstall-tools-local') }
    it { should_not contain_service('vmware-tools') }
  end

end
