#!/usr/bin/env jruby

remoteRequire 'installerLogger'
remoteRequire 'components/gnuBuild'
remoteRequire 'buildHelper'

class ChefServer < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.chefServer
  end

  def alreadyInstalled?
    return false
  end
  
  def getDistribution
  end

  def unpackDistribution
  end
  
  def configureBuild
    msg = "Don't know how to configure Chef Server yet"
    logger.debug("msg")
    puts msg
  end

  def make
  end

  def install
    msg = "Don't know how to install Chef Server yet"
    logger.debug("msg")
    puts msg
  end

end
