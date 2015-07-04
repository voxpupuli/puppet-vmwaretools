#!/usr/bin/env rspec

require 'spec_helper'

describe 'vmwaretools::repo', :type => 'class' do

  context 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily               => 'foo',
      :operatingsystem        => 'foo',
      :operatingsystemrelease => '1.0'
    }
    end
    #it { should run.with_params("Your operating system #{osfamily} is unsupported and will not have the VMware Tools OSP installed.").and_return('Your operating system foo is unsupported and will not have the VMware Tools OSP installed.') }
    it { should_not contain_yumrepo('vmware-tools') }
    it { should_not contain_file('/etc/yum.repos.d/vmware-tools.repo') }
    it { should_not contain_zypprepo('vmware-tools') }
    it { should_not contain_file('/etc/zypp/repos.d/vmware-tools.repo') }
  end

  redhatish = ['RedHat', 'CentOS', 'Scientific', 'OracleLinux', 'OEL']
  suseish   = ['SLES', 'SLED']

  context 'on a supported osfamily, non-vmware platform' do
    ({'RedHat' => 'CentOS', 'SuSE' => 'SLES', 'Debian' => 'Ubuntu'}).each do |osf, os|
      describe "for osfamily #{osf} operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => osf,
          :operatingsystem        => os,
          :operatingsystemrelease => '1.0',
          :virtual                => 'foo'
        }
        end
        it { should_not contain_yumrepo('vmware-tools') }
        it { should_not contain_file('/etc/yum.repos.d/vmware-tools.repo') }
        it { should_not contain_zypprepo('vmware-tools') }
        it { should_not contain_file('/etc/zypp/repos.d/vmware-tools.repo') }
        it { should_not contain_apt__source('vmware-tools') }
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
        it { should contain_zypprepo('vmware-tools').with(
          :descr       => 'VMware Tools latest - sles10 i586',
          :enabled     => '1',
          :gpgcheck    => '1',
          :gpgkey      => 'http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub',
          :baseurl     => 'http://packages.vmware.com/tools/esx/latest/sles10/i586/',
          :priority    => '50',
          :autorefresh => '1',
          :notify      => 'Exec[vmware-import-gpgkey]'
        )}
        it { should contain_file('/etc/zypp/repos.d/vmware-tools.repo') }
        it { should contain_exec('vmware-import-gpgkey') }
      end
    end

    describe "for operating system Ubuntu" do
      let(:pre_condition) { "class { 'apt': }" }
      let :facts do {
        :virtual                => 'vmware',
        :osfamily               => 'Debian',
        :operatingsystemrelease => '12.04',
        :architecture           => 'amd64',
        :operatingsystem        => 'Ubuntu',
        :lsbdistcodename        => 'precise',
        :lsbdistid              => 'Ubuntu'
      }
      end
      it { should contain_apt__source('vmware-tools').with(
        :comment     => 'VMware Tools latest - ubuntu precise',
        :ensure      => 'present',
        :location    => 'http://packages.vmware.com/tools/esx/latest/ubuntu',
        :key_source  => 'http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub',
       #:key         => '0xC0B5E0AB66FD4949',
        :key         => '36E47E1CC4DCC5E8152D115CC0B5E0AB66FD4949',
        :include_src => false
      )}
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

    describe 'reposerver => http://localhost:8000' do
      let(:params) {{ :reposerver => 'http://localhost:8000' }}
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://localhost:8000/tools/esx/latest/rhel6/x86_64/'
      )}
    end

    describe 'repopath => /some/path' do
      let(:params) {{ :repopath => '/some/path' }}
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://packages.vmware.com/some/path/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://packages.vmware.com/some/path/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://packages.vmware.com/some/path/'
      )}
    end

    describe 'gpgkey_url => http://localhost:8000/custom/path/' do
      let(:params) {{ :gpgkey_url => 'http://localhost:8000/custom/path/' }}
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/custom/path/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/custom/path/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
      )}
    end

    describe 'reposerver => http://localhost:8000 and repopath => /some/path' do
      let :params do {
        :reposerver => 'http://localhost:8000',
        :repopath   => '/some/path'
      }
      end
      it { should contain_yumrepo('vmware-tools').with(
        :gpgkey   => "http://localhost:8000/some/path/VMWARE-PACKAGING-GPG-DSA-KEY.pub\n    http://localhost:8000/some/path/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
        :baseurl  => 'http://localhost:8000/some/path/'
      )}
    end

    describe 'reposerver => http://localhost:8000 and repopath => /some/path and just_prepend_repopath => true' do
      let :params do {
        :reposerver            => 'http://localhost:8000',
        :repopath              => '/some/path',
        :just_prepend_repopath => true
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
