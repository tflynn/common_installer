#!/usr/bin/env jruby

class BaseSystem
  
  def preInstall
    puts("baseSystem.preInstall")
  end

  def install
    puts("baseSystem.install")
  end

  def postInstall()
    puts("baseSystem.postInstall")
  end
  
  def configure()
    puts("baseSystem.configure")
  end
  
end
