#!/usr/bin/env rspec
require 'spec_helper'
require 'facter'
describe 'vmware fact' do
  let (:facts) do {:macaddress => 'aa:bb:66:55:dd:22'}  end
  context 'on a physical host' do
    it 'should set the vmware fact to nil' do
      Facter.fact(:virtual).stubs(:value).returns(:physical)
      Facter.fact(:vmware).value.should == nil
    end
    it 'should set the vmware_patchlevel fact to nil' do
      Facter.fact(:virtual).stubs(:value).returns(:virtual)
      Facter.fact(:vmware_patchlevel).value.should == nil
    end
  end
  context 'on a non-vmware virtual host' do
    it 'should set the vmware fact to nil' do
      Facter.fact(:virtual).stubs(:value).returns(:virtual)
      Facter.fact(:vmware).value.should == nil
    end
    it 'should set the vmware_patchlevel fact to nil' do
      Facter.fact(:virtual).stubs(:value).returns(:virtual)
      Facter.fact(:vmware_patchlevel).value.should == nil
    end
  end

  context 'on a vmware host' do
    before :each do
      Facter.clear
      Facter.fact(:macaddress).stubs(:value).returns('a8:20:66:55:48:38')
      Facter.fact(:virtual).stubs(:value).returns(:vmware)
    end

    context 'not running linux' do
      before :each do
        Facter.fact(:virtual).stubs(:value).returns(:vmware)
        Facter.fact(:kernel).stubs(:value).returns(:unicorn)
      end
      it 'should be vmware-unknown' do
        Facter.fact(:vmware).value.should == 'vmware-unknown'
      end
      it 'should set the vmware_patchlevel fact to unknown' do
        Facter.fact(:vmware_patchlevel).value.should == 'unknown'
      end
    end

    context 'running linux' do
      context 'without dmidecode' do
        before :each do
          Facter.fact(:virtual).stubs(:value).returns(:vmware)
          Facter.fact(:kernel).stubs(:value).returns(:linux)
        end
        it 'should be vmware-linux' do
          Facter::Util::Resolution.stubs(:exec)
          Facter::Util::Resolution.stubs(:exec).with('which dmidecode').returns(nil)
          Facter.fact(:vmware).value.should == 'vmware-linux'
        end
        it 'should set the vmware_patchlevel fact to unknown' do
          Facter.fact(:vmware_patchlevel).value.should == 'unknown'
        end
      end

      context 'with dmidecode' do
        before :each do
          Facter.fact(:virtual).stubs(:value).returns(:vmware)
          Facter.fact(:kernel).stubs(:value).returns(:linux)
          Facter::Util::Resolution.stubs(:exec)
          Facter::Util::Resolution.stubs(:exec).with('which dmidecode').returns('/usr/sbin/dmidecode')
        end
        context 'but we cannot tell what version of vmware we are on' do
          it 'should be vmware-linux' do
            Facter.clear
          Facter.fact(:virtual).stubs(:value).returns(:vmware)
            #Facter::Util::Resolution.stubs(:exec)
            Facter.fact(:kernel).stubs(:value).returns(:linux)
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns('bogus')
            Facter::Util::Resolution.stubs(:exec).with('which dmidecode').returns('/usr/sbin/dmidecode')
            Facter.fact(:vmware).value.should == 'vmware-linux'
          end
          it 'should set the vmware_patchlevel fact to unknown' do
            Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'but the result is nil' do
          it 'should return vmware-linux' do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns(nil)
            Facter.fact(:vmware).value.should == 'vmware-linux'
          end
        end
        context 'but the result is useless' do
          it 'should return vmware-linux' do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns('No SMBIOS nor DMI entry point found, sorry.')
            Facter.fact(:vmware).value.should == 'vmware-linux'
          end
        end


        context 'when running on esxi 2.5 - insufficient data to deep-dive this. Still need the full output of dmidecode on an esx 2.5 host' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Address: 0xE8480\nRelease Date: 04/21/2004\nRuntime Size: 97152 bytes")
          end
          it "should set the vmware fact to '2.5'" do
            Facter.fact(:vmware).value.should == '2.5'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 3.0 - insufficient data to deep-dive this. Still need the full output of dmidecode on an esx 3.0 host' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Address: 0xE7C70\nRelease Date: 04/17/2006\nRuntime Size: 99216 bytes")
          end
          it "should set the vmware fact to '3.0'" do
            Facter.fact(:vmware).value.should == '3.0'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 3.5.0 - 207095' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTDVersion: 6.00\nRelease Date: 03/19/2009\nAddress: 0xE66C0\nRuntime Size: 104768 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '3.5'" do
            Facter.fact(:vmware).value.should == '3.5'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.0 - 171294' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 03/26/2009\nAddress: 0xEA550\nRuntime Size: 88752 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.0'" do
            Facter.fact(:vmware).value.should == '4.0'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.0.0u1 - 208167' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 09/22/2009\nAddress: 0xEA550\nRuntime Size: 88752 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.0'" do
            Facter.fact(:vmware).value.should == '4.0'
          end
          it "should set the vmware_patchlevel fact to 'u1'" do
            pending 'we do not yet have a way to determine this' do
             Facter.fact(:vmware_patchlevel).value.should == 'u1'
            end
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.0.0u2 - 261974' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 09/22/2009\nAddress: 0xEA550\nRuntime Size: 88752 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.0'" do
            Facter.fact(:vmware).value.should == '4.0'
          end
          it "should set the vmware_patchlevel fact to 'u2'" do
            pending 'we do not yet have a way to determine this' do
             Facter.fact(:vmware_patchlevel).value.should == 'u2'
            end
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.0.0u3 - 398348' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 09/22/2009\nAddress: 0xEA550\nRuntime Size: 88752 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.0'" do
            Facter.fact(:vmware).value.should == '4.0'
          end
          it "should set the vmware_patchlevel fact to 'u3'" do
            pending 'we do not yet have a way to determine this' do
             Facter.fact(:vmware_patchlevel).value.should == 'u3'
            end
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.0.0u4 - 504850' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 09/22/2009\nAddress: 0xEA550\nRuntime Size: 88752 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.0'" do
            Facter.fact(:vmware).value.should == '4.0'
          end
          it "should set the vmware_patchlevel fact to 'u4'" do
            pending 'we do not yet have a way to determine this' do
             Facter.fact(:vmware_patchlevel).value.should == 'u4'
            end
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.1.0 - 260247' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 10/13/2009\nAddress: 0xEA2E0\nRuntime Size: 89376 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.1'" do
            Facter.fact(:vmware).value.should == '4.1'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 4.1.0u2 - 800380' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 04/15/2011\nAddress: 0xEA2E0\nRuntime Size: 89376 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nUSB legacy is supported\nSmart battery is supported\nBIOS boot specification is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '4.1'" do
            Facter.fact(:vmware).value.should == '4.1'
          end
          it "should set the vmware_patchlevel fact to 'u2'" do
           Facter.fact(:vmware_patchlevel).value.should == 'u2'
          end
        end

        context 'when running on esxi 5.0.0 - 469512' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 01/07/2011\nAddress: 0xE72C0\nRuntime Size: 101696 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nBoot from CD is supported\nSelectable boot is supported\nEDD is supported\nPrint screen service is supported (int 5h)\n8042 keyboard services are supported (int 9h)\nSerial services are supported (int 14h)\nPrinter services are supported (int 17h)\nCGA/mono video services are supported (int 10h)\nACPI is supported\nSmart battery is supported\nBIOS boot specification is supported\nFunction key-initiated network boot is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '5.0'" do
            Facter.fact(:vmware).value.should == '5.0'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end

        context 'when running on esxi 5.0.0u1 - 623860' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 09/21/2011\nAddress: 0xE72C0\nRuntime Size: 101696 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nBoot from CD is supported\nSelectable boot is supported\nEDD is supported\nPrint screen service is supported (int 5h)\n8042 keyboard services are supported (int 9h)\nSerial services are supported (int 14h)\nPrinter services are supported (int 17h)\nCGA/mono video services are supported (int 10h)\nACPI is supported\nSmart battery is supported\nBIOS boot specification is supported\nFunction key-initiated network boot is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '5.0'" do
            Facter.fact(:vmware).value.should == '5.0'
          end
          it "should set the vmware_patchlevel fact to 'u1'" do
           Facter.fact(:vmware_patchlevel).value.should == 'u1'
          end
        end
        context 'when running on esxi 5.0.0u2 - 914586' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 07/09/2012\nAddress: 0xE72C0\nRuntime Size: 101696 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nBoot from CD is supported\nSelectable boot is supported\nEDD is supported\nPrint screen service is supported (int 5h)\n8042 keyboard services are supported (int 9h)\nSerial services are supported (int 14h)\nPrinter services are supported (int 17h)\nCGA/mono video services are supported (int 10h)\nACPI is supported\nSmart battery is supported\nBIOS boot specification is supported\nFunction key-initiated network boot is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '5.0'" do
            Facter.fact(:vmware).value.should == '5.0'
          end
          it "should set the vmware_patchlevel fact to 'u2'" do
           Facter.fact(:vmware_patchlevel).value.should == 'u2'
          end
        end

        context 'when running on esxi 5.1.0 - 799733' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 06/22/2012\nAddress: 0xEA0C0\nRuntime Size: 89920 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nBoot from CD is supported\nSelectable boot is supported\nEDD is supported\nPrint screen service is supported (int 5h)\n8042 keyboard services are supported (int 9h)\nSerial services are supported (int 14h)\nPrinter services are supported (int 17h)\nCGA/mono video services are supported (int 10h)\nACPI is supported\nSmart battery is supported\nBIOS boot specification is supported\nFunction key-initiated network boot is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '5.1'" do
            Facter.fact(:vmware).value.should == '5.1'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end
        
        context 'when running on esxi 5.1.0 - 1065491' do
          before do
            Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/dmidecode -t bios').returns("Handle 0x0000, DMI type 0, 24 bytes\nBIOS Information\nVendor: Phoenix Technologies LTD\nVersion: 6.00\nRelease Date: 06/22/2012\nAddress: 0xEA0C0\nRuntime Size: 89920 bytes\nROM Size: 64 kB\nCharacteristics:\nISA is supported\nPCI is supported\nPC Card (PCMCIA) is supported\nPNP is supported\nAPM is supported\nBIOS is upgradeable\nBIOS shadowing is allowed\nESCD support is available\nBoot from CD is supported\nSelectable boot is supported\nEDD is supported\nPrint screen service is supported (int 5h)\n8042 keyboard services are supported (int 9h)\nSerial services are supported (int 14h)\nPrinter services are supported (int 17h)\nCGA/mono video services are supported (int 10h)\nACPI is supported\nSmart battery is supported\nBIOS boot specification is supported\nFunction key-initiated network boot is supported\nTargeted content distribution is supported\nBIOS Revision: 4.6\nFirmware Revision: 0.0\n")
          end
          it "should set the vmware fact to '5.1'" do
            Facter.fact(:vmware).value.should == '5.1'
          end
          it "should set the vmware_patchlevel fact to 'unknown'" do
           Facter.fact(:vmware_patchlevel).value.should == 'unknown'
          end
        end
      end
    end
  end
end
