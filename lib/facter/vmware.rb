require 'facter'

# I have verified that the following versions match the following strings in dmidecode
# ESXi 3.5    207095 ( Address: 0xE66C0 Release Date: 03/19/2009)
# ESXi 4.0    171294 ( Address: 0xEA550 Release Date: 03/26/2009)
# ESXi 4.0u1  208167 ( Address: 0xEA550 Release Date: 09/22/2009)
# ESXi 4.0u2  261974 ( Address: 0xEA550 Release Date: 09/22/2009)
# ESXi 4.0u3  398348 ( Address: 0xEA550 Release Date: 09/22/2009)
# ESXi 4.0u4  504850 ( Address: 0xEA550 Release Date: 09/22/2009)
# ESXi 4.1    260247 ( Address: 0xEA2E0 Release Date: 10/13/2009)
# ESXi 4.1u2  800380 ( Address: 0xEA2E0 Release Date: 04/15/2011)
# ESXi 5.0    469512 ( Address: 0xE72C0 Release Date: 01/07/2011)
# ESXi 5.0u1  623860 ( Address: 0xE72C0 Release Date: 09/21/2011)
# ESXi 5.0u2  914586 ( Address: 0xE72C0 Release Date: 07/09/2012)
# ESXi 5.1    799733 ( Address: 0xEA0C0 Release Date: 06/22/2012)
# ESXi 5.1.0 1065491 ( Address: 0xEA0C0 Release Date: 06/22/2012)
#
Facter.add(:vmware) do
  #default for non-vmware nodes
  setcode do
    nil
  end
end

Facter.add(:vmware) do
  confine :virtual => :vmware
  #VMWare, but not linux
  setcode do
    'vmware-unknown'
  end
end
Facter.add(:vmware) do
  confine :virtual => :vmware
  confine :kernel => :linux
  #vmware and linux. whee!
  setcode do
    hasdmi = Facter::Util::Resolution.exec('which dmidecode')
    if hasdmi.nil?
      #no dmidecode
      result='vmware-linux'
    else
      foobar = Facter::Util::Resolution.exec("#{hasdmi} -t bios")
      if foobar.nil?
        result='vmware-linux'
      else
        if foobar.match(/No SMBIOS nor DMI entry point found, sorry/)
          result='vmware-linux'
        else
          #we're good
          mainver  = 'vmware-linux'
          if foobar.include? 'Address'
            address = foobar.match(/Address: 0x(.*)/i)[0]
          else
            address = 'no_data'
          end
          if foobar.include? 'Release Date'
            biosdate = foobar.match(/Release Date: (.*)/i)[0]
          else
            biosdate = 'no_data'
          end
          case
          when address.match(/E8480/)
            mainver = '2.5'
          when address.match(/E7C70/)
            mainver = '3.0'
          when address.match(/E7910/)
            mainver = '3.5'
          when address.match(/E66C0/)
            mainver = '3.5'
          when address.match(/EA6C0/)
            mainver = '4.0'
          when address.match(/EA550/)
            mainver = '4.0'
          when address.match(/EA2E0/)
            mainver = '4.1'
          when address.match(/E72C0/)
            mainver = '5.0'
          when address.match(/EA0C0/)
            mainver = '5.1'
          end
          result=mainver
        end
      end
    end
    result
  end
end
Facter.add(:vmware_patchlevel) do
  confine :virtual => :vmware
  setcode do
    'unknown'
  end
end

Facter.add(:vmware_patchlevel) do
  confine :virtual => :vmware
  confine :kernel => :linux
  setcode do
    hasdmi = Facter::Util::Resolution.exec('which dmidecode')
    if hasdmi.nil?
      #no dmidecode
      result='vmware-linux'
    else
      foobar = Facter::Util::Resolution.exec("#{hasdmi} -t bios")
      if foobar.nil?
        result='vmware-linux'
      else
        if foobar.match(/No SMBIOS nor DMI entry point found, sorry/)
          result='vmware-linux'
        else
          #we're good
          update  = 'unknown'
          if foobar.include? 'Address'
            address = foobar.match(/Address: 0x(.*)/i)[0]
          else
            address = 'no_data'
          end
          if foobar.include? 'Release Date'
            biosdate = foobar.match(/Release Date: (.*)/i)[0]
          else
            biosdate = 'no_data'
          end
          case
            #we only have means of detecting 4.1u2, 5.0u1, 5.0u2 right now.
          when address.match(/EA2E0/)
            if biosdate.include? '04/15/2011'
              update = 'u2'
            end
          when address.match(/E72C0/)
            if biosdate.include? '09/21/2011'
              update = 'u1'
            end
            if biosdate.include? '07/09/2012'
              update = 'u2'
            end
          end
        end
      end
    end
    update
  end
end
Facter.add(:vmware_patchlevel) do
  setcode do
    nil
  end
end
