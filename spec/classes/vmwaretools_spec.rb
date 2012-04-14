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

  redhatish = ['RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM', 'OracleLinux', 'OVS', 'OEL']
  fedoraish = ['Fedora']
  suseish   = ['SLES', 'SLED', 'OpenSuSE', 'SuSE']

  describe 'on a supported osfamily, non-vmware platform' do
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'foo'
        }
        end
        it { should_not contain_yumrepo('vmware-tools') }
        it { should_not contain_package('vmware-tools') }
        it { should_not contain_exec('vmware-uninstall-tools') }
        it { should_not contain_exec('vmware-uninstall-tools-local') }
        it { should_not contain_service('vmware-tools') }
      end
    end
  end

  describe 'on a supported osfamily, vmware platform' do
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'vmware'
        }
        end
        it 'should remove Package[VMwareTools]' do
          should contain_package('VMwareTools').with_ensure('absent')
        end
        it { should contain_exec('vmware-uninstall-tools').with_command('/usr/bin/vmware-uninstall-tools.pl && rm -rf /usr/lib/vmware-tools') }
        it { should contain_exec('vmware-uninstall-tools-local').with_command('/usr/local/bin/vmware-uninstall-tools.pl && rm -rf /usr/local/lib/vmware-tools') }
        it { should contain_service('vmware-tools').with_pattern('vmtoolsd')  }
      end
    end

    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{ :tools_version => '3.5u3' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 3.5u3 - RHEL6 i686',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => 'http://packages.vmware.com/tools/VMWARE-PACKAGING-GPG-KEY.pub',
          :baseurl  => 'http://packages.vmware.com/tools/esx/3.5u3/rhel6/i686/',
          :priority => '50',
          :protect  => '0'
        )}
        it { should contain_package('vmware-tools').with_name('vmware-tools-nox') }
      end
    end

    fedoraish.each do |os|
      describe "for operating system #{os}" do
        #let(:params) {{ :tools_version => '4.1latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'Redhat',
          :operatingsystemrelease => '16',
          :architecture           => 'x86_64',
          :operatingsystem        => os
        }
        end
        it { should_not contain_yumrepo('vmware-tools') }
        it { should contain_package('vmware-tools').with_name('open-vm-tools') }
      end
    end

    suseish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{ :tools_version => '4.0latest' }}
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'SuSE',
          :operatingsystemrelease => '10',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 4.0latest - SUSE10 i586',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => 'http://packages.vmware.com/tools/VMWARE-PACKAGING-GPG-KEY.pub',
          :baseurl  => 'http://packages.vmware.com/tools/esx/4.0latest/suse10/i586/',
          :priority => '50',
          :protect  => '0'
        )}
        it { should contain_package('vmware-tools').with_name('vmware-tools-nox') }
      end
    end
  end
end
