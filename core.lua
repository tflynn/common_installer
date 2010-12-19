#!/usr/bin/env lua

require 'os'
remoteRequire 'commandLine'
remoteRequire 'logger'
remoteRequire 'ioHelpers'

local DEFAULT_SETTINGS_FILE = 'defaultSettings'
local CUSTOM_SETTINGS_FILE = 'customSettings'

core = {}

function core.runInstaller()
  core.initializeInstaller()
  core.loadSettings()
end

function core.initializeInstaller() 
  commandLine.parseOptions(arg)
  logger.addConsoleAppender()
  logger.addFileAppender(commandLine.getLogFileName())
end

function core.loadSettings()
  remoteRequire(DEFAULT_SETTINGS_FILE)
  if ioHelpers.fileExists(CUSTOM_SETTINGS_FILE) then
    require(CUSTOM_SETTINGS_FILE)
  end
end

function core.getComponentNames()
  return COMPONENT_NAMES
end

function core.getComponentOptions(componentName) 
  return COMPONENT_OPTIONS[componentName]
end

function core.getComponentsOptions()
  local componentNames = core.getComponentNames()
  local allComponentOptions = {}
  for i = 1 , #componentNames do
    local componentName = componentNames[i]
    allComponentOptions[i] = core.getComponentOptions(componentName)
  end
  return allComponentOptions
end


function core.getPackageNames()
  return PACKAGE_NAMES
end

function core.getPackageOptions(packageName) 
  return PACKAGE_OPTIONS[packageName]
end

function core.getPackagesOptions()
  local packageNames = core.getPackageNames()
  local allPackageOptions = {}
  for i = 1 , #packageNames do
    local packageName = packageNames[i]
    allPackageOptions[i] = core.getPackageOptions(packageName)
  end
  return allPackageOptions
end

function core.displayInstallationMenuPackages()
  local packageNames = core.getPackageNames()
  print "Available Installation Packages\n"
  local menuEntryFormat = '%d. %s'
  for i = 1 , #packageNames do
    local packageName = packageNames[i]
    local packageOptions = core.getPackageOptions(packageName)
    local menuOption = menuEntryFormat:format(i,packageOptions.name)
    print(menuOption)
  end
  print("\nX  Exit")
end

function core.getUserPackageSelection() 
  local packageNames = core.getPackageNames()
  core.displayInstallationMenuPackages()
  local userPackageSelection = ioHelpers.readKeyboardWithPrompt("\nEnter selection")
  if userPackageSelection == 'X' or userPackageSelection == 'x'  then
    core.normalExit()
  end
  return packageNames[userPackageSelection + 0]
end

function core.normalExit()
  os.exit(0)
end

return core