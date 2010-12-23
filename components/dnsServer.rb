#!/usr/bin/env jruby

class DnsServer
  
  def preInstall
    puts("dnsServer.preInstall")
  end

  def install
    puts("dnsServer.install")
  end

  def postInstall()
    puts("dnsServer.postInstall")
  end
  
end
