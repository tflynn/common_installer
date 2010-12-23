#!/usr/bin/env jruby

class CommandLine
  
  COMMAND_LINE_OPTIONS = {}
  
  class << self
    
    def parseOptions(args)
      originalOptions = args
      continueParsing = true
      currentArgPosition = 0
      totalArgs = args.size
      logFileName = DEFAULT_LOG_FILE_NAME
      while currentArgPosition < totalArgs
        if args[currentArgPosition] == '--logfile'
          logFileName = args[currentArgPosition + 1]
          currentArgPosition = currentArgPosition + 1
          COMMAND_LINE_OPTIONS[:logFileName] = logFileName
        end
        currentArgPosition = currentArgPosition + 1
      end

    end

    def getLogFileName
      return COMMAND_LINE_OPTIONS[:logFileName]
    end

  end
  
end

