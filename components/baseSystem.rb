#!/usr/bin/env jruby

class BaseSystem
  
  def preInstall
    puts("baseSystempreInstall")
  end

  def install
    puts("baseSysteminstall")
  end

  def postInstall()
    puts("baseSystempostInstall")
  end
  
end
