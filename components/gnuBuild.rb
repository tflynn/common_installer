#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'core'
remoteRequire 'buildHelper'

class GnuBuild
  
  def initialize
    @settings = nil
    @options = {}
    @dependencyPaths = nil
    @baseFileName = nil
    @status = nil
  end

  def getSettings
    return @settings
  end
  
  def getDependencyPaths
    if @dependencyPaths == :none
      return nil
    end
    if @dependencyPaths.nil?
      @dependencyPaths = BuildHelper.getDependencyPaths(getSettings)
    end
    if @dependencyPaths.nil?
      @dependencyPaths == :none
      return nil
    else
      return @dependencyPaths
    end
  end
  
  def getOptions
    @options[:dependencyPaths] = getDependencyPaths unless @options[:dependencyPaths]
    @options[:baseFileName] = @baseFileName unless @options[:baseFileName]
    @options[:status] = @status
    return @options
  end
  
  def canBeInstalled?
    return true
  end
  
  def alreadyInstalled?
    return false
  end
  
  def installNeeded?
    needToInstall = true
    needToInstall = false if alreadyInstalled?
    needToInstall = false if @status == FAILURE
    return needToInstall
  end
  
  def executeWithErrorCheck(options = {})
    options = {:installCheck => true }.merge(options)
    installCheck = options[:installCheck]
    if block_given?
      #puts "gnuBuild.executeWithErrorCheck for #{callingComponentName} block provided"
      if installCheck
        goExecute = installNeeded?
      else
        goExecute = true
      end
      if goExecute 
        results = yield
        status = results[:status]
        errorMsg = results[:errorMsg]
        if status == FAILURE
          logger.error("#{errorMsg}. Exiting ...")
          Core.errorExit
        end
      end
    else
      #puts "gnuBuild.executeWithErrorCheck for #{callingComponentName}  no block provided"
    end
  end
  
  def beforeGetDistribution
  end
  
  def getDistribution
    executeWithErrorCheck do 
      results = BuildHelper.getDistributionFile(@settings,getOptions)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def afterGetDistribution
  end
  
  def beforeUnpackDistribution
  end

  def unpackDistribution
    executeWithErrorCheck do
      results =  BuildHelper.unpackFile(@settings,getOptions)
      @status = results[:retVal]
      @baseFileName = results[:baseFileName]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end

  def afterUnpackDistribution
  end
  
  def beforeConfigureBuild
  end
  
  def configureBuild
    # puts "Entering gnuBuild.configureBuild"
    # caller[0,5].each do |callEntry|
    #   puts "gnuBuild.configureBuild #{callEntry}"
    # end
    executeWithErrorCheck do
      results = BuildHelper.configureBuild(@settings,getOptions)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def afterConfigureBuild
  end

  def beforeMake
  end
  
  def make
    executeWithErrorCheck do
      results = BuildHelper.make(@baseFileName,@settings,getOptions)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def afterMake
  end
     
     
  def beforeInstall
  end
  
  def install
    executeWithErrorCheck do
      results = BuildHelper.install(@baseFileName,@settings,getOptions)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end

  def afterInstall
  end
  
  def beforeConfigure
  end

  def configure
  end
  
  def afterConfigure
  end
  
  def beforeRun
  end
  
  def run
  end
  
  def afterRun
  end
  
  def afterEverything
  end
  
  def completeObtainBuildInstallConfigure
    beforeGetDistribution
    getDistribution
    afterGetDistribution
    beforeUnpackDistribution
    unpackDistribution
    afterUnpackDistribution
    beforeConfigureBuild
    configureBuild
    afterConfigureBuild
    beforeMake
    make
    afterMake
    beforeInstall
    install
    afterInstall
    beforeConfigure
    configure
    afterConfigure
    beforeRun
    run
    afterRun
    afterEverything
  end
  
end
