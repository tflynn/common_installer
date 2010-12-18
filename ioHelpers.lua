#!/usr/bin/env lua

require 'io'

ioHelpers = {}

function ioHelpers.readKeyboard()
  local inputLine = io.stdin:read('*l')
  return inputLine
end

function ioHelpers.readKeyboardWithPrompt(prompt)
  io.stdout:write(prompt..": ")
  return ioHelpers.readKeyboard()
end

function ioHelpers.fileExists(fileName) 
  return io.open(fileName) and true or false
end

return ioHelpers
