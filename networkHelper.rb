#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'core'
remoteRequire 'osHelpers'

class NetworkHelper
  
  class << self
    
    def getPrimaryIPAddress
      
      primaryIPAddress = nil
      if OSHelpers.isCommmandPresent?('ifconfig')
        osType = OSHelpers.getSystemType
        result = `ifconfig`
        if osType == SYSTEM_TYPE_OSX
          primaryIPAddress = parseIfonfigOutput(result, 'en0')
        elsif osType == SYSTEM_TYPE_LINUX
          primaryIPAddress = parseIfonfigOutput(result, 'eth0')
        end
      else
        logger.error("Unable to locate command 'ifconfig'. Leaving ...")
        Core.errorExit
      end
      return primaryIPAddress
      
    end
    
    def parseIfonfigOutput(ifconfigOutput, networkAdapter)
      networkAdapterRegex = Regexp.new('^' + networkAdapter)
      adapterEntryActive = false
      ipAddress = nil
      ifconfigOutput = ifconfigOutput.split("\n")
      ifconfigOutput.each do |ifconfigLine|
        if ifconfigLine =~ networkAdapterRegex
          adapterEntryActive = true
          next
        end
        if adapterEntryActive
          if ifconfigLine =~ /inet/
            inetEntry = ifconfigLine.chomp.strip.split(' ')
            if inetEntry.first == 'inet'
              ipAddress = inetEntry[1].gsub(/addr\:/,'')
              break
            end
          end
        end
      end
      return ipAddress
    end
    
    
  end
  
end
