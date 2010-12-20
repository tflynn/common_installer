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
  local userComponentSelection = core.getUserComponentSelection()
  core.installComponent(userComponentSelection)
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

function core.getComponentOptions(componentName) 
  return COMPONENT_OPTIONS[componentName]
end

function core.displayInstallationMenu()
  print "Available Installation Components\n"
  local menuEntryFormat = '%d. %s'
  local components = {}
  for i = 1 , #MENU_ORDER do
    local menuEntry = MENU_ORDER[i]
    if menuEntry == MENU_SEPARATOR then
      print(MENU_SEPARATOR)
    else
      local componentOptions = core.getComponentOptions(menuEntry)
      local menuOption = menuEntryFormat:format(#components + 1,componentOptions.name)
      print(menuOption)
      components[#components + 1] = menuEntry
    end
  end
  print("\nX  Exit")
  return components
end

function core.getUserComponentSelection() 
  local components = core.displayInstallationMenu()
  local userComponentSelection = ioHelpers.readKeyboardWithPrompt("\nEnter selection")
  print('')
  if userComponentSelection == 'X' or userComponentSelection == 'x'  then
    core.normalExit()
  end
  return components[userComponentSelection + 0]
end

function core.installComponent(componentName)
  local componentOptions = core.getComponentOptions(componentName) 
  print("Installing component " .. componentOptions.name)
  
  local componentDependencies = componentOptions.componentDependencies
  if componentDependencies ~= nil then
    for i = 1 , #componentDependencies do
      local componentDependency = componentDependencies[i]
      core.installComponent(componentDependency)
    end
  end
  
  local fullyQualifiedCopmonentName = 'components/' .. componentName
  require(fullyQualifiedCopmonentName)
  local currentComponent = package.loaded[fullyQualifiedCopmonentName]
  currentComponent.preInstall()
  currentComponent.install()
  currentComponent.postInstall()
  
end

function core.normalExit()
  os.exit(0)
end


return core

