#!/usr/bin/env jruby

class BaseSystem
  
  def initialize
    @settings = @settings = COMPONENT_OPTIONS.baseSystem
  end
  
  def alreadyInstalled?
    return false
  end

  def canBeInstalled?
    return true
  end
  
end
