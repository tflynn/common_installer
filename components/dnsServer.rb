#!/usr/bin/env jruby

remoteRequire 'components/gnuBuild'

class DnsServer < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.dnsServer
  end
  
  
  def alreadyInstalled?
    return File.exists?('/etc/mararc')
  end
  
  def configureBuild
    # puts "Entering DnsServer.configureBuild"
    # caller[0,5].each do |callEntry|
    #   puts "DnsServer.configureBuild #{callEntry}"
    # end
    executeWithErrorCheck do
      options = getOptions.dup
      options[:customConfigureBuildCommand] = "export PREFIX=#{@settings.buildInstallationDirectory}   ; ./configure"
      results = BuildHelper.configureBuild(@settings,options)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  
end
