#!/usr/bin/env lua

require 'osHelpers'
local ioHelpers = require 'ioHelpers'

cmd = "echo $SHELL"
print(cmd)
status, result = os.capture(cmd,false)
print("status = "..status)
print("result = "..result)

cmd = "which bua"
print(cmd)
status, result = os.capture(cmd,false)
print("status = "..status)
print("result = "..result)

response = ioHelpers.readKeyboardWithPrompt('tell me')
print(response)
