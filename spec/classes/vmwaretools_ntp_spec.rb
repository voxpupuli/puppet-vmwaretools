require 'spec_helper'

describe 'vmwaretools::ntp' do
  describe 'without base class defined, vmware platform' do
    let(:params) {{}}
    let :facts do {
      :virtual => 'vmware',
    }
    end
    it 'should fail' do
      expect {
        subject
      }.to raise_error(/The class vmwaretools must be declared/)
    end
  end

  describe 'without base class defined, non-vmware platform' do
    let(:params) {{}}
    let :facts do {
      :virtual => 'foo',
    }
    end
    it { should_not contain_exec('vmware-tools.syncTime') }
  end

  describe 'on a non-supported osfamily' do
    let :pre_condition do
      "class { 'vmwaretools': }"
    end
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect {
        subject
      }.to raise_error(Puppet::Error, /Unsupported platform: foo/)
    end
  end

  describe 'on a supported osfamily, non-vmware platform' do
    let :pre_condition do
      "class { 'vmwaretools': }"
    end
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'foo'
        }
        end
        it { should_not contain_exec('vmware-tools.syncTime') }
      end
    end
  end

  describe 'on a supported osfamily, vmware platform' do
    let :pre_condition do
      "class { 'vmwaretools': }"
    end
    (['RedHat', 'SuSE']).each do |osf|
      describe "for osfamily #{osf}" do
        let(:params) {{}}
        let :facts do {
          :osfamily => osf,
          :virtual  => 'vmware'
        }
        end
        it { should contain_exec('vmware-tools.syncTime').with_command('vmware-toolbox-cmd timesync disable') }
      end
    end
  end
end
