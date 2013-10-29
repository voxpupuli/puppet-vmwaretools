#!/usr/bin/env rspec

require 'spec_helper'

describe 'vmwaretools::repo', :type => 'class' do

  context 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    #it { should run.with_params("Your operating system #{osfamily} is unsupported and will not have the VMware Tools installed.").and_return('Your operating system foo is unsupported and will not have the VMware Tools installed.') }
    it { should_not contain_yumrepo('vmware-tools') }
    it { should_not contain_file('/etc/yum.repos.d/vmware-tools.repo') }
#    it do
#      expect do
#        subject
#      end.to raise_error(Puppet::Error, /Unsupported platform: foo/)
#    end
  end

  redhatish = ['RedHat', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'PSBM', 'OracleLinux', 'OVS', 'OEL']
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
        it { should_not contain_file('/etc/yum.repos.d/vmware-tools.repo') }
      end
    end
  end

  context 'on a supported osfamily, vmware platform, default parameters' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.1',
          :architecture           => 'x86_64',
          :operatingsystem        => os
        }
        end
        it { should contain_yumrepo('vmware-tools').with(
          :descr           => 'VMware Tools latest - rhel6 x86_64',
          :enabled         => '1',
          :gpgcheck        => '1',
          :gpgkey          => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl         => 'http://packages.vmware.com/tools/esx/latest/rhel6/x86_64/',
          :priority        => '50',
          :protect         => '0',
          :proxy           => 'absent',
          :proxy_username  => 'absent',
          :proxy_password  => 'absent'
        )}
        it { should contain_file('/etc/yum.repos.d/vmware-tools.repo') }
      end
    end

    suseish.each do |os|
      describe "for operating system #{os}" do
        let :facts do {
          :virtual                => 'vmware',
          :osfamily               => 'SuSE',
          :operatingsystemrelease => '10',
          :architecture           => 'i386',
          :operatingsystem        => os
        }
        end
        it { should contain_yumrepo('vmware-tools').with(
          :descr           => 'VMware Tools latest - suse10 i586',
          :enabled         => '1',
          :gpgcheck        => '1',
          :gpgkey          => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
          :baseurl         => 'http://packages.vmware.com/tools/esx/latest/suse10/i586/',
          :priority        => '50',
          :protect         => '0',
          :proxy           => 'absent',
          :proxy_username  => 'absent',
          :proxy_password  => 'absent'
        )}
        it { should contain_file('/etc/yum.repos.d/vmware-tools.repo') }
      end
    end
  end

  context 'on a supported operatingsystem, vmware platform, custom parameters' do
    let :facts do {
      :virtual                => 'vmware',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.1',
      :architecture           => 'x86_64'
    }
    end

    describe 'tools_version => 5.1' do
      let(:params) {{ :tools_version => '5.1' }}
      it { should contain_yumrepo('vmware-tools').with(
        :descr    => 'VMware Tools 5.1 - rhel6 x86_64',
        :gpgkey   => "http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://packages.vmware.com/tools/esx/5.1/rhel6/x86_64/'
      )}
    end

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_yumrepo('vmware-tools').with_enabled('0') }
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

    describe 'proxy => http://proxy:8080/' do
      let :params do {
        :proxy => 'http://proxy:8080/'
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :proxy => 'http://proxy:8080/'
      )}
    end

    describe 'proxy_username => someuser' do
      let :params do {
        :proxy_username => 'someuser'
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :proxy_username => 'someuser'
      )}
    end

    describe 'proxy_password => somepasswd' do
      let :params do {
        :proxy_password => 'somepasswd'
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :proxy_password => 'somepasswd'
      )}
    end
  end

end
