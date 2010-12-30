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
      almostFullCmd = %{export PATH=#{allPaths} ;  #{cmd} }
      logger.debug("Executing command \"#{almostFullCmd}\"")
      tempFile = Tempfile.new("cmdOut")
      if logger.consoleLogging
        fullCmd = %{#{almostFullCmd} | tee #{tempFile.path}}
      else
        fullCmd = %{#{almostFullCmd} >#{tempFile.path} 2>&1}
      end
      status = Kernel.system(fullCmd)
      if logger.fileLogging
        cmdOutput = IO.read(tempFile.path)
        File.open(logger.getFileName,'a') do |logfile|
          logfile.write(cmdOutput)
        end
      end
      # If Kernel.system returns a false results, docs say error code is in $?
      if status == true
        status = 0
      else
        status = $?
      end
      retVal = status == 0 ? SUCCESS : FAILURE
      cmdOutput = IOHelpers.readFile(tempFile.path)
      File.delete(tempFile.path)
      return {:status => status , :fullCommand => almostFullCmd, :commandOutput => cmdOutput , :retVal => retVal }
    end
    
    def isCommmandPresent?(cmd)
      results = executeCommand("which #{cmd}")
      return results[:status] == 0
    end
    
    def getCommandLocation(cmd)
      results = executeCommand("which #{cmd}")
      if results[:status] == 0
        commandLocation = results[:commandOutput].first
        return commandLocation
      else
        return nil
      end
    end
  end
  
end

