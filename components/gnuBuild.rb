#!/usr/bin/env jruby

class GnuBuild
  
  def preInstall
    puts("gnuBuild.preInstall")
  end

  def install
    puts("gnuBuild.install")
  end

  def postInstall()
    puts("gnuBuild.postInstall")
  end
  
  def configure()
    puts("gnuBuild.configure")
  end
  
end
