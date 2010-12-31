#!/usr/bin/env jruby

class CommandLine
  
  COMMAND_LINE_OPTIONS = {}
  
  class << self
    
    def parseOptions(args)
      if args
        while args.size > 0
          currentArg = args.shift
          # Skip any options to do with logging
          next if currentArg =~ /logfile/ or currentArg =~ /consoleLogging/
        end
      end
    end

  end
  
end

