#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'components/gnuBuild'
remoteRequire 'buildHelper'
remoteRequire 'ioHelpers'

class Openssl < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.openssl
  end

  def alreadyInstalled?
    buildInstallationDirectory = @settings.buildInstallationDirectory
    includeFile = "#{buildInstallationDirectory}/include/openssl/opensslconf.h"
    staticLibFile = "#{buildInstallationDirectory}/lib/libssl.a"
    componentInstalled = File.exists?(includeFile) and File.exists?(staticLibFile)
    logger.info("Component: #{@settings.name} : Checking for presence of files '#{includeFile}' and  '#{staticLibFile}' . File  #{includeFile} #{File.exists?(includeFile) ? 'is' : 'is not'} present and file #{staticLibFile}  #{File.exists?(staticLibFile) ? 'is' : 'is not'} present so component #{componentInstalled ? 'is' : 'is not'} already installed.")
    return componentInstalled
  end


  def beforeConfigureBuild
    if @settings.patchOSX64bitConfiguration
      systemType = OSHelpers.getSystemType
      errorMsg = nil
      executeWithErrorCheck do
        if systemType == SYSTEM_TYPE_OSX
          baseFileName = getOptions[:baseFileName]
          srcDir = %{#{settings.buildInstallationDirectory}/src}
          Dir.chdir(srcDir) do |xdir|
            Dir.chdir(baseFileName) do |dir|
              begin
                outputLines = []
                inputLines = IOHelpers.readFile('./Configure',{:skipComments => false, :skipEmpty => false})
                inputLines.each do |inputline|
                  outputLine = nil
                  if inputLine =~ /^\"darwin-i386-cc\"/
                    outputLine = "##{inputLine}"
                  elsif inputLine =~ /^\"darwin64-x86_64-cc\"/
                    modifiedOutputLine = inputLine.sub(/darwin64-x86_64-cc/,'darwin-i386-cc')
                    outputLines << modifiedOutputLine
                    outputLine = inputLine
                  else
                    outputLine = inputLine
                  end
                  outputLines << outputLine
                end
                IOHelpers.overwriteFile('./Configure',outputLines)
                @status = SUCCESS
                logger.info( %{Openssl.beforeConfigureBuild patched ./Configure to build OSX 64-bit version correctly})
              rescue Exception => ex
                errorMsg = %{Openssl.beforeConfigureBuild failed \n #{ex.to_s} \n #{ex.backtrace.join("\n")}}
                @status = FAILURE
              end
            end
          end
        end
        { :status => @status, :errorMsg => errorMsg }
      end
    end
  end
  
  def configureBuild
    executeWithErrorCheck do
      buildInstallationDirectory = @settings.buildInstallationDirectory
      systemType = OSHelpers.getSystemType
      if systemType == SYSTEM_TYPE_LINUX
        cmd = %{./config shared --prefix=#{buildInstallationDirectory} --openssldir=#{buildInstallationDirectory}/openssl}
      elsif systemType == SYSTEM_TYPE_OSX
        cmd = %{./config shared --prefix=#{buildInstallationDirectory} --openssldir=#{buildInstallationDirectory}/openssl -fPIC}
      end
      options = getOptions.merge({:customConfigureBuildCommand => cmd })
      results = BuildHelper.configureBuild(@settings,options)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end

  def afterInstall
    if @settings.patchOSXHeadersForRuby
      systemType = OSHelpers.getSystemType
      errorMsg = nil
      buildInstallationDirectory = @settings.buildInstallationDirectory
      includeFile = "#{buildInstallationDirectory}/include/openssl/bn.h"
      executeWithErrorCheck do
        if systemType == SYSTEM_TYPE_OSX
          begin
            outputLines = []
            inputLines = IOHelpers.readFile(includeFile,{:skipComments => false, :skipEmpty => false})
            inputLines.each do |inputline|
              outputLine = nil
              if inputLine =~ /^int\sBN_rand_range/
                outputLine = "/* #{inputLine} */"
              elsif inputLine =~ /^int\sBN_pseudo_rand_range/
                outputLine = "/* #{inputLine} */"
              else
                outputLine = inputLine
              end
              outputLines << outputLine
            end
            IOHelpers.overwriteFile(includeFile,outputLines)
            @status = SUCCESS
            logger.info( %{Openssl.afterInstall patched #{includeFile} to allow Ruby to build correctly on OS X})
          rescue Exception => ex
            errorMsg = %{Openssl.afterInstall failed \n #{ex.to_s} \n #{ex.backtrace.join("\n")}}
            @status = FAILURE
          end
      
        end
        { :status => @status, :errorMsg => errorMsg }
      end
    end
  end



end
