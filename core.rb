#!/usr/bin/env jruby

remoteRequire 'commandLine'
remoteRequire 'installerLogger'
remoteRequire 'ioHelpers'
remoteRequire 'osHelpers'

class Core
  
  
  class << self
    
    def runInstaller
      initializeInstaller
      preloadComponents
      checkSystemSupported
      getGlobalUserChoices
      while true
        @@pass_settings = {}
        userComponentSelections = getUserComponentSelection
        userComponentSelections.each do | userComponentSelection|
          installComponent(userComponentSelection)
        end
      end
    end
    
    def checkSystemSupported
      systemType = OSHelpers.getSystemType
      if systemType == SYSTEM_TYPE_UNKNOWN then
        msg = "Unknown system type. Leaving ..."
        unless logger.consoleLogging
          puts msg
        end
        logger.error(msg)
        errorExit
      end
      if systemType == SYSTEM_TYPE_LINUX
        linuxTypeAndVersion = OSHelpers.getLinuxTypeAndVersion
        linuxType = linuxTypeAndVersion[:type]
        if linuxType == LINUX_TYPE_UNKNOWN
          msg = "Unknown Linux system type. Leaving ..."
          unless logger.consoleLogging
            puts msg
          end
          logger.error(msg)
          errorExit
        end
        unless LINUX_TYPES_SUPPORTED.index(linuxType)
          msg = "Unsupported Linux type '#{linuxType}'. Leaving ..."
          unless logger.consoleLogging
            puts msg
          end
          logger.error(msg)
          errorExit
        end
      end
    end
    
    def initializeInstaller 
      loadSettings
      setLoggingSettings
      CommandLine.parseOptions(ARGV)
      unless File.exists?('components')
        Kernel.system('mkdir components')
      end
    end
    
    def loadSettings
      remoteRequire(DEFAULT_SETTINGS_FILE)
      if File.exists?(::CUSTOM_SETTINGS_FILE)
        fileContents = IOHelpers.readFile(::CUSTOM_SETTINGS_FILE)
        logger.info(%{Loading settings file #{::CUSTOM_SETTINGS_FILE}})
        eval(fileContents.join("\n"))
      end
    end
    
    def setLoggingSettings
      #TODO set true logging settings
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
        logger.info("System will update external settings in #{SYSTEM_SETTINGS.modify_shell_startup_file}")
      else
        logger.info("System will not update external settings")
      end
    end
    
    def shouldUpdateExternalSettings?
      return (SYSTEM_SETTINGS.modify_shell_startup_file.nil? or SYSTEM_SETTINGS.modify_shell_startup_file == 'none') ? false : true
    end
    
    
    def getComponentOptions(componentName) 
      return COMPONENT_OPTIONS.send(componentName)
    end

    def displayInstallationMenu()
      menuEntryFormat = '%d. %s %s %s %s'
      components = []
      entryPosition = 0

      installationStatuses = {}
      MENU_ORDER.each do |menuEntry|
        next if menuEntry == MENU_SEPARATOR
        installed = getLoadedComponent(menuEntry).alreadyInstalled?
        if installed
          installationStatuses[menuEntry] = true
        end
      end
      
      puts("\nAvailable Installation Components\n\n")
      MENU_ORDER.each do |menuEntry|
        if menuEntry == MENU_SEPARATOR
          puts(menuEntry)
        else
          componentOptions = getComponentOptions(menuEntry)
          component = getLoadedComponent(menuEntry)
          installed = installationStatuses[menuEntry]
          osSpecific = componentOptions.osSpecific.nil? ? '' : "(#{componentOptions.osSpecific} only)"
          installedDirectoryMsg = componentOptions.buildInstallationDirectory.nil? ?  '' : %{ in #{componentOptions.buildInstallationDirectory}}
          installedMsg = installed ? %{(installed#{installedDirectoryMsg})} : ''
          enabledMsg = component.canBeInstalled? ? '' : '(disabled)'
          menuOption = menuEntryFormat % [entryPosition + 1 , componentOptions.name, osSpecific, installedMsg, enabledMsg]
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
    
    def getLoadedComponent(componentName)
      unless defined?( @@registeredInstances)
        @@registeredInstances = {}
      end
      return @@registeredInstances[componentName]
    end
    
    def requireComponent(componentName)
      unless defined?( @@registeredInstances)
        @@registeredInstances = {}
      end
      newInstance =  @@registeredInstances[componentName]
      unless newInstance
        fullyQualifiedCopmonentName = %{components/#{componentName}}
        remoteRequire(fullyQualifiedCopmonentName)
        newInstanceCmd = %{newInstance = #{fileNameToClassName(componentName)}.new}
        eval(newInstanceCmd)
        @@registeredInstances[componentName] = newInstance
      end
      return newInstance
    end
    
    def fileNameToClassName(fileName)
      firstCharacter = fileName[0,1]
      firstCharacter = firstCharacter.upcase
      fileName = firstCharacter + fileName[1..-1]
      return fileName
    end
    
    def preloadComponents
      components = []
      ::MENU_ORDER.each do |menuEntry|
        next if menuEntry == ::MENU_SEPARATOR
        components << menuEntry
      end
      components = components.uniq
      components.each do |componentName|
        componentOptions = getComponentOptions(componentName) 
        currentComponent = requireComponent(componentOptions.componentInstallerName)
        loadComponentSettings(componentName)
      end
    end
    
    def installComponent(componentName)
      componentOptions = getComponentOptions(componentName) 
      currentComponent = requireComponent(componentOptions.componentInstallerName)
      loadComponentSettings(componentName)
      if currentComponent.canBeInstalled?
        logger.info(%{Installing component '#{componentOptions.name}'})

        componentDependencies = componentOptions.componentDependencies
        if componentDependencies
          componentDependencies.each do |componentDependency|
            installComponent(componentDependency)
          end
        end

        if currentComponent 
          currentComponent.completeObtainBuildInstallConfigure
          componentOptions.installed = true
        end
      else
        logger.info(%{Component '#{componentOptions.name}' disabled. Skipping install ...})
      end
      
    end
    
    def loadComponentSettings(componentName)
      unless defined?(@@loadededSettings)
        @@loadedSettings = {}
      end
      customSettingsFile = File.basename("#{componentName}Settings")
      #puts "remoteRequire customSettingsFile #{customSettingsFile}"
      if File.exists?(customSettingsFile)
        unless @@loadedSettings[customSettingsFile]
          logger.info(%{Loading settings file #{customSettingsFile}})
          fileContents = IOHelpers.readFile(customSettingsFile)
          eval(fileContents.join("\n"))
          @@loadedSettings[customSettingsFile] = true
        end
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