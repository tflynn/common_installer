#!/usr/bin/env jruby

remoteRequire 'osHelpers'
remoteRequire 'installerLogger'
remoteRequire 'core'

#TODO use dependencies to generate appropriate path.
# Send in to command to pass as 'export PATH=....'



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
    
    def getDistributionFile(distributionGroup,distributionFile,settings,options = {})
      remoteRepo = REMOTE_REPOSITORIES.first
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      cmd = "mkdir -p #{srcDir}"
      retVal = OSHelpers.executeCommand(cmd)
      if retVal == SUCCESS
        Dir.chdir(srcDir) do |dir|
          cmd = %{wget #{remoteRepo}/#{distributionGroup}/#{distributionFile}}
        end
        retVal = OSHelpers.executeCommand(cmd)
      end
      return retVal
    end
    
    def unpackFile(fileName,settings,options = {})
      cmd = nil
      retVal = nil
      baseFileName = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}

      if fileName =~ /\.tar\.gz$/
        cmd = %{tar xzf #{fileName}}
        baseFileName = fileName.gsub('.tar.gz','')
      elseif fileName =~ /\.tgz$/
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
          retVal = OSHelpers.executeCommand(cmd)
        end
      else
        retVal = FAILURE
      end
      return {:retVal => retVal, :baseFileName => baseFileName }
    end
    
    def configure(baseFileName,settings,options = {})
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          buildInstallationDirectory = settings.buildInstallationDirectory
          if buildInstallationDirectory
            cmd = %{./configure --prefix=#{buildInstallationDirectory}}
          else
            cmd = %{./configure}
          end
          retVal = OSHelpers.executeCommand(cmd)
        end
      end
      return retVal
    end
    
    def make(baseFileName,settings,options = {})
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          cmd = %{make}
          retVal = OSHelpers.executeCommand(cmd)
        end
      end
      return retVal
    end
    
    def install(baseFileName,settings,options = {})
      retVal = nil
      srcDir = %{#{settings.buildInstallationDirectory}/src}
      Dir.chdir(srcDir) do |xdir|
        Dir.chdir(baseFileName) do |dir|
          cmd = %{make install}
          retVal = OSHelpers.executeCommand(cmd)
        end
      end
      return retVal
    end

    def standardBuildAndInstall(settings,options = {})
      getDistributionFile(settings.distributionGroup,settings.distributionFile,settings,options)
      results = unpackFile(settings.distributionFile,settings,options)
      baseFileName = results[:baseFileName]
      configure(baseFileName,settings,options)
      make(baseFileName,settings,options)
      install(baseFileName,settings,options)
      return SUCCESS
    end
    
  end
  
end