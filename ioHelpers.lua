#!/usr/bin/env lua

require 'io'

module('ioHelpers', package.seeall)

function readKeyboard()
  local inputLine = io.stdin:read('*l')
  return inputLine
end

function readKeyboardWithPrompt(prompt)
  io.stdout:write(prompt.." : ")
  return readKeyboard()
end
