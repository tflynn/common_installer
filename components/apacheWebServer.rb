#!/usr/bin/env jruby

remoteRequire 'components/gnuBuild'

class ApacheWebServer < GnuBuild
  
  def preInstall
    puts("apacheWebServer.preInstall")
  end

  def install
    puts("apacheWebServer.install")
  end

  def postInstall()
    puts("apacheWebServer.postInstall")
  end
  
  def configure()
    puts("apacheWebServer.configure")
  end
  
end
