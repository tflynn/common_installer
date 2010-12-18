#!/usr/bin/env lua

require 'os'

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

return osHelpers
