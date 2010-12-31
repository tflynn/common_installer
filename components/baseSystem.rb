#!/usr/bin/env jruby

require 'fileutils'

remoteRequire 'installerLogger'
remoteRequire 'components/gnuBuild'
remoteRequire 'buildHelper'
remoteRequire 'ioHelpers'
remoteRequire 'osHelpers'
remoteRequire 'networkHelper'

class BaseSystem < GnuBuild
  
  def initialize
    super
    @settings = COMPONENT_OPTIONS.baseSystem
    @installationIndicator = 'baseSystem.installed'
  end

  def alreadyInstalled?
    installationStatus = false
    if ::SYSTEM_SETTINGS.baseSystemConfigured.nil?
      if @settings.forceReloadOnEveryRestart
        FileUtils.rm_f(@installationIndicator)
      end
      installationStatus = File.exists?(@installationIndicator)
    else
      installationStatus =  true
    end
    logger.info("BaseSystem #{installationStatus ? 'is' : 'is not'} already installed")
    return installationStatus
  end

  def installNeeded?
    return true
  end
  
  def getDistribution
  end
  
  def unpackDistribution
  end
  
  def configureBuild
  end
  
  def make
  end
  
  def install
  end
  
  def configure
    unless alreadyInstalled?
      # UTC Time zone
      ensureUTC
      # NTP Service
      ensureNTPService
      # hostname
      setPermanentHostname
      # Do nothing with firewall for present - iptables or ipfw?
      
      ::SYSTEM_SETTINGS.baseSystemConfigured = true
      FileUtils.touch(@installationIndicator)
    end
  end
  
  def ensureUTC
    date = `date`.strip.chomp
    systemType = OSHelpers.getSystemType

    if systemType == SYSTEM_TYPE_LINUX
      unless date =~ /UTC/i
        if ::SYSTEM_SETTINGS.forceUTCClockLinux
          OSHelpers.executeCommand('ln -sf /usr/share/zoneinfo/UTC /etc/localtime')
        end
      end
    end
    
    if systemType == SYSTEM_TYPE_OSX
      unless date =~ /UTC/i
        if ::SYSTEM_SETTINGS.forceUTCClockOSX
          OSHelpers.executeCommand('ln -sf /usr/share/zoneinfo/UTC /etc/localtime')
        else
          force = IOHelpers.readKeyboardWithPromptYesNo("If this OS X system is being used as a server, force the system clock to UTC?")
          if force
            OSHelpers.executeCommand('ln -sf /usr/share/zoneinfo/UTC /etc/localtime')
          end
        end
      end
    end

  end
  
  def ensureNTPService
    systemType = OSHelpers.getSystemType

    if systemType == SYSTEM_TYPE_LINUX
      unless OSHelpers.isCommmandPresent?('ntpd')
        if OSHelpers.getLinuxInstallerType == LINUX_INSTALLER_YUM
          OSHelpers.executeCommand('yum -y install ntp')
        end
      end
      if OSHelpers.isCommmandPresent?('ntpd')
        if OSHelpers.isCommmandRunning?('ntpd')
          OSHelpers.executeCommand('/sbin/service ntpd stop')
        end
        #Fix system config to force hardware clock synchronization
        outputLines = []
        inputLines = IOHelpers.readFile('/etc/sysconfig/ntpd',{:skipComments => false, :skipEmpty => false})
        inputLines.each do |inputLine|
          if inputLine =~ /^SYNC_HWCLOCK/
            outputLines << 'SYNC_HWCLOCK=yes'
          else
            outputLines << inputLine
          end
        end
        IOHelpers.overwriteFile('/etc/sysconfig/ntpd',outputLines)
        #Restart service
        OSHelpers.executeCommand('/sbin/service ntpd start')
      else
        logger.error("Unable to install 'ntp'. Please install 'ntp' manually and return this installer. Leaving ")
        Core.errorExit
      end
    end
    if systemType == SYSTEM_TYPE_OSX
      unless OSHelpers.isCommmandRunning?('ntpd')
        # Don't have to worry - NTP service runs by default if 'Set date and time automatically ...
        IOHelpers.readKeyboardWithPrompt(%{When running on a OS X system ensure that "System Preferences > Date and Time > 'Set date and time automatically'" is set.})
      end
    end
    
  end
  
  def setPermanentHostname
    
    permanentHostName = ::SYSTEM_SETTINGS.permanentHostName
    return unless permanentHostName.nil?
    
    systemType = OSHelpers.getSystemType
    
    hostName = nil
    
    if systemType == SYSTEM_TYPE_OSX
      setHostName = IOHelpers.IOHelpers.readKeyboardWithPromptYesNo(%{If this OS X system is being used as a server, set the permanent host name ?})
      if setHostName
        hostName = IOHelpers.IOHelpers.readKeyboardWithResponseWithPrompt(%{Enter host name})
        ::SYSTEM_SETTINGS.hostName = hostName
         OSHelpers.executeCommand("scutil –set HostName #{hostName}")
      end
    elsif systemType == SYSTEM_TYPE_LINUX
      if ::SYSTEM_SETTINGS.setPermanentHostName
        linuxSystemType = OSHelpers.getLinuxTypeAndVersion[:type]
        hostName = IOHelpers.readKeyboardWithResponseWithPrompt(%{Enter host name})
        logger.info("Setting permanent hostname to #{hostName}")
        ::SYSTEM_SETTINGS.hostName = hostName
        if linuxSystemType == LINUX_TYPE_REDHAT or linuxSystemType == LINUX_TYPE_CENTOS or linuxSystemType == LINUX_TYPE_FEDORA
          #/etc/sysconfig/network
          outputLines = []
          inputLines = IOHelpers.readFile('/etc/sysconfig/network',{:skipComments => false, :skipEmpty => false})
          inputLines.each do |inputLine|
            if inputLine =~ /^HOSTNAME/
              outputLines << "HOSTNAME=#{hostName}"
            else
              outputLines << inputLine
            end
          end
          IOHelpers.overwriteFile('/etc/sysconfig/network',outputLines)
        elsif linuxSystemType == LINUX_TYPE_DEBIAN or linuxSystemType == LINUX_TYPE_UBUNTU
          outputLines = [hostname]
          IOHelpers.overwriteFile('/etc/hostname',outputLines)
        end  
      end
      # Make sure it's set right now for the local session - the preceeding sets up hostname on a reboot
      if hostName
        OSHelpers.executeCommand("hostname #{hostName}")
      end
    end
    
    unless systemType == SYSTEM_TYPE_UNKNOWN
      # /etc/hosts
      primaryIPAddress = NetworkHelper.getPrimaryIPAddress
      userIPAddress = IOHelpers.readKeyboardWithPrompt("Enter Primary IP address (#{primaryIPAddress})")
      if userIPAddress != ''
        primaryIPAddress = userIPAddress
      end
      ::SYSTEM_SETTINGS.primaryIPAddress = primaryIPAddress
      outputLines = []
      inputLines = IOHelpers.readFile('/etc/hosts',{:skipComments => false, :skipEmpty => false})
      primaryIPAddressWritten = false
      inputLines.each do |inputLine|
        if inputLine.index(primaryIPAddress)
          outputLines << "#{primaryIPAddress}    #{hostName}"
          primaryIPAddressWritten = true
        else
          outputLines << inputLine
        end
      end
      unless primaryIPAddressWritten
        outputLines << "#{primaryIPAddress}    #{hostName}"
      end
      IOHelpers.overwriteFile('/etc/hosts',outputLines)
    end
    
  end
  
end
