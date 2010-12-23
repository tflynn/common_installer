#!/usr/bin/env jruby

remoteRequire 'commandLine'
remoteRequire 'installerLogger'
remoteRequire 'ioHelpers'

class Core
  
  DEFAULT_SETTINGS_FILE = 'defaultSettings'
  CUSTOM_SETTINGS_FILE = 'customSettings'
  
  class << self
    
    def runInstaller
      initializeInstaller
      loadSettings
      userComponentSelection = getUserComponentSelection
      installComponent(userComponentSelection)
    end
    
    def initializeInstaller 
      CommandLine.parseOptions(ARGV)
      logger.addConsoleAppender
      logger.addFileAppender(CommandLine.getLogFileName)
      unless File.exists?('components')
        Kernel.system('mkdir components')
      end
    end
    
    def loadSettings
      remoteRequire(DEFAULT_SETTINGS_FILE)
      if File.exists?(CUSTOM_SETTINGS_FILE)
        require(CUSTOM_SETTINGS_FILE)
      end
    end
    
    def getComponentOptions(componentName) 
      return COMPONENT_OPTIONS[componentName]
    end

    def displayInstallationMenu()
      puts("\nAvailable Installation Components\n")
      menuEntryFormat = '%d. %s'
      components = []
      entryPosition = 0
      MENU_ORDER.each do |menuEntry|
        if menuEntry == MENU_SEPARATOR
          puts(menuEntry)
        else
          componentOptions = getComponentOptions(menuEntry)
          menuOption = menuEntryFormat % [entryPosition + 1 , componentOptions[:name]]
          puts(menuOption)
          entryPosition += 1 
          components << menuEntry
        end 
      end
      puts("\nX  Exit")
      return components
    end
    
    def getUserComponentSelection 
      components = displayInstallationMenu
      userComponentSelection = IOHelpers.readKeyboardWithPrompt("\nEnter selection")
      puts('')
      if userComponentSelection == 'X' or userComponentSelection == 'x'  then
        normalExit
      end
      return components[userComponentSelection.to_i - 1]
    end
    
    
    def requireComponent(componentName)
      fullyQualifiedCopmonentName = %{components/#{componentName}}
      remoteRequire(fullyQualifiedCopmonentName)
      newInstance = nil
      newInstanceCmd = %{newInstance = #{fileNameToClassName(componentName)}.new}
      eval(newInstanceCmd)
      return newInstance
    end
    
    def fileNameToClassName(fileName)
      firstCharacter = fileName[0,1]
      firstCharacter = firstCharacter.upcase
      fileName = firstCharacter + fileName[1..-1]
      return fileName
    end
    
    def installComponent(componentName)
      componentOptions = getComponentOptions(componentName) 
      puts(%{Installing component #{componentOptions[:name]}})

      componentDependencies = componentOptions[:componentDependencies]
      if componentDependencies
        componentDependencies.each do |componentDependency|
          installComponent(componentDependency)
        end
      end

      currentComponent = requireComponent(componentName)

      if currentComponent and currentComponent.respond_to?(:preInstall)
        currentComponent.preInstall
      end
      buildType = componentOptions[:compomentBuildType]
      if buildType and buildType == BUILD_TYPE_GNU
        overrideComponent = requireComponent('gnuBuild')
        if overrideComponent and overrideComponent.respond_to?(:install)
          overrideComponent.install
        end
      else
        if currentComponent.respond_to?(:install)
          currentComponent.install
        end
      end
      if currentComponent.respond_to?(:postInstall)
        currentComponent.postInstall
      end

    end
    
    def normalExit()
      Kernel.exit(0)
    end

    
  end
  
end