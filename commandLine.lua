#!/usr/bin/env lua

local originalOptions = nil
local logFileName = 'bootstrap_installer.log'

commandLine = {}

function commandLine.parseOptions(args)
  originalOptions = args
  local continueParsing = true
  local currentArgPosition = 0
  local totalArgs = #args
  while currentArgPosition < totalArgs  do
    if args[currentArgPosition] == '--logfile' then
      logFileName = args[currentArgPosition + 1]
      currentArgPosition = currentArgPosition + 1
    end
    currentArgPosition = currentArgPosition + 1
  end
  
end

function commandLine.getLogFileName()
  return logFileName
end

return commandLine