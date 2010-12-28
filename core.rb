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
      getGlobalUserChoices
      while true
        @@pass_settings = {}
        userComponentSelections = getUserComponentSelection
        userComponentSelections.each do | userComponentSelection|
          installComponent(userComponentSelection)
        end
      end
    end
    
    def initializeInstaller 
      CommandLine.parseOptions(ARGV)
      # logger.addConsoleAppender
      # logger.addFileAppender(CommandLine.getLogFileName)
      unless File.exists?('components')
        Kernel.system('mkdir components')
      end
    end
    
    def loadSettings
      remoteRequire(DEFAULT_SETTINGS_FILE)
      if File.exists?(CUSTOM_SETTINGS_FILE)
        fileContents = IOHelpers.readFile(CUSTOM_SETTINGS_FILE)
        eval(fileContents.join("\n"))
      end
    end
    
    def getGlobalUserChoices
      puts("\nOptions that apply for all installations\n\n") 
      
      if SYSTEM_SETTINGS.modify_shell_startup_file.nil? 
        updateStartupShellsAutomatically = IOHelpers.readKeyboardWithPromptYesNo("Update shell startup files automatically with new PATH and other settings?")
        puts('')
        menuEntryFormat = '%d. Update %s'
        if updateStartupShellsAutomatically
          entryPosition = 0
          SHELL_STARTUP_FILES.each do |shell_startup_file|
            menuOption = menuEntryFormat % [entryPosition + 1 , shell_startup_file]
            puts menuOption
            entryPosition += 1
          end
          userSelection = IOHelpers.readKeyboardWithPrompt("\nEnter selection").to_i
          selected_shell_startup_file = SHELL_STARTUP_FILES[userSelection - 1]
          SYSTEM_SETTINGS.modify_shell_startup_file = selected_shell_startup_file
        else
          puts("The system will display and log suggested changes to startup settings.\n\n")
          SYSTEM_SETTINGS.modify_shell_startup_file = 'none'
        end
      end
      
    end
    
    def updateExternalSettings(options = {})
      if shouldUpdateExternalSettings?
        puts "Updating external settings"
      else
        puts "Won't update external settings"
      end
    end
    
    def shouldUpdateExternalSettings?
      return (SYSTEM_SETTINGS.modify_shell_startup_file.nil? or SYSTEM_SETTINGS.modify_shell_startup_file == 'none') ? false : true
    end
    
    def getComponentOptions(componentName) 
      return COMPONENT_OPTIONS.send(componentName)
    end

    def displayInstallationMenu()
      puts("\nAvailable Installation Components\n\n")
      menuEntryFormat = '%d. %s'
      components = []
      entryPosition = 0
      MENU_ORDER.each do |menuEntry|
        if menuEntry == MENU_SEPARATOR
          puts(menuEntry)
        else
          componentOptions = getComponentOptions(menuEntry)
          menuOption = menuEntryFormat % [entryPosition + 1 , componentOptions.name]
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
      userComponentSelection = IOHelpers.readKeyboardWithPrompt("\nEnter selection (separate multiple selections with ',')")
      puts('')
      if userComponentSelection == 'X' or userComponentSelection == 'x'  then
        normalExit
      end
      selectedComponents = []
      if userComponentSelection =~ /,/
        selectedComponentsList = userComponentSelection.split(',')
        selectedComponentsList.each do |selectedComponent|
          selectedComponents << components[selectedComponent.strip.chomp.to_i - 1]
        end
      else
        selectedComponents << components[userComponentSelection.to_i - 1]
      end
      return selectedComponents
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
      puts(%{Installing component #{componentOptions.name}})

      componentDependencies = componentOptions.componentDependencies
      if componentDependencies
        componentDependencies.each do |componentDependency|
          installComponent(componentDependency)
        end
      end

      currentComponent = requireComponent(componentName)

      if currentComponent 
        currentComponent.completeObtainBuildInstallConfigure
      end
    
    end
    
    def normalExit
      Kernel.exit(0)
    end

    def errorExit
      Kernel.exit(1)
    end

    
  end
  
end