#!/usr/bin/env jruby

class ApacheWebServer
  
  def preInstall
    puts("apacheWebServer.preInstall")
  end

  def install
    puts("apacheWebServer.install")
  end

  def postInstall()
    puts("apacheWebServer.postInstall")
  end
  
end
