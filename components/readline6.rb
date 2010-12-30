#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'components/gnuBuild'
remoteRequire 'buildHelper'

class Readline6 < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.readline6
  end

  def alreadyInstalled?
    buildInstallationDirectory = @settings.buildInstallationDirectory
    includeFile = "#{buildInstallationDirectory}/include/readline/readline.h"
    staticLibFile = "#{buildInstallationDirectory}/lib/libreadline.a"
    componentInstalled = File.exists?(includeFile) and File.exists?(staticLibFile)
    logger.info("Component: #{@settings.name} : Checking for presence of files '#{includeFile}' and  '#{staticLibFile}' . File  #{includeFile} #{File.exists?(includeFile) ? 'is' : 'is not'} present and file #{staticLibFile}  #{File.exists?(staticLibFile) ? 'is' : 'is not'} present so component #{componentInstalled ? 'is' : 'is not'} already installed.")
    return componentInstalled
  end

  def make
    buildInstallationDirectory = @settings.buildInstallationDirectory
    systemType = OSHelpers.getSystemType 
    if systemType == SYSTEM_TYPE_LINUX
      super
    elsif systemType == SYSTEM_TYPE_OSX
      executeWithErrorCheck do
        options = getOptions.merge({:customMakeCommand => %{make SHOBJ_LDFLAGS=-dynamiclib } })
        results = BuildHelper.make(@baseFileName,@settings,options)
        @status = results[:retVal]
        { :status => @status, :errorMsg => results[:errorMsg] }
      end
    end
  end

  
  
end