#!/usr/bin/env jruby

require 'tempfile'

remoteRequire 'core'
remoteRequire 'installerLogger'
remoteRequire 'ioHelpers'

SYSTEM_TYPE_LINUX = 'linux'
SYSTEM_TYPE_OSX = 'osx'
SYSTEM_TYPE_UNKNOWN = 'unknown'

LINUX_TYPE_REDHAT='redhat'
LINUX_TYPE_CENTOS='centos'
LINUX_TYPE_DEBIAN='debian'
LINUX_TYPE_UBUNTU='ubuntu'
LINUX_TYPE_FEDORA='fedora'
LINUX_TYPE_UNKNOWN='unknown'

LINUX_TYPES_SUPPORTED = [LINUX_TYPE_REDHAT,LINUX_TYPE_CENTOS]

# Redhat-derived
LINUX_INSTALLER_YUM='yum'
LINUX_INSTALLER_RPM='rpm'
# Debian
LINUX_INSTALLER_APTITUDE='aptitude'
# Gentoo
LINUX_INSTALLER_PORTAGE='portage'
LINUX_INSTALLER_UNKNOWN='unknown'
# Ubuntu - synaptics

class OSHelpers

  class << self
    
    def getSystemType

      systemType = ::SYSTEM_SETTINGS.systemType
      return systemType unless systemType.nil?

      results = `uname -a | grep -q -i linux`.chomp.strip
      status = $?
      if status == 0
        systemType = SYSTEM_TYPE_LINUX
      else
        results = `uname -a | grep -q -i darwin`.chomp.strip
        status = $?
        if status == 0 then
          systemType = SYSTEM_TYPE_OSX
        end
      end
      ::SYSTEM_SETTINGS.systemType = systemType
      return systemType
    end
    
    def getLinuxInstallerType
      
      installerType = ::SYSTEM_SETTINGS.linuxInstallerType
      return installerType unless installerType.nil?
      
      installerType = LINUX_INSTALLER_UNKNOWN
      if isCommmandPresent?('yum')
        installerType = LINUX_INSTALLER_YUM
      elsif isCommmandPresent?('rpm')
        installerType = LINUX_INSTALLER_RPM
      elsif isCommmandPresent?('aptitude')
        installerType =  LINUX_INSTALLER_APTITUDE
      elsif isCommmandPresent?('aptitude')
        installerType =  LINUX_INSTALLER_PORTAGE
      end
      ::SYSTEM_SETTINGS.linuxInstallerType = installerType
      return installerType
    end

    # /etc/issue
    # RedHat 4 - Red Hat Enterprise Linux AS release 4 (Nahant Update 4)
    # RedHat 5 - Red Hat Enterprise Linux Server release 5.4 (Tikanga)
    # Centos 5 - CentOS release 5.5 (Final)
    # Debian 5 - Debian GNU/Linux 5.0 \n \l
    # Ubuntu 10 - Ubuntu 10.10 \n \l
    # Fedora 14 - Fedora release 14 (Laughlin) 
    
    def getLinuxTypeAndVersion
      
      linuxTypeAndVersion = ::SYSTEM_SETTINGS.linuxTypeAndVersion
      return linuxTypeAndVersion unless linuxTypeAndVersion.nil?

      linuxType = linuxType = LINUX_TYPE_UNKNOWN
      linuxVersion = nil
      if File.exists?('/etc/issue')
        issueLine = IOHelpers.readFile('/etc/issue').first
        parts = issueLine.split(' ')
        if issueLine =~ /Red.*Hat/i
          linuxType = LINUX_TYPE_REDHAT
          linuxVersion = parts[6]
        elsif issueLine =~ /Centos/i
          linuxType = LINUX_TYPE_CENTOS
          linuxVersion = parts[2]
        elsif issueLine =~ /Debian/i
          linuxType = LINUX_TYPE_DEBIAN
          linuxVersion = parts[2]
        elsif issueLine =~ /Ubuntu/i
          linuxType = LINUX_TYPE_UBUNTU
          linuxVersion = parts[1]
        elsif issueLine =~ /Fedora/i
          linuxType = LINUX_TYPE_FEDORA
          linuxVersion = parts[2]
        end
      end
      linuxTypeAndVersion = {:type => linuxType , :version => linuxVersion}
      ::SYSTEM_SETTINGS.linuxTypeAndVersion = linuxTypeAndVersion
      return linuxTypeAndVersion
    end
    
    def executeCommand(cmd,options = {})
      options = {:commandOutput => false }.merge(options)
      additionalPaths = []
      additionalPaths = additionalPaths.concat(options[:additionalPaths]) if options[:additionalPaths]
      additionalPaths = additionalPaths.concat(::DEFAULT_PATHS)
      # caller[0,15].each do |callEntry|
      #   puts "OSHelpers.executeCommand #{callEntry}"
      # end
      allPaths = additionalPaths.join(":")
      almostFullCmd = %{export PATH=#{allPaths} ;  #{cmd} }
      logger.debug("Executing command \"#{almostFullCmd}\"")
      tempFile = Tempfile.new("cmdOut")
      if logger.consoleLogging
        fullCmd = %{export PATH=#{allPaths} ; ( #{cmd} 2>&1 ; echo $? >status.tmp ) | tee #{tempFile.path} }
        Kernel.system(fullCmd)
        status = IO.read('status.tmp').strip.chomp.to_i 
        File.delete('status.tmp')
      else
        fullCmd = %{#{almostFullCmd} >#{tempFile.path} 2>&1}
        status = Kernel.system(fullCmd)
        # If Kernel.system returns a false results, docs say error code is in $?
        if status == true
          status = 0
        else
          status = $?
        end
      end
      cmdOutput = IO.read(tempFile.path)
      File.open(logger.getFileName,'a') do |logfile|
        logfile.write(cmdOutput)
      end
      retVal = status == 0 ? SUCCESS : FAILURE
      File.delete(tempFile.path)
      return {:status => status , :fullCommand => almostFullCmd, :commandOutput => cmdOutput , :retVal => retVal }
    end
    
    def isCommmandPresent?(cmd)
      results = executeCommand("which #{cmd}")
      return results[:status] == 0
    end

    def isCommmandRunning?(cmd)
      fullCmd = %{ps alwwwx |  grep -i "#{cmd}" | grep -v grep | grep -v fps}
      results = executeCommand(fullCmd, {:commandOutput => true })
      commandOutput = results[:commandOutput]
      #puts "isCommmandRunning? commandOutput #{commandOutput} "
      #puts "isCommmandRunning? cmd #{cmd} commandOutput.index(cmd) #{commandOutput.index(cmd).inspect}"
      return commandOutput.index(cmd) != nil
    end
    
    def getCommandLocation(cmd)
      results = executeCommand("which #{cmd}" , {:commandOutput => true })
      if results[:status] == 0
        commandLocation = results[:commandOutput].first
        return commandLocation
      else
        return nil
      end
    end
  end
  
end

