#!/usr/bin/env jruby

SYSTEM_TYPE_LINUX = 'linux'
SYSTEM_TYPE_OSX = 'osx'
SYSTEM_TYPE_UNKNOWN = 'unknown'

remoteRequire 'core'
remoteRequire 'installerLogger'

class OSHelpers

  class << self
    
    def getSystemType
      systemType = nil
      results = `uname -a | grep -q -i linux`.chomp.strip
      status = $?
      if status == 0
        systemType = SYSTEM_TYPE_LINUX
      else
        results = `uname -a | grep -q -i darwin`.chomp.strip
        status = $?
        if status == 0 then
          systemType = SYSTEM_TYPE_OSX
        end
      end
      if systemType == nil then
        systemType = SYSTEM_TYPE_UNKNOWN
      end
      return systemType
    end
    
    def executeCommand(cmd)
      # caller[0,15].each do |callEntry|
      #   puts "OSHelpers.executeCommand #{callEntry}"
      # end
      
      logger.info("Executing command \"#{cmd}\"")
      Kernel.system(cmd)
      status = $?
      retVal = status == 0 ? SUCCESS : FAILURE
      # if retVal == FAILURE
      #   logger.error("Command \"#{cmd}\" returned status #{status} . Exiting ...")
      #   Core.errorExit
      # end
      return retVal
    end
    
  end
  
end

