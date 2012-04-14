require 'spec_helper'

describe 'vmwaretools::ntp' do
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
