#!/usr/bin/env jruby

class CommandLine
  
  COMMAND_LINE_OPTIONS = {}
  
  class << self
    
    def parseOptions(args)
      logFileName = DEFAULT_LOG_FILE_NAME
      while args.size > 0
        currentArg = args.shift
        setting, value = currentArg.split('=')
        if setting == 'logfile'
          COMMAND_LINE_OPTIONS[:logFileName] = value
        end
      end

    end

    def getLogFileName
      return COMMAND_LINE_OPTIONS[:logFileName]
    end

  end
  
end

