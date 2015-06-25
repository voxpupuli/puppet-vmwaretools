#!/usr/bin/env rspec

require 'spec_helper'

describe 'vmwaretools::ntp', :type => 'class' do

  describe 'without base class defined, non-vmware platform' do
    let(:params) {{}}
    let :facts do {
      :virtual => 'foo',
    }
    end
    it { should_not contain_exec('vmware-tools.syncTime') }
  end

  describe 'without base class defined, vmware platform' do
    let(:params) {{}}
    let :facts do {
      :virtual => 'vmware',
    }
    end
    it 'should fail' do
      expect {
       should raise_error(Puppet::Error, /The class vmwaretools must be declared/)
      }
    end
  end

  describe 'with base class defined, on a supported osfamily, non-vmware platform' do
    let(:pre_condition) { "class { 'vmwaretools': package => 'RandomData' }" }
    let(:params) {{}}
    let :facts do {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemmajrelease => '6',
      :virtual                   => 'foo'
    }
    end
    it { should_not contain_exec('vmware-tools.syncTime') }
  end

  describe 'with base class defined, on a supported osfamily, vmware platform' do
    describe "for service_pattern vmware-guestd" do
      let :pre_condition do
        "class { 'vmwaretools':
          package       => 'RandomData',
          tools_version => '3.0u5',
        }"
      end
      let(:params) {{}}
      let :facts do {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '6',
        :virtual                   => 'vmware'
      }
      end
      it { should contain_exec('vmware-tools.syncTime').with_command('vmware-guestd --cmd "vmx.set_option synctime 1 0" || true') }
    end

    describe "for service_pattern vmtoolsd" do
      let :pre_condition do
        "class { 'vmwaretools':
          package       => [ 'RandomData', 'OtherData', ],
          tools_version => '4.1latest',
        }"
      end
      let(:params) {{}}
      let :facts do {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '6',
        :virtual                   => 'vmware'
      }
      end
      it { should contain_exec('vmware-tools.syncTime').with_command('vmware-toolbox-cmd timesync disable') }
    end
  end

end
