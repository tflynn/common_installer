#!/usr/bin/env jruby

remoteRequire 'buildHelper'

class DnsServer
  
  def alreadyInstalled?
    return File.exists?('/etc/mararc')
  end
  
  def preInstall
    #puts("dnsServer.preInstall")
  end

  def install
    settings = COMPONENT_OPTIONS.dnsServer
    options = {}
    unless alreadyInstalled?
      BuildHelper.standardBuildAndInstall(settings,options)
    end
    return SUCCESS
  end

  def postInstall()
    #puts("dnsServer.postInstall")
  end
  
  def configure()
    puts("dnsServer.configure")
  end
  
end
