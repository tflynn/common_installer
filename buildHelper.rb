#!/usr/bin/env jruby

require 'fileutils'

remoteRequire 'osHelpers'
remoteRequire 'installerLogger'
remoteRequire 'core'
remoteRequire 'ioHelpers'

class BuildHelper
  
  class << self
    
    def getDependencyPaths(settings,options = {})
      dependencyPaths = []
      if settings.componentDependencies
        settings.componentDependencies.each do |componentDependency|
          componentOptions = Core.getComponentOptions(componentDependency)
          dependencyPaths << componentOptions.buildInstallationDirectory
        end
        dependencyPaths = dependencyPaths.uniq
      else
        dependencyPaths = nil
      end
      return dependencyPaths
    end
    
    def updateLdconfig(newPath)
      ldConfigFile = '/etc/ld.so.conf'
      ldConfigBin = OSHelpers.getCommandLocation('ldconfig')
      systemType = OSHelpers.getSystemType
      results = nil
      if systemType == SYSTEM_TYPE_LINUX
        if File.exists?(ldConfigFile)
          matchingEntryFound = false
          fileContents = IOHelpers.readFile(ldConfigFile)
          fileContents.each do |line|
            if line == newPath
              matchingEntryFound = true
              break
            end
          end
          if matchingEntryFound
            logger.info("ldconfig: #{ldConfigFile} already contains #{newPath}")
            results = {:status => SUCCESS}
          else
            logger.info("ldconfig:  Adding #{newPath} to #{ldConfigFile}")
            File.open(ldConfigFile,'a') do |file|
              file.puts(newPath)
            end
            results = {:status => SUCCESS}
          end
        end
        OSHelpers.executeCommand(ldConfigBin)
      else
        results = {:status => SUCCESS}
      end
      return results
    end
    
    def executeCommandWithBuildEnvironment(cmd, settings,options = {})
      fullCmd = nil
      additionalPaths = [%{#{settings.buildInstallationDirectory}/bin}]
      if options[:dependencyPaths]
        options[:dependencyPaths].each do |dependencyPath|
          additionalPaths << "#{dependencyPath}/bin"
        end
      end
      results = OSHelpers.executeCommand(cmd,{:additionalPaths => additionalPaths })
      retVal = results[:retVal]
      return retVal
    end
    
    def makeStandardBuildDirectories(settings, options = {})
      ::DEFAULT_BUILD_DIRECTORIES.each do |buildDir|
        fullDir = "#{settings.buildInstallationDirectory}/#{buildDir}"
        FileUtils.mkdir_p(fullDir)
      end
    end
    
    def getDistributionFile(settings,options = {})
      distributionGroup = settings.distributionGroup
      distributionFile = settings.distributionFile
      remoteRepo = REMOTE_REPOSITORIES.first
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      cmd = "mkdir -p #{srcDir}"
      results = OSHelpers.executeCommand(cmd)
      retVal = results[:retVal]
      distributionFileURI = "#{remoteRepo}/#{distributionGroup}/#{distributionFile}"
      errorMsg = nil
      if retVal == SUCCESS
        Dir.chdir(srcDir) do |dir|
          if File.exists?(distributionFile)
            File.delete(distributionFile)
          end
          cmd = %{wget -q #{distributionFileURI}}
          results = OSHelpers.executeCommand(cmd)
          retVal = results[:retVal]
        end
      end
      if retVal == FAILURE
        errorMsg = "Component #{settings.name} : Unable to retrieve distribution file #{distributionFileURI}"
      end  
      return {:retVal => retVal, :errorMsg => errorMsg }
    end
    
    def unpackFile(settings,options = {})
      fileName = settings.distributionFile
      cmd = nil
      retVal = FAILURE
      baseFileName = nil
      errorMsg = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}

      if fileName =~ /\.tar\.gz$/
        cmd = %{tar xzf #{fileName}}
        baseFileName = fileName.gsub('.tar.gz','')
      elsif fileName =~ /\.tgz$/
        cmd = %{tar xzf #{fileName}}
        baseFileName = fileName.gsub('.tgz','')
      elsif fileName =~ /\.tar\.bz2$/
        cmd = %{tar xjf #{fileName}}
        baseFileName = fileName.gsub('.tar.bz2','')
      elsif fileName =~ /\.zip$/
        cmd = %{unzip #{fileName}}
        baseFileName = fileName.gsub('.zip','')
      end
      if cmd
        Dir.chdir(srcDir) do |dir|
          if File.exists?(baseFileName)
            FileUtils.rm_rf(baseFileName)
          end
          results = OSHelpers.executeCommand(cmd)
          retVal = results[:retVal]
        end
      end
      if retVal == FAILURE
        errorMsg = "Component #{settings.name} : Unable to unpack #{fileName}"
      end
      return {:retVal => retVal, :baseFileName => baseFileName , :errorMsg => errorMsg}
    end
    
    def configureBuild(settings,options = {})
      # puts "Entering BuildHelper.configureBuild"
      # caller[0,10].each do |callEntry|
      #   puts "BuildHelper.configureBuild #{callEntry}"
      # end
      # 
      makeStandardBuildDirectories(settings)
      baseFileName = options[:baseFileName]
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          buildInstallationDirectory = settings.buildInstallationDirectory
          if options[:customConfigureBuildCommand]
            cmd = options[:customConfigureBuildCommand]
          else
            if buildInstallationDirectory
              cmd = %{./configure --prefix=#{buildInstallationDirectory}}
            else
              cmd = %{./configure}
            end
          end
          retVal = executeCommandWithBuildEnvironment(cmd, settings,options)
        end
      end
      if retVal == FAILURE
        errorMsg = "Component #{settings.name} : Unable to configure build"
      end
      return {:retVal => retVal, :errorMsg => errorMsg}
    end
    
    def make(baseFileName,settings,options = {})
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          if options[:customMakeCommand]
            cmd = options[:customMakeCommand]
          else
            cmd = %{make}
          end
          retVal = executeCommandWithBuildEnvironment(cmd, settings,options)
        end
      end
      if retVal == FAILURE
        errorMsg = "Component #{settings.name} : Unable to 'make' build"
      end
      return {:retVal => retVal, :errorMsg => errorMsg}
    end
    
    def install(baseFileName,settings,options = {})
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          if options[:customMakeInstallCommand]
            cmd = options[:customMakeInstallCommand]
          else
            cmd = %{make install}
          end
          retVal = executeCommandWithBuildEnvironment(cmd, settings,options)
        end
      end
      if retVal == FAILURE
        errorMsg = "Component #{settings.name} : Unable to install build"
      end
      return {:retVal => retVal, :errorMsg => errorMsg}
    end

  end
  
end