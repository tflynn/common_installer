#!/usr/bin/env lua

enableRemoteRequire = true
local remoteRepository = {'http://dl.dropbox.com/u/12189743/InstallationFiles/bootstrap_installer'}

require 'os'
require 'io'

-- Load the module from a remote location
-- This will fail in remote mode if the remote file is not present
function remoteRequire(moduleName)
  local fullModuleName = moduleName .. '.lua'
  local localCopy = io.open(fullModuleName) and true or false
  if enableRemoteRequire and (not localCopy) then
    local cmd = "wget " .. remoteRepository[1] .. "/" .. fullModuleName
    local fullCmd = cmd .. " > /dev/null 2>&1 "
    local status = os.execute(fullCmd)
    if status ~= 0 then
      print("Error: File not found in remote repository " .. remoteRepository[1] .. "/" .. moduleName .. ".lua"  .. '. Exiting ... ')
      return nil
    end
  end
  requiredModule = require(moduleName)
  return requiredModule
end

remoteRequire 'osHelpers'
local ioHelpers = remoteRequire 'ioHelpers'

cmd = "echo $SHELL"
print(cmd)
status, result = os.capture(cmd,false)
print("status = "..status)
print("result = "..result)

cmd = "which lua"
print(cmd)
status, result = os.capture(cmd,false)
print("status = "..status)
print("result = "..result)

-- response = ioHelpers.readKeyboardWithPrompt('tell me')
-- print(response)
