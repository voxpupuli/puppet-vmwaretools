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
        it { should_not contain_yumrepo('vmware-tools') }
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 3.5u3 - rhel6 i686',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/3.5u3/rhel6/i686/',
          :priority => '50',
          :protect  => '0'
        )}
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 4.0latest - rhel6 i686',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/4.0latest/rhel6/i686/',
          :priority => '50',
          :protect  => '0'
        )}
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 4.1latest - rhel6 i686',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/4.1latest/rhel6/i686/',
          :priority => '50',
          :protect  => '0'
        )}
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 5.0u1 - rhel6 i386',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/5.0u1/rhel6/i386/',
          :priority => '50',
          :protect  => '0'
        )}
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 5.1 - rhel6 i386',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/5.1/rhel6/i386/',
          :priority => '50',
          :protect  => '0'
        )}
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
        #it { should_not contain_yumrepo('vmware-tools') }
        #it { should contain_package('vmware-tools').with_name('open-vm-tools') }
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
        it { should contain_yumrepo('vmware-tools').with(
          :descr    => 'VMware Tools 4.0latest - suse10 i586',
          :enabled  => '1',
          :gpgcheck => '1',
          :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl  => 'http://packages.vmware.com/tools/esx/4.0latest/suse10/i586/',
          :priority => '50',
          :protect  => '0'
        )}
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

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_yumrepo('vmware-tools').with_enabled('0') }
     #it { should contain_package('vmware-tools').with_ensure('absent') }
     #it { should contain_package('vmware-tools-nox').with_ensure('absent') }
      it { should contain_package('vmware-tools-esx-nox').with_ensure('absent') }
      it { should contain_package('vmware-tools-esx-kmods').with_ensure('absent') }
      it { should contain_file_line('disable-tools-version') }
     #it { should contain_service('vmware-tools').with_ensure('stopped') }
      it { should contain_service('vmware-tools-services').with_ensure('stopped') }
    end

    describe 'yum_server => http://localhost:8000' do
      let(:params) {{ :yum_server => 'http://localhost:8000' }}
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://localhost:8000/tools/esx/latest/rhel6/x86_64/'
      )}
    end

    describe 'yum_path => /some/path' do
      let(:params) {{ :yum_path => '/some/path' }}
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://packages.vmware.com/some/path/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/some/path/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://packages.vmware.com/some/path/'
      )}
    end

    describe 'yum_server => http://localhost:8000 and yum_path => /some/path' do
      let :params do {
        :yum_server => 'http://localhost:8000',
        :yum_path   => '/some/path'
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/some/path/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/some/path/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://localhost:8000/some/path/'
      )}
    end

    describe 'yum_server => http://localhost:8000 and yum_path => /some/path and just_prepend_yum_path => true' do
      let :params do {
        :yum_server            => 'http://localhost:8000',
        :yum_path              => '/some/path',
        :just_prepend_yum_path => true
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/some/path/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/some/path/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://localhost:8000/some/path/esx/latest/rhel6/x86_64/'
      )}
    end

    describe 'manage_repository => false' do
      let :params do {
        :manage_repository => false
      }
      end
      it { should_not contain_yumrepo('vmware-tools') }
    end
  end
end
