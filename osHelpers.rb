#!/usr/bin/env jruby

require 'tempfile'

remoteRequire 'core'
remoteRequire 'installerLogger'

SYSTEM_TYPE_LINUX = 'linux'
SYSTEM_TYPE_OSX = 'osx'
SYSTEM_TYPE_UNKNOWN = 'unknown'

remoteRequire 'ioHelpers'

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
    
    def executeCommand(cmd,options = {})
      additionalPaths = []
      additionalPaths = additionalPaths.concat(options[:additionalPaths]) if options[:additionalPaths]
      additionalPaths = additionalPaths.concat(::DEFAULT_PATHS)
      # caller[0,15].each do |callEntry|
      #   puts "OSHelpers.executeCommand #{callEntry}"
      # end
      allPaths = additionalPaths.join(":")
      tempFile = Tempfile.new("cmdOut")
      fullCmd = %{export PATH=#{allPaths} ;  #{cmd} | tee #{tempFile.path}}
      logger.info("Executing command \"#{fullCmd}\"")
      Kernel.system(fullCmd)
      status = $?
      retVal = status == 0 ? SUCCESS : FAILURE
      cmdOutput = IOHelpers.readFile(tempFile.path)
      File.delete(tempFile.path)
      return {:status => status , :fullCommand => fullCmd, :commandOutput => cmdOutput , :retVal => retVal }
    end
    
    def isCommmandPresent?(cmd)
      results = executeCommand("which #{cmd}")
      return results[:status] == 0
    end
    
  end
  
end

