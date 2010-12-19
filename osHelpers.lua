#!/usr/bin/env lua

require 'os'

SYSTEM_TYPE_LINUX = 'linux'
SYSTEM_TYPE_OSX = 'osx'
SYSTEM_TYPE_UNKNOWN = 'unknown'


osHelpers = {}


function osHelpers.readFile(fileName)
  local lines = {}
  local line
  for line in io.lines(fileName) do
    lines[#lines + 1] = line
  end
  lines[#lines + 1] = ""
  return table.concat(lines,"\n")
end

function osHelpers.capture(cmd)
  local tempFile = os.tmpname()
  local fullCmd = cmd.." >"..tempFile.." 2>&1 "
  -- print(cmd)
  local status = os.execute(fullCmd)
  local results = osHelpers.readFile(tempFile)
  os.remove(tempFile)
  return status, results
end

function osHelpers.captureAndStrip(cmd)
  local status = nil
  local results = nil
  status, results = osHelpers.capture(cmd)
  results = string.gsub(results,"\n","")
  return status, results
end

function osHelpers.getSystemType()
  local systemType = nil
  status, results = osHelpers.captureAndStrip('uname -a | grep -q -i linux')
  if status == 0 then
    systemType = SYSTEM_TYPE_LINUX
  else
    status, results = osHelpers.captureAndStrip('uname -a | grep -q -i darwin')
    if status == 0 then
      systemType = SYSTEM_TYPE_OSX
    end
  end
  if systemType == nil then
    systemType = SYSTEM_TYPE_UNKNOWN
  end
  return systemType
end


return osHelpers
