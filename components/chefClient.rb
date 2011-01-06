#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'components/gnuBuild'
remoteRequire 'buildHelper'

class ChefClient < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.chefClient
  end

  def alreadyInstalled?
    return false
  end
  
  def getDistribution
  end

  def unpackDistribution
  end
  
  def configureBuild
    msg = "Don't know how to configure Chef Client yet"
    logger.debug("msg")
    puts msg
  end

  def make
  end

  def install
    msg = "Don't know how to install Chef Client yet"
    logger.debug("msg")
    puts msg
  end

end
