#!/usr/bin/env lua

require 'os'

module('osHelpers', package.seeall)


function os.readFile(fileName)
  local lines = {}
  local line
  for line in io.lines(fileName) do
    lines[#lines + 1] = line
  end
  lines[#lines + 1] = ""
  return table.concat(lines,"\n")
end

function os.capture(cmd, raw)
  local tempFile = os.tmpname()
  local fullCmd = cmd.." >"..tempFile.." 2>&1 "
  -- print(cmd)
  local status = os.execute(fullCmd)
  local results = os.readFile(tempFile)
  os.remove(tempFile)
  return status, results
end

